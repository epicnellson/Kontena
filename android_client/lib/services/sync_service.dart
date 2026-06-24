import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/record.dart';

class SyncResult {
  final int pushed;
  final int pulled;
  final String? error;
  const SyncResult({this.pushed = 0, this.pulled = 0, this.error});
  bool get success => error == null;
}

class SyncService {
  final String baseUrl;
  Timer? _timer;

  SyncService(this.baseUrl);

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<int> _pushPending() async {
    final pending = await DatabaseService.pendingRecords();
    if (pending.isEmpty) return 0;
    int pushed = 0;
    for (final rec in pending) {
      try {
        final res = await http.post(
          Uri.parse('$baseUrl/records'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(rec.toJson()),
        ).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200 || res.statusCode == 201) {
          await DatabaseService.markSynced(rec.id);
          pushed++;
        }
      } catch (_) {}
    }
    return pushed;
  }

  Future<int> _pullNew() async {
    final prefs = await SharedPreferences.getInstance();
    final sinceTs = prefs.getInt('last_pull_ts') ?? 0;
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/sync/batch?since=$sinceTs'),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return 0;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final newRecs = data['new_records'] as List? ?? [];
      int pulled = 0;
      for (final r in newRecs) {
        final rec = Record.fromMap({...r as Map<String, dynamic>, 'is_pending': 0});
        await DatabaseService.upsertRecord(rec);
        pulled++;
      }
      final serverTs = data['server_ts'] as int?;
      if (serverTs != null) await prefs.setInt('last_pull_ts', serverTs);
      return pulled;
    } catch (_) {
      return 0;
    }
  }

  Future<SyncResult> sync() async {
    if (!await isOnline()) {
      return const SyncResult(error: 'offline');
    }
    try {
      final pushed = await _pushPending();
      final pulled = await _pullNew();
      return SyncResult(pushed: pushed, pulled: pulled);
    } catch (e) {
      return SyncResult(error: e.toString());
    }
  }

  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => sync());
  }

  void dispose() => _timer?.cancel();
}

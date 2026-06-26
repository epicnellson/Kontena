import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_service.dart';
import '../models/record.dart';

class SyncResult {
  final int pushed;
  final int pulled;
  final String? error;
  const SyncResult({this.pushed = 0, this.pulled = 0, this.error});
  bool get success => error == null;
}

class BleService {
  static const _serviceUuid  = '0000AA01-0000-1000-8000-00805F9B34FB';
  static const _charUuid     = '0000AA02-0000-1000-8000-00805F9B34FB';
  static const _maxHops      = 3;

  final _peersController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get peersStream => _peersController.stream;

  final Map<String, String> _discoveredPeers = {};
  final Set<String> _relayedIds = {};

  StreamSubscription? _scanSub;

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> startDiscovery() async {
    final granted = await requestPermissions();
    if (!granted) return;

    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final hasService = r.advertisementData.serviceUuids
            .any((u) => u.toString().toUpperCase() == _serviceUuid);
        if (hasService) {
          _discoveredPeers[r.device.remoteId.str] = r.device.platformName;
          _peersController.add(Map.from(_discoveredPeers));
        }
      }
    });

    await FlutterBluePlus.startScan(
      withServices: [Guid(_serviceUuid)],
      timeout: const Duration(seconds: 30),
    );
  }

  Future<void> stopDiscovery() async {
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
  }

  Future<SyncResult> syncWithPeer(String deviceId) async {
    final device = BluetoothDevice.fromId(deviceId);
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      final services = await device.discoverServices();

      BluetoothCharacteristic? char;
      for (final s in services) {
        if (s.uuid.toString().toUpperCase() == _serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid.toString().toUpperCase() == _charUuid) {
              char = c;
              break;
            }
          }
        }
      }
      if (char == null) {
        await device.disconnect();
        return SyncResult(error: 'No sync characteristic found');
      }

      await char.setNotifyValue(true);
      final responseCompleter = Completer<List<int>>();
      final sub = char.onValueReceived.listen((data) {
        if (!responseCompleter.isCompleted) responseCompleter.complete(data);
      });

      final pending = await DatabaseService.pendingRecords();
      final payload = jsonEncode(pending.map((r) => r.toJson()).toList());
      await char.write(utf8.encode(payload), withoutResponse: false);

      final responseData = await responseCompleter.future
          .timeout(const Duration(seconds: 15), onTimeout: () => []);
      sub.cancel();

      int pulled = 0;
      if (responseData.isNotEmpty) {
        final List incoming = jsonDecode(utf8.decode(responseData));
        for (final r in incoming) {
          final rec = Record.fromMap({...r as Map<String,dynamic>, 'is_pending': 0});
          if (!_relayedIds.contains(rec.id)) {
            await DatabaseService.upsertRecord(rec);
            _relayedIds.add(rec.id);
            pulled++;
            if (rec.hopCount < _maxHops) {
              final relayRec = Record(
                id: rec.id, schema: rec.schema, langCode: rec.langCode,
                payload: rec.payload, createdAt: rec.createdAt,
                updatedAt: rec.updatedAt, deviceId: rec.deviceId,
                isPending: true, hopCount: rec.hopCount + 1,
              );
              await DatabaseService.upsertRecord(relayRec);
            }
          }
        }
      }

      for (final r in pending) { await DatabaseService.markSynced(r.id); }

      await device.disconnect();
      return SyncResult(pushed: pending.length, pulled: pulled);
    } catch (e) {
      return SyncResult(error: e.toString());
    }
  }

  void dispose() {
    _scanSub?.cancel();
    _peersController.close();
  }
}

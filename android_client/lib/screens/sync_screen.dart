import 'package:flutter/material.dart';
import 'package:kontena/l10n/app_localizations.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';

class SyncScreen extends StatefulWidget {
  final SyncService syncService;
  const SyncScreen({super.key, required this.syncService});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String _status = '';
  bool _syncing = false;
  int _pendingCount = 0;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.isEmpty) {
      setState(() => _status = AppL10n.of(context)!.readyToSync);
    }
  }

  Future<void> _checkState() async {
    final online = await widget.syncService.isOnline();
    final pending = await DatabaseService.pendingCount();
    if (!mounted) return;
    setState(() { _online = online; _pendingCount = pending; });
  }

  Future<void> _sync() async {
    setState(() { _syncing = true; _status = AppL10n.of(context)!.syncing; });
    final result = await widget.syncService.sync();
    await _checkState();
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _status = result.success
          ? AppL10n.of(context)!.syncSuccess(result.pushed, result.pulled)
          : 'Ɛrɔ: ${result.error}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context)!.syncTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(children: [
              Icon(_online ? Icons.wifi : Icons.wifi_off,
                  color: _online ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(_online
                  ? AppL10n.of(context)!.onlineBadge
                  : AppL10n.of(context)!.offlineBadge),
            ]),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                title: Text(AppL10n.of(context)!.pendingRecords),
                trailing: Text('$_pendingCount',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _syncing ? null : _sync,
                icon: _syncing
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
                label: Text(AppL10n.of(context)!.syncNow,
                    style: const TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

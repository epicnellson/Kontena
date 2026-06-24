import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';

class SyncScreen extends StatefulWidget {
  final SyncService syncService;
  const SyncScreen({super.key, required this.syncService});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String _status = 'Redi fɔ sink';
  bool _syncing = false;
  int _pendingCount = 0;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _checkState();
  }

  Future<void> _checkState() async {
    final online = await widget.syncService.isOnline();
    final pending = await DatabaseService.pendingCount();
    if (!mounted) return;
    setState(() { _online = online; _pendingCount = pending; });
  }

  Future<void> _sync() async {
    setState(() { _syncing = true; _status = 'Sinkin...'; });
    final result = await widget.syncService.sync();
    await _checkState();
    if (!mounted) return;
    setState(() {
      _syncing = false;
      _status = result.success
          ? '${result.pushed} push ✓  ${result.pulled} pul ✓'
          : 'Ɛrɔ: ${result.error}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sink')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(children: [
              Icon(_online ? Icons.wifi : Icons.wifi_off,
                  color: _online ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(_online ? 'Yu kɔnɛkt' : 'Yu nɔ dɛn kɔnɛkt'),
            ]),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                title: const Text('Rikod witin'),
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
                label: const Text('Sink Nau', style: TextStyle(fontSize: 18)),
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

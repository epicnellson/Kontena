import 'package:flutter/material.dart';
import 'package:kontena/l10n/app_localizations.dart';
import '../services/ble_service.dart';

class BleScreen extends StatefulWidget {
  const BleScreen({super.key});
  @override
  State<BleScreen> createState() => _BleScreenState();
}

class _BleScreenState extends State<BleScreen> {
  final _ble = BleService();
  final Map<String, String> _peers = {};
  bool _scanning = false;
  String _status = '';
  final Map<String, String> _syncResults = {};

  @override
  void initState() {
    super.initState();
    _ble.peersStream.listen((peers) {
      if (!mounted) return;
      setState(() => _peers
        ..clear()
        ..addAll(peers));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.isEmpty) {
      setState(() => _status = AppL10n.of(context)!.startScan);
    }
  }

  Future<void> _toggleScan() async {
    if (_scanning) {
      await _ble.stopDiscovery();
      setState(() { _scanning = false; _status = AppL10n.of(context)!.stopScan; });
    } else {
      setState(() { _scanning = true; _peers.clear(); _status = AppL10n.of(context)!.scanning; });
      await _ble.startDiscovery();
      setState(() { _scanning = false; _status = AppL10n.of(context)!.peersFound(_peers.length); });
    }
  }

  Future<void> _syncPeer(String deviceId, String name) async {
    setState(() => _syncResults[deviceId] = AppL10n.of(context)!.syncing);
    final result = await _ble.syncWithPeer(deviceId);
    if (!mounted) return;
    setState(() => _syncResults[deviceId] = result.success
        ? AppL10n.of(context)!.syncSuccess(result.pushed, result.pulled)
        : 'Ɛrɔ: ${result.error}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context)!.bleScreenTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(_status, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleScan,
                  icon: Icon(_scanning ? Icons.stop : Icons.bluetooth_searching),
                  label: Text(_scanning ? AppL10n.of(context)!.stopScan : AppL10n.of(context)!.startScan,
                      style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: _scanning ? Colors.red.shade700 : Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
          const Divider(),
          Expanded(
            child: _peers.isEmpty
                ? Center(child: Text(AppL10n.of(context)!.noPeersFound,
                    textAlign: TextAlign.center))
                : ListView(
                    children: _peers.entries.map((e) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.phone_android, color: Colors.blue),
                        title: Text(e.value.isEmpty ? e.key.substring(0, 8) : e.value),
                        subtitle: _syncResults[e.key] != null
                            ? Text(_syncResults[e.key]!)
                            : Text(AppL10n.of(context)!.readyToSync),
                        trailing: ElevatedButton(
                          onPressed: () => _syncPeer(e.key, e.value),
                          child: Text(AppL10n.of(context)!.syncButton),
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _ble.dispose(); super.dispose(); }
}

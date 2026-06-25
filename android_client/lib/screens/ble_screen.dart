import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  String _status = 'Tap fɔ luk mɔbail';
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

  Future<void> _toggleScan() async {
    if (_scanning) {
      await _ble.stopDiscovery();
      setState(() { _scanning = false; _status = 'Stɔp luk'; });
    } else {
      setState(() { _scanning = true; _peers.clear(); _status = 'Lukin fɔ mɔbail...'; });
      await _ble.startDiscovery();
      setState(() { _scanning = false; _status = '${_peers.length} mɔbail fayn'; });
    }
  }

  Future<void> _syncPeer(String deviceId, String name) async {
    setState(() => _syncResults[deviceId] = 'Sinkin...');
    final device = BluetoothDevice.fromId(deviceId);
    final result = await _ble.syncWithPeer(device);
    if (!mounted) return;
    setState(() => _syncResults[deviceId] = result.success
        ? '${result.pushed} push, ${result.pulled} pul ✓'
        : 'Ɛrɔ: ${result.error}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Mesh')),
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
                  label: Text(_scanning ? 'Stɔp' : 'Stat Luk',
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
                ? const Center(child: Text('Nɔ mɔbail fayn.\nMek sho BLE dɛn on.',
                    textAlign: TextAlign.center))
                : ListView(
                    children: _peers.entries.map((e) => Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.phone_android, color: Colors.blue),
                        title: Text(e.value.isEmpty ? e.key.substring(0, 8) : e.value),
                        subtitle: _syncResults[e.key] != null
                            ? Text(_syncResults[e.key]!)
                            : const Text('Redi fɔ sink'),
                        trailing: ElevatedButton(
                          onPressed: () => _syncPeer(e.key, e.value),
                          child: const Text('Sink'),
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

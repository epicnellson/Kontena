import 'package:flutter/material.dart';
import '../models/record.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'create_record_screen.dart';
import 'sync_screen.dart';
import 'ble_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});
  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _schemas = ['word', 'phrase', 'proverb'];
  final _labels  = ['Wod', 'Friez', 'Prɔvab'];
  List<List<Record>> _records = [[], [], []];
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait(
      _schemas.map((s) => DatabaseService.listBySchema(s)));
    final pending = await DatabaseService.pendingCount();
    if (!mounted) return;
    setState(() { _records = results; _pendingCount = pending; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kɔntena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BleScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SyncScreen(
                syncService: SyncService('http://YOUR_NGROK_OR_LAN_IP:8080'),
              ),
            )),
          ),
          if (_pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text('$_pendingCount witin',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.orange.shade700,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: List.generate(3, (i) => _buildList(_records[i])),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateRecordScreen()));
          _loadAll();
        },
      ),
    );
  }

  Widget _buildList(List<Record> records) {
    if (records.isEmpty) {
      return const Center(child: Text('Nɔ rikod yet.\nTap + fɔ kreat.',
          textAlign: TextAlign.center));
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (ctx, i) {
          final rec = records[i];
          return ListTile(
            title: Text(rec.payload),
            subtitle: Text(rec.deviceId,
                style: const TextStyle(fontSize: 11)),
            trailing: rec.isPending
                ? const Icon(Icons.circle, color: Colors.orange, size: 10)
                : const Icon(Icons.cloud_done, color: Colors.green, size: 16),
          );
        },
      ),
    );
  }
}

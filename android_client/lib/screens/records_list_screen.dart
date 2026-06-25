import 'package:flutter/material.dart';
import 'package:kontena/l10n/app_localizations.dart';
import '../models/record.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/tts_service.dart';
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
        title: Text(AppL10n.of(context)!.appTitle),
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
                label: Text(AppL10n.of(context)!.pendingCount(_pendingCount),
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.orange.shade700,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: _schemas.map((s) {
            switch (s) {
              case 'word': return Tab(text: AppL10n.of(context)!.wordSchema);
              case 'phrase': return Tab(text: AppL10n.of(context)!.phraseSchema);
              case 'proverb': return Tab(text: AppL10n.of(context)!.proverbSchema);
              default: return Tab(text: s);
            }
          }).toList(),
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
      return Center(
          child: Text(AppL10n.of(context)!.noRecordsYet,
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20,
                      color: Colors.blueGrey),
                  onPressed: () => TtsService.speak(rec.payload),
                ),
                Icon(
                  rec.isPending ? Icons.circle : Icons.cloud_done,
                  color: rec.isPending ? Colors.orange : Colors.green,
                  size: rec.isPending ? 10 : 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

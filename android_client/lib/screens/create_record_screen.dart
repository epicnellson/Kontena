import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';
import '../services/database_service.dart';

class CreateRecordScreen extends StatefulWidget {
  const CreateRecordScreen({super.key});
  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _payloadCtrl = TextEditingController();
  String _schema = 'word';
  bool _saving = false;

  final _schemas = ['word', 'phrase', 'proverb'];

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_id');
    if (id == null) {
      id = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', id);
    }
    return id;
  }

  Future<void> _save() async {
    final text = _payloadCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rayt somtin fɔs!')));
      return;
    }
    setState(() => _saving = true);
    final deviceId = await _getDeviceId();
    final record = Record(
      schema: _schema,
      langCode: 'kri',
      payload: text,
      deviceId: deviceId,
      isPending: true,
    );
    await DatabaseService.upsertRecord(record);
    setState(() { _saving = false; _payloadCtrl.clear(); });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sev don! ✓'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kreat Rikod')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Kayn Rikod', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _schema,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _schemas.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s == 'word' ? 'Wod' : s == 'phrase' ? 'Friez' : 'Prɔvab'),
              )).toList(),
              onChanged: (v) => setState(() => _schema = v!),
            ),
            const SizedBox(height: 16),
            const Text('Wɛtin yu wan sev?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _payloadCtrl,
              decoration: const InputDecoration(
                hintText: 'Rayt wod ɔ friez ya...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sev', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

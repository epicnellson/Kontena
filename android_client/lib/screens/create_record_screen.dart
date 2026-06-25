import 'package:flutter/material.dart';
import 'package:kontena/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';
import '../services/database_service.dart';
import '../services/voice_service.dart';

class CreateRecordScreen extends StatefulWidget {
  const CreateRecordScreen({super.key});
  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _payloadCtrl = TextEditingController();
  String _schema = 'word';
  bool _saving = false;
  bool _listening = false;

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

  String _schemaLabel(String s) {
    switch (s) {
      case 'word': return AppL10n.of(context)!.wordSchema;
      case 'phrase': return AppL10n.of(context)!.phraseSchema;
      case 'proverb': return AppL10n.of(context)!.proverbSchema;
      default: return s;
    }
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
      SnackBar(
        content: Text(AppL10n.of(context)!.savedSuccess),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _startListening() async {
    setState(() => _listening = true);
    final text = await VoiceService.listen();
    setState(() { _listening = false; });
    if (text.isNotEmpty) _payloadCtrl.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppL10n.of(context)!.createRecord)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppL10n.of(context)!.recordType,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _schema,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _schemas.map((s) => DropdownMenuItem(
                value: s,
                child: Text(_schemaLabel(s)),
              )).toList(),
              onChanged: (v) => setState(() => _schema = v!),
            ),
            const SizedBox(height: 16),
            Text(AppL10n.of(context)!.whatToSave,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _payloadCtrl,
                    decoration: InputDecoration(
                      hintText: AppL10n.of(context)!.typeHere,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.mic),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                          backgroundColor: _listening
                              ? Colors.red.shade700
                              : Colors.green.shade700),
                      onPressed: _listening ? null : _startListening,
                    ),
                    Text(_listening ? '...' : AppL10n.of(context)!.listenButton,
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
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
                  : Text(AppL10n.of(context)!.saveButton,
                      style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

class VoiceService {
  static final _vosk = VoskFlutterPlugin.instance();
  static Model? _model;
  static bool _loading = false;

  static Future<void> init() async {
    if (_model != null || _loading) return;
    _loading = true;
    _model = await _vosk.createModel(
        'assets/models/vosk-model-small-en-us-0.15');
    _loading = false;
  }

  static Future<String> listen({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final granted = await Permission.microphone.request();
    if (!granted.isGranted) return '';

    await init();
    if (_model == null) return '';

    final recognizer = await _vosk.createRecognizer(
        model: _model!, sampleRate: 16000);

    final recorder = AudioRecorder();
    final stream = await recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final completer = Completer<String>();
    StreamSubscription? sub;

    sub = stream.listen((chunk) async {
      final isFinal = await recognizer.acceptWaveformBytes(chunk);
      if (isFinal && !completer.isCompleted) {
        final text = await recognizer.getResult();
        completer.complete(_parseResult(text));
        sub?.cancel();
        await recorder.stop();
        recognizer.dispose();
      }
    });

    Future.delayed(timeout, () async {
      if (!completer.isCompleted) {
        sub?.cancel();
        await recorder.stop();
        final text = await recognizer.getFinalResult();
        recognizer.dispose();
        completer.complete(_parseResult(text));
      }
    });

    return completer.future;
  }

  static String _parseResult(String json) {
    try {
      final match = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(json);
      return match?.group(1) ?? '';
    } catch (_) {
      return '';
    }
  }
}

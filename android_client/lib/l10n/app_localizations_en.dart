// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kɔntena';

  @override
  String get createRecord => 'Kreat Rikod';

  @override
  String get saveButton => 'Sev';

  @override
  String get syncNow => 'Sink Nau';

  @override
  String get wordSchema => 'Wod';

  @override
  String get phraseSchema => 'Friez';

  @override
  String get proverbSchema => 'Prɔvab';

  @override
  String get offlineBadge => 'Yu nɔ dɛn kɔnɛkt';

  @override
  String get onlineBadge => 'Yu kɔnɛkt';

  @override
  String pendingCount(int count) {
    return '$count rikod witin';
  }

  @override
  String peerFound(String name) {
    return 'Mɔbail fayn: $name';
  }

  @override
  String get savedSuccess => 'Sev don! ✓';

  @override
  String syncSuccess(int pushed, int pulled) {
    return '$pushed push  $pulled pul';
  }

  @override
  String get noRecordsYet => 'Nɔ rikod yet.\nTap + fɔ kreat.';

  @override
  String get bleScreenTitle => 'BLE Mesh';

  @override
  String get startScan => 'Stat Luk';

  @override
  String get stopScan => 'Stɔp';

  @override
  String get noPeersFound => 'Nɔ mɔbail fayn.\nMek sho BLE dɛn on.';

  @override
  String get syncButton => 'Sink';

  @override
  String get scanning => 'Lukin fɔ mɔbail...';

  @override
  String peersFound(int count) {
    return '$count mɔbail fayn';
  }

  @override
  String get typeHere => 'Rayt wod ɔ friez ya...';

  @override
  String get recordType => 'Kayn Rikod';

  @override
  String get whatToSave => 'Wɛtin yu wan sev?';

  @override
  String get speakNow => 'Tɔk nau...';

  @override
  String get listenButton => 'Yɛri';

  @override
  String get syncTitle => 'Sink';

  @override
  String get readyToSync => 'Redi fɔ sink';

  @override
  String get pendingRecords => 'Rikod witin';

  @override
  String get syncing => 'Sinkin...';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n? of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n);
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Kɔntena'**
  String get appTitle;

  /// No description provided for @createRecord.
  ///
  /// In en, this message translates to:
  /// **'Kreat Rikod'**
  String get createRecord;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Sev'**
  String get saveButton;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sink Nau'**
  String get syncNow;

  /// No description provided for @wordSchema.
  ///
  /// In en, this message translates to:
  /// **'Wod'**
  String get wordSchema;

  /// No description provided for @phraseSchema.
  ///
  /// In en, this message translates to:
  /// **'Friez'**
  String get phraseSchema;

  /// No description provided for @proverbSchema.
  ///
  /// In en, this message translates to:
  /// **'Prɔvab'**
  String get proverbSchema;

  /// No description provided for @offlineBadge.
  ///
  /// In en, this message translates to:
  /// **'Yu nɔ dɛn kɔnɛkt'**
  String get offlineBadge;

  /// No description provided for @onlineBadge.
  ///
  /// In en, this message translates to:
  /// **'Yu kɔnɛkt'**
  String get onlineBadge;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rikod witin'**
  String pendingCount(int count);

  /// No description provided for @peerFound.
  ///
  /// In en, this message translates to:
  /// **'Mɔbail fayn: {name}'**
  String peerFound(String name);

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sev don! ✓'**
  String get savedSuccess;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'{pushed} push  {pulled} pul'**
  String syncSuccess(int pushed, int pulled);

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'Nɔ rikod yet.\nTap + fɔ kreat.'**
  String get noRecordsYet;

  /// No description provided for @bleScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'BLE Mesh'**
  String get bleScreenTitle;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Stat Luk'**
  String get startScan;

  /// No description provided for @stopScan.
  ///
  /// In en, this message translates to:
  /// **'Stɔp'**
  String get stopScan;

  /// No description provided for @noPeersFound.
  ///
  /// In en, this message translates to:
  /// **'Nɔ mɔbail fayn.\nMek sho BLE dɛn on.'**
  String get noPeersFound;

  /// No description provided for @syncButton.
  ///
  /// In en, this message translates to:
  /// **'Sink'**
  String get syncButton;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Lukin fɔ mɔbail...'**
  String get scanning;

  /// No description provided for @peersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} mɔbail fayn'**
  String peersFound(int count);

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Rayt wod ɔ friez ya...'**
  String get typeHere;

  /// No description provided for @recordType.
  ///
  /// In en, this message translates to:
  /// **'Kayn Rikod'**
  String get recordType;

  /// No description provided for @whatToSave.
  ///
  /// In en, this message translates to:
  /// **'Wɛtin yu wan sev?'**
  String get whatToSave;

  /// No description provided for @speakNow.
  ///
  /// In en, this message translates to:
  /// **'Tɔk nau...'**
  String get speakNow;

  /// No description provided for @listenButton.
  ///
  /// In en, this message translates to:
  /// **'Yɛri'**
  String get listenButton;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sink'**
  String get syncTitle;

  /// No description provided for @readyToSync.
  ///
  /// In en, this message translates to:
  /// **'Redi fɔ sink'**
  String get readyToSync;

  /// No description provided for @pendingRecords.
  ///
  /// In en, this message translates to:
  /// **'Rikod witin'**
  String get pendingRecords;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Sinkin...'**
  String get syncing;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

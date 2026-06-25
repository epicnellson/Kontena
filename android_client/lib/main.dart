import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/records_list_screen.dart';

void main() => runApp(const KontenaApp());

class KontenaApp extends StatelessWidget {
  const KontenaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kɔntena',
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade800),
        useMaterial3: true,
      ),
      home: const RecordsListScreen(),
    );
  }
}

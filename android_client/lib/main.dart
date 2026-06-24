import 'package:flutter/material.dart';
import 'screens/records_list_screen.dart';

void main() => runApp(const KontenaApp());

class KontenaApp extends StatelessWidget {
  const KontenaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kɔntena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade800),
        useMaterial3: true,
      ),
      home: const RecordsListScreen(),
    );
  }
}

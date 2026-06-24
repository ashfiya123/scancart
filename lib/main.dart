import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ScanCartApp());
}

class ScanCartApp extends StatelessWidget {
  const ScanCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanCart',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

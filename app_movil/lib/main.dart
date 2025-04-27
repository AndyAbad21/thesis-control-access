import 'package:flutter/material.dart';
import 'pages/biometric_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Acceso UPS',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BiometricPage(),
    );
  }
}

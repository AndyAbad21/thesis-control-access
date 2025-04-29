import 'package:flutter/material.dart';
import 'pages/biometric_page.dart';
import 'pages/splash_screen.dart';
import 'pages/login_screen.dart';
import 'pages/home_screen.dart';
import 'pages/config_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acceso UPS',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/biometric': (context) => const BiometricPage(), 
        '/home': (context) => const HomeScreen(),
        '/config': (context) => const ConfigScreen(),
      },
    );
  }
}

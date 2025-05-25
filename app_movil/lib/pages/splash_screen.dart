import 'package:flutter/material.dart';
import 'dart:async'; // Para usar Future.delayed

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simula tiempo de carga de la app
    Future.delayed(const Duration(seconds: 0), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Stack(
        children: [
          // Rombito azul
          Positioned(
            top: -100,
            left: -250,
            child: Transform.rotate(
              angle: 0.785398, // 45 grados en radianes
              child: Container(
                width: 508,
                height: 340,
                color: Color(0xFF013B72),
              ),
            ),
          ),
          // Semicírculo azul
          Positioned(
            bottom: -60,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFF013B72),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Contenido prin0xcipal (Logos)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 300
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [// ⬅️ Empuja todo 150 píxeles hacia abajo
                  // Logo UPS
                  Image.asset('assets/logo_ups.png', width: 270),
                  const SizedBox(height: 60),
                  // Icono de grupo
                  Image.asset('assets/logo_grupo.png', width: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

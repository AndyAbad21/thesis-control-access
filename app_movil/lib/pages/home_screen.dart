import 'package:app_movil/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../services/secure_storage_service.dart';
import '../services/access_controller_service.dart';
import 'config_screen.dart';

import '../widgets/key_button.dart';
import '../widgets/user_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nombres = '';
  String apellidos = '';

  double progress = 1.0;
  Timer? countdownTimer;
  bool isCounting = false;
  static int totalSeconds = AccessControllerService.time;
  int secondsLeft = totalSeconds;
  bool _isConfigOpen = false;
  bool isValidating = false;
  Color circleColor = const Color(0xFFFEC455);

  @override
  void initState() {
    super.initState();
    _loadUserData();

    OtpService.keyExpiredNotifier.addListener(() {
      if (OtpService.keyExpiredNotifier.value) {
        countdownTimer?.cancel();
        setState(() {
          isCounting = false;
          progress = 0.0;
          secondsLeft = totalSeconds;
          circleColor = Colors.red;
        });
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            circleColor = const Color(0xFFFEC455);
          });
        });
        OtpService.keyExpiredNotifier.value = false;
      }
    });
  }

  Future<void> _loadUserData() async {
    final n = await SecureStorageService.obtenerValor('nombres');
    final a = await SecureStorageService.obtenerValor('apellidos');

    setState(() {
      nombres = n ?? 'Nombre';
      apellidos = a ?? 'Apellido';
    });
  }

  void startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      progress = 1.0;
      secondsLeft = totalSeconds;
      isCounting = true;
      circleColor = const Color(0xFFFEC455);
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        progress -= 1 / (totalSeconds * 10);
        if (timer.tick % 10 == 0) {
          secondsLeft--;
        }
      });

      if (progress <= 0) {
        countdownTimer?.cancel();
        setState(() {
          isCounting = false;
          secondsLeft = totalSeconds;
          circleColor = Colors.red;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                'Key expired!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            circleColor = const Color(0xFFFEC455);
          });
        });
      }
    });
  }

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo azul con rotación
          Positioned(
            top: -100,
            left: -250,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(width: 508, height: 340, color: const Color(0xFF013B72)),
            ),
          ),

          // Botón menú configuración
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 40),
              onPressed: () {
                setState(() => _isConfigOpen = true);

                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                  barrierLabel: 'ConfigScreen',
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, __, ___) => const ConfigScreen(),
                  transitionBuilder: (_, animation, __, child) {
                    final tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
                    return SlideTransition(
                      position: tween.animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                      child: child,
                    );
                  },
                ).then((_) => setState(() => _isConfigOpen = false));
              },
            ),
          ),

          // Nombres y apellidos
          Positioned(top: 125, left: 35, child: UserHeader(nombres: nombres, apellidos: apellidos)),

          // Logo UPS en opacidad
          Positioned(
            top: 200,
            right: -60,
            child: AnimatedOpacity(
              opacity: _isConfigOpen ? 0.0 : 0.2,
              duration: const Duration(milliseconds: 500),
              child: Image.asset('assets/logo_ups_unico.png', width: 250),
            ),
          ),

          // Texto central con tiempo o estado
          Align(
            alignment: const Alignment(0, 0.12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCounting ? 'Expire in:' : 'Generate key',
                  style: const TextStyle(color: Color.fromARGB(157, 1, 59, 114), fontSize: 28, fontWeight: FontWeight.bold),
                ),
                if (isCounting)
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(formatTime(secondsLeft),
                        style: const TextStyle(color: Color(0xFF013B72), fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                if (isValidating)
                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text('Validando...',
                        style: TextStyle(color: Color(0xFF013B72), fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Botón circular para generar/verificar OTP
          Align(
            alignment: const Alignment(0, 0.66),
            child: KeyButton(
              progress: progress,
              isCounting: isCounting,
              circleColor: circleColor,
              onTap: () async {
                setState(() {
                  isValidating = true;
                  circleColor = Colors.green;
                });

                final result = await AccessControllerService.verificarAccesoYGenerarOTP();

                countdownTimer?.cancel();

                setState(() {
                  isCounting = false;
                  secondsLeft = totalSeconds;
                });

                if (result["success"]) {
                  startCountdown();
                  setState(() {
                    progress = 0.0;
                    secondsLeft = totalSeconds;
                    circleColor = Colors.red;
                  });
                } else {
                  setState(() {
                    isCounting = false;
                    progress = 0.0;
                    secondsLeft = totalSeconds;
                    circleColor = Colors.red;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result["message"] ?? "❌ OTP rechazada", textAlign: TextAlign.center),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      circleColor = const Color(0xFFFEC455);
                    });
                  });
                }
                setState(() {
                  isValidating = false;
                  circleColor = const Color(0xFFFEC455);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

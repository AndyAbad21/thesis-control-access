import 'package:flutter/material.dart';
import 'dart:async'; // Para controlar el timer
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double progress = 1.0;
  Timer? countdownTimer;
  bool isCounting = false;
  static const int totalSeconds = 5; // Cambia a 300 para 5 minutos reales
  int secondsLeft = totalSeconds;
  bool _isConfigOpen = false;

  void startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      progress = 1.0;
      secondsLeft = totalSeconds;
      isCounting = true;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        progress -= 1 / (totalSeconds * 10);

        // Actualiza los segundos faltantes cada 1 segundo exacto
        if (timer.tick % 10 == 0) {
          secondsLeft--;
        }
      });

      if (progress <= 0) {
        countdownTimer?.cancel();
        setState(() {
          isCounting = false;
          secondsLeft = totalSeconds;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                'Key expired!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            backgroundColor: Color(0xFF013B72),
            // behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
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
          // 🔷 Rombito azul
          Positioned(
            top: -100,
            left: -250,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 508,
                height: 340,
                color: const Color(0xFF013B72),
              ),
            ),
          ),

          // 🔷 Icono menú
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 40),
              onPressed: () {
                setState(() {
                  _isConfigOpen = true; // 🔥 Oculta el logo
                });

                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.transparent,
                  barrierLabel: 'ConfigScreen',
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const ConfigScreen();
                  },
                  transitionBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    final tween = Tween(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    );
                    return SlideTransition(
                      position: tween.animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: child,
                    );
                  },
                ).then((_) {
                  // 🔥 Cuando cierran el panel, vuelve a mostrar el logo
                  setState(() {
                    _isConfigOpen = false;
                  });
                });
              },
            ),
          ),

          // 🔷 Nombre del usuario
          Positioned(
            top: 125,
            left: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Andy Fabricio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Text(
                  'Abad Freire',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
          ),

          // 🔷 Logo semi-transparente
          Positioned(
            top: 200,
            right: -60,
            child: AnimatedOpacity(
              opacity:
                  _isConfigOpen
                      ? 0.0
                      : 0.2, // 🔥 Si configuración abierta, se desvanece
              duration: const Duration(
                milliseconds: 500,
              ), // Tiempo de desvanecimiento
              child: Image.asset('assets/logo_ups_unico.png', width: 250),
            ),
          ),

          // 🔷 Texto dinámico: "Generate Key" o "Expire in" + contador
          Align(
            alignment: const Alignment(0, 0.12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCounting ? 'Expire in:' : 'Generate key',
                  style: TextStyle(
                    color: Color.fromARGB(157, 1, 59, 114),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCounting)
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      formatTime(secondsLeft),
                      style: const TextStyle(
                        color: Color(0xFF013B72),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 🔷 Botón circular animado
          Align(
            alignment: const Alignment(0, 0.66),
            child: GestureDetector(
              onTap: () {
                startCountdown();
              },
              child: CustomPaint(
                painter: KeyButtonPainter(progress, isCounting),
                child: Container(
                  width: 175,
                  height: 175,
                  alignment: Alignment.center,
                  child: Image.asset('assets/key.png', width: 150),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 Pintor del botón
class KeyButtonPainter extends CustomPainter {
  final double progress;
  final bool isCounting;

  KeyButtonPainter(this.progress, this.isCounting);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;

    // 🔵 Círculo azul exterior (borde)
    Paint outerCircle =
        Paint()
          ..color = const Color(0xFF013B72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 70;

    canvas.drawCircle(Offset(radius, radius), radius - 1, outerCircle);

    if (!isCounting) {
      // Estado inactivo: todo blanco
      Paint fullWhite =
          Paint()
            ..color = Color(0xFFFEC455)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 70;

      canvas.drawCircle(Offset(radius, radius), radius - 20, fullWhite);
    } else {
      // 🟡 Estado activo: blanco + amarillo
      Paint passedArc =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 70;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 20),
        -90 * 0.0174533,
        -360 * (1 - progress) * 0.0174533,
        false,
        passedArc,
      );

      Paint remainingArc =
          Paint()
            ..color = const Color(0xFFFEC455)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 70;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 20),
        (-90 + 360 * progress) * 0.0174533,
        -360 * progress * 0.0174533,
        false,
        remainingArc,
      );
    }

    // 🔵 Círculo interno azul relleno
    Paint innerCircle =
        Paint()
          ..color = const Color(0xFF013B72)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, innerCircle);
  }

  @override
  bool shouldRepaint(covariant KeyButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCounting != isCounting;
  }
}

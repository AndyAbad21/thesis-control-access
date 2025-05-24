import 'package:app_movil/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Para controlar el timer
import 'config_screen.dart';
import '../services/access_controller_service.dart'; // Importa el orquestador

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double progress = 1.0;
  Timer? countdownTimer;
  bool isCounting = false;
  static int totalSeconds =
      AccessControllerService.time; // Cambia a 300 para 5 minutos reales
  int secondsLeft = totalSeconds;
  bool _isConfigOpen = false;
  bool isValidating = false;
  Color circleColor = const Color(0xFFFEC455); // Color por defecto del círculo

  @override
  void initState() {
    super.initState();

    OtpService.keyExpiredNotifier.addListener(() {
      debugPrint("📢 Notificador escuchado en HomeScreen");

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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );

        // Cambiar el color a rojo cuando expire
        setState(() {
          circleColor = Colors.red; // Color rojo
        });

        // Restaurar el color original después de que el SnackBar desaparezca
        Future.delayed(const Duration(milliseconds: 1500), () {
          setState(() {
            circleColor = const Color(0xFFFEC455); // Color original
          });
        });
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
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 40),
              onPressed: () {
                setState(() {
                  _isConfigOpen = true;
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
                  setState(() {
                    _isConfigOpen = false;
                  });
                });
              },
            ),
          ),
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
          Positioned(
            top: 200,
            right: -60,
            child: AnimatedOpacity(
              opacity: _isConfigOpen ? 0.0 : 0.2,
              duration: const Duration(milliseconds: 500),
              child: Image.asset('assets/logo_ups_unico.png', width: 250),
            ),
          ),
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
                if (isValidating)
                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Text(
                      'Validando...',
                      style: TextStyle(
                        color: Color(0xFF013B72),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.66),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  isValidating = true; // Mostrar mensaje "Validando..."
                  circleColor = Colors.green;
                });
                // Llamamos a la función para verificar el acceso y generar la OTP
                final result =
                    await AccessControllerService.verificarAccesoYGenerarOTP();

                // Siempre detener cualquier temporizador anterior antes de continuar
                countdownTimer?.cancel();

                setState(() {
                  isCounting = false;
                  secondsLeft = totalSeconds;
                });

                if (result["success"]) {
                  // Si fue exitoso, iniciar el temporizador
                  startCountdown();
                  setState(() {
                    isCounting = false;
                    progress = 0.0; // 👈 Esto es clave
                    secondsLeft = totalSeconds;
                    circleColor = Colors.red;
                  });
                } else {
                  // Si hubo un error, detener el temporizador si está corriendo
                  countdownTimer?.cancel();
                  setState(() {
                    isCounting = false;
                    progress = 0.0; // 👈 Esto es clave
                    secondsLeft = totalSeconds;
                    circleColor = Colors.red; // Color rojo para denegado
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result["message"] ?? "❌ OTP rechazada",
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Restaurar color original después de mostrar el mensaje
                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      circleColor = const Color(
                        0xFFFEC455,
                      ); // Color original del botón
                    });
                  });
                }
                setState(() {
                  isValidating =
                      false; // Ocultar mensaje "Validando..." cuando termine
                  circleColor = const Color(0xFFFEC455);
                });
              },
              child: CustomPaint(
                painter: KeyButtonPainter(progress, isCounting, circleColor),
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

class KeyButtonPainter extends CustomPainter {
  final double progress;
  final bool isCounting;
  final Color circleColor; // Agregamos el color como parámetro

  KeyButtonPainter(this.progress, this.isCounting, this.circleColor);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;

    Paint outerCircle =
        Paint()
          ..color = const Color(0xFF013B72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 70;

    canvas.drawCircle(Offset(radius, radius), radius - 1, outerCircle);

    if (!isCounting) {
      Paint fullWhite =
          Paint()
            ..color =
                circleColor // Usamos el color que se pasa como parámetro
            ..style = PaintingStyle.stroke
            ..strokeWidth = 70;

      canvas.drawCircle(Offset(radius, radius), radius - 20, fullWhite);
    } else {
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
            ..color =
                circleColor // Usamos el color que se pasa como parámetro
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

    Paint innerCircle =
        Paint()
          ..color = const Color(0xFF013B72)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, innerCircle);
  }

  @override
  bool shouldRepaint(covariant KeyButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCounting != isCounting ||
        oldDelegate.circleColor != circleColor;
  }
}

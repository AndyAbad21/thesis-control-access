import 'package:otp/otp.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';

class OtpService {
  // --- VARIABLES SEGURAS ---
  static const int _time = 10; // 5 minutos = 300 segundos
  static String? _currentOtp;
  static Timer? _otpTimer;
  static Timer? _countdownTimer; // 🔥 Timer para actualizar el contador
  static int _timeLeft = _time;  // 🔥 Segundos restantes
  static final ValueNotifier<int> timeNotifier = ValueNotifier<int>(_time); // 🔥 Notificador para actualizar UI

  // Método para generar y mostrar OTP
  static Future<void> generateAndShowOTP(BuildContext context) async {
    // Cancelar timers anteriores si existen
    _otpTimer?.cancel();
    _countdownTimer?.cancel();

    // Resetear tiempo
    _timeLeft = _time;
    timeNotifier.value = _timeLeft;

    await SecureStorageService.guardarSecretoOTP('JBSWY3DPEHPK3PXP'); //Guardar el secret en el secure storage

    // Obtener el secreto dinámicamente desde almacenamiento seguro
    String? secret = await SecureStorageService.obtenerSecretoOTP(); // Obtener el secret del secure storage

    if (secret == null || secret.isEmpty) {
      debugPrint('❌ Error: No se encontró o está vacío el secreto para generar OTP.');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de Seguridad'),
          content: const Text(
              'No se encontró tu clave secreta para generar la llave de acceso. '
              'Por favor reinstala la app o contacta a soporte técnico.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Generar el código TOTP usando el secreto
    String totp = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: _time,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    _currentOtp = totp;

    debugPrint('✅ La OTP se generó correctamente con un tiempo válido de $_time segundos.');

    // Mostrar la OTP en un cuadro de diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Llave Temporal Generada'),
        content: ValueListenableBuilder<int>(
  valueListenable: timeNotifier,
  builder: (context, tiempoRestante, _) {
    final minutos = (tiempoRestante ~/ 60).toString().padLeft(2, '0');
    final segundos = (tiempoRestante % 60).toString().padLeft(2, '0');
    
    double progreso = tiempoRestante / OtpService._time; // 🔥 Cálculo de progreso
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: progreso, // 🔥 Progreso entre 0.0 - 1.0
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            Text(
              "$minutos:$segundos",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Tu OTP es: $totp',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  },
),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // --- Timers para expirar y actualizar contador ---

    // Timer para cuando expire completamente
    _otpTimer = Timer(Duration(seconds: _time), () {
      _currentOtp = null;
      _countdownTimer?.cancel();
      debugPrint('⚠️ La OTP ha expirado automáticamente después de $_time segundos.');
    });

    // Timer para ir actualizando cada segundo
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        _timeLeft--;
        timeNotifier.value = _timeLeft;
      }
    });
  }
}

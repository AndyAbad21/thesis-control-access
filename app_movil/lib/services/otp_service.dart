import 'package:otp/otp.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class OtpService {
  // --- VARIABLES SEGURAS (inmutables y protegidas) ---
  static const String _secret = 'JBSWY3DPEHPK3PXP';
  static const int _time = 300; // 5 minutos = 300 segundos

  static String? _currentOtp;
  static Timer? _otpTimer;

  // Método para generar y mostrar OTP
  static Future<void> generateAndShowOTP(BuildContext context) async {
    // Cancelar un timer anterior si existe
    _otpTimer?.cancel();

    // Generar el código TOTP
    String totp = OTP.generateTOTPCodeString(
      _secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: _time,
      length: 12,
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
        content: Text('Tu OTP es: $totp\n\n¡Expira en $_time segundos!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Programar la expiración automática
    _otpTimer = Timer(const Duration(seconds: _time), () {
      _currentOtp = null;
      debugPrint('⚠️ La OTP ha expirado automáticamente después de $_time segundos.');
    });
  }
}

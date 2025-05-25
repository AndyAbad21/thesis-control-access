import 'package:app_movil/services/access_controller_service.dart';
import 'package:otp/otp.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';

class OtpService {
  static String? _currentOtp;
  static Timer? _otpTimer;
  static Timer? _countdownTimer;
  static int _timeLeft = 0;
  static final ValueNotifier<int> timeNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> keyExpiredNotifier = ValueNotifier<bool>(
    false,
  );

  // Método para generar OTP y tomar el tiempo de expiración del backend
  static Future<Map<String, dynamic>> generateOTP(int expirationTime) async {
    // Cancelar timers anteriores si existen
    _otpTimer?.cancel();
    _countdownTimer?.cancel();

    // Resetear tiempo
    _timeLeft = expirationTime;
    timeNotifier.value = _timeLeft;

    // Obtener el secreto desde el almacenamiento seguro
    String? secret = await SecureStorageService.obtenerSecretoOTP();

    if (secret == null || secret.isEmpty) {
      debugPrint(
        '❌ Error: No se encontró o está vacío el secreto para generar OTP.',
      );
      return {
        "success": false,
        "message": "❌ Error: No se encontró el secreto.",
      }; // Si no se encuentra el secreto, retorna false
    }

    // Generar el código TOTP usando el secreto
    String totp = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: expirationTime,
      length: 10,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    if (totp.isEmpty) {
      debugPrint('❌ Error: No se pudo generar la OTP.');
      return {
        "success": false,
        "message": "❌ Error al generar la OTP.",
      }; // Si no se pudo generar la OTP, retorna false
    }

    _currentOtp = totp;

    debugPrint(
      '✅ La OTP se generó correctamente con un tiempo válido de $expirationTime segundos. Llave: $_currentOtp',
    );

    // --- Timers para expirar y actualizar contador ---
    // Timer para cuando expire completamente
    _otpTimer = Timer(Duration(seconds: expirationTime), () {
      notifyExpiration(); // ✅ esto es lo que envía el evento al ValueNotifier
    });

    // Timer para ir actualizando cada segundo
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeLeft > 0) {
        _timeLeft--;
        timeNotifier.value = _timeLeft;
      }
    });

    return {
      "success": true,
      "message": "✅ OTP generada correctamente.",
      "otp": totp,
    };
  }

  static void notifyExpiration() {
    _otpTimer?.cancel();
    _countdownTimer?.cancel();
    _currentOtp = null;
    _timeLeft = 0;
    timeNotifier.value = 0;

    debugPrint(
      "⚠️ La OTP fue forzada a expirar (rechazada o expiró por tiempo).",
    );
    keyExpiredNotifier.value = true; // ✅ muy importante
    AccessControllerService.notifyKeyExpired();
  }
}

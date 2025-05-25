import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'location_service.dart';
import 'otp_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // Importar para Secure Storage

class AccessControllerService {
  static bool isKeyActive = false;
  static const double _maxAllowed = 10000.0;
  static const int _time = 15;

  static int get time => _time;

  // Crear instancia del almacenamiento seguro
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Función para recuperar el usuario_id desde el almacenamiento seguro
  static Future<String?> obtenerUsuarioId() async {
    return await _secureStorage.read(key: 'usuario_id');
  }

  static Future<Map<String, dynamic>> verificarAccesoYGenerarOTP() async {
    if (isKeyActive) {
      return {
        "success": false,
        "message": "❌ Ya hay una llave activa. Espera a que expire.",
      };
    }

    // Autenticación del usuario
    bool autenticado = await AuthService.authenticate();
    if (!autenticado) {
      return {"success": false, "message": "❌ Autenticación fallida."};
    }

    // Obtener la ubicación del usuario
    Position? position = await LocationService.getCurrentLocation();
    if (position == null) {
      return {
        "success": false,
        "message": "❌ No se pudo obtener ubicación o permisos denegados.",
      };
    }

    // Calcular la distancia mínima
    final resultado = LocationService.calcularDistanciaMinima(position);
    double distanciaMinima = resultado['distancia'];
    if (distanciaMinima > _maxAllowed) {
      return {
        "success": false,
        "message":
            "❌ Estás fuera del rango permitido.\nPunto más cercano: ${distanciaMinima.toStringAsFixed(2)} metros.",
      };
    }

    // Generar OTP
    var otpResultado = await OtpService.generateOTP(_time);
    if (!otpResultado["success"]) {
      isKeyActive = false; // Desbloquear la creación de una nueva llave
      return {"success": false, "message": otpResultado["message"]};
    }

    String otp = otpResultado["otp"];
    isKeyActive = true;

    // Obtener el usuario_id desde el almacenamiento seguro
    String? usuarioId = await obtenerUsuarioId();
    if (usuarioId == null || usuarioId.isEmpty) {
      return {
        "success": false,
        "message": "❌ No se encontró el usuario ID en el almacenamiento.",
      };
    }

    // Enviar OTP al backend directamente por Wi-Fi (HTTP POST)
    final response = await http.post(
      Uri.parse("http://192.168.1.123/recibir-otp"), // Reemplaza con tu IP
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "llave": otp,
        "usuario_id": usuarioId,  // Usar el usuario_id recuperado del storage
      }),
    );

    final decoded = jsonDecode(response.body);
    debugPrint("📡 Respuesta recibida del ESP32: ${response.body}");
    bool autorizado = decoded["estado"] == "autorizado";

    if (!autorizado) {
      isKeyActive = false; // Marcar la llave como inactiva si fue rechazada
      OtpService.notifyExpiration();
    } else {
      OtpService.notifyExpiration(); // Detener timer visual cuando ESP32 responde
    }

    return {
      "success": autorizado,
      "message":
          autorizado
              ? "✅ Acceso autorizado por ESP32."
              : "❌ OTP inválida o acceso denegado.",
    };
  }

  static void notifyKeyExpired() {
    isKeyActive = false;
    print("La OTP ha expirado, ahora se puede generar una nueva.");
  }
}

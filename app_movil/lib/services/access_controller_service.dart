//--------------------------//
// Orquestador de servicios //
//--------------------------//

// lib/services/access_controller_service.dart
import 'package:geolocator/geolocator.dart';

// Servicios existentes
import 'location_service.dart';
import 'auth_service.dart';
import 'otp_service.dart';

class AccessControllerService {
  static bool isKeyActive = false; // Variable para saber si la llave está activa
  static const double _maxAllowed = 10000.0;
  static const int _time = 10; // Control del tiempo de expiración de la llave

  static int get time => _time;

  static Future<Map<String, dynamic>> verificarAccesoYGenerarOTP() async {
    // Comprobar si ya hay una llave activa
    if (isKeyActive) {
      return {"success": false, "message": "❌ Ya hay una llave activa. Espera a que expire."};
    }

    // Paso 3: Autenticación biométrica
    bool autenticado = await AuthService.authenticate();
    if (!autenticado) {
      return {"success": false, "message": "❌ Autenticación fallida."};
    }

    // Paso 1: Obtener ubicación
    Position? position = await LocationService.getCurrentLocation();
    if (position == null) {
      return {"success": false, "message": "❌ No se pudo obtener ubicación o permisos denegados."};
    }

    // Paso 2: Calcular distancia
    final resultado = LocationService.calcularDistanciaMinima(position);
    double distanciaMinima = resultado['distancia'];
    if (distanciaMinima > _maxAllowed) {
      return {"success": false, "message": "❌ Estás fuera del rango permitido.\nPunto más cercano: ${distanciaMinima.toStringAsFixed(2)} metros."};
    }

    // Paso 4: Generar OTP
    bool otpGenerado = await OtpService.generateOTP(_time);
    if (!otpGenerado) {
      return {"success": false, "message": "❌ Error al generar la OTP."};
    }

    isKeyActive = true; // Bloquear la creación de una nueva llave
    return {"success": true, "message": "✅ OTP generada correctamente."};
  }

  // Método para notificar que la OTP ha expirado
  static void notifyKeyExpired() {
    isKeyActive = false;
    print("La OTP ha expirado, ahora se puede generar una nueva.");
  }
}

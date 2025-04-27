import 'package:flutter/material.dart';
// Importar los servicios
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/otp_service.dart';

import 'package:geolocator/geolocator.dart'; // Importación de la librería de localización

class BiometricPage extends StatefulWidget {
  const BiometricPage({super.key});

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  // --- VARIABLES SEGURAS SOLO PARA ESTA CLASE ---
  static const double _maxAllowedDistanceMeters = 10000.0; // 10 kilómetros

  String _locationMessage = "Ubicación no obtenida";
  String _authenticationMessage = "Esperando autenticación...";

  @override
  void initState() {
    super.initState();
    _initControlDeAcceso();
  }

  // Método que une ubicación + autenticación + generación OTP
  Future<void> _initControlDeAcceso() async {
    // 1. Obtener ubicación
    Position? position = await LocationService.getCurrentLocation();
    if (position == null) {
      setState(() {
        _locationMessage = "❌ No se pudo obtener ubicación o permisos denegados.";
      });
      return;
    }

    // 2. Calcular distancia
    final resultado = LocationService.calcularDistanciaMinima(position);
    double distanciaMinima = resultado['distancia'];
    Map<String, double> puntoMasCercano = resultado['punto'];

    if (distanciaMinima <= _maxAllowedDistanceMeters) {
      setState(() {
        _locationMessage = "✅ Dentro del rango permitido.\n"
            "Punto más cercano: ${distanciaMinima.toStringAsFixed(2)} metros.\n"
            "Lat: ${puntoMasCercano['lat']}, Lon: ${puntoMasCercano['lon']}";
      });

      // 3. Mostrar cuadro de autenticación biométrica
      bool autenticado = await AuthService.authenticate();

      if (autenticado) {
        setState(() {
          _authenticationMessage = "✅ Autenticación exitosa.";
        });

        // 4. Generar y mostrar OTP
        await OtpService.generateAndShowOTP(context);
      } else {
        setState(() {
          _authenticationMessage = "❌ Autenticación fallida.";
        });
      }
    } else {
      setState(() {
        _locationMessage = "❌ Estás fuera del rango permitido.\n"
            "Punto más cercano: ${distanciaMinima.toStringAsFixed(2)} metros.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Acceso UPS')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(_authenticationMessage, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

import 'package:geolocator/geolocator.dart';

class LocationService {
  // --- VARIABLES SEGURAS SOLO PARA ESTA CLASE ---
  static const List<Map<String, double>> _puntosUniversidad = [
    {"lat": -2.886605, "lon": -78.991467}, // Punto 1
    {"lat": -2.887719, "lon": -78.990259}, // Punto 2
    {"lat": -2.885555, "lon": -78.987531}, // Punto 3
    {"lat": -2.884516, "lon": -78.989742}, // Punto 4
  ];

  // Método para obtener la ubicación actual del usuario
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está activo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Obtener la posición actual con alta precisión
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Método para calcular la distancia mínima al punto más cercano
  static Map<String, dynamic> calcularDistanciaMinima(Position position) {
    double distanciaMinima = double.infinity;
    Map<String, double> puntoMasCercano = {};

    // Calcular cuál es la distancia más cercana
    for (var punto in _puntosUniversidad) {
      double distancia = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        punto["lat"]!,
        punto["lon"]!,
      );

      if (distancia < distanciaMinima) {
        distanciaMinima = distancia;
        puntoMasCercano = punto;
      }
    }

    return {
      "distancia": distanciaMinima,
      "punto": puntoMasCercano,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:otp/otp.dart';
import 'dart:async';

void main() => runApp(const MyApp());

//Coornedanas de la Universidad

// Lista de los 4 puntos de la universidad
final List<Map<String, double>> puntosUniversidad = [
  {"lat": -2.886605, "lon": -78.991467}, // Punto 1
  {"lat": -2.887719, "lon": -78.990259}, // Punto 2
  {"lat": -2.885555, "lon": -78.987531}, // Punto 3
  {"lat": -2.884516, "lon": -78.989742}, // Punto 4
];

// ignore: unused_element
String? _currentOtp;
Timer? _otpTimer;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autenticación Biométrica + Geolocalización',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const BiometricPage(),
    );
  }
}

class BiometricPage extends StatefulWidget {
  const BiometricPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BiometricPageState createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _message = 'Esperando autenticación...';
  String _locationMessage = "Ubicación no obtenida";
  String _validateDistance = "Esta fuera del rango de la u";

  Future<void> _authenticate() async {
    try {
      bool isDeviceSupported = await auth.isDeviceSupported();
      //Validar si el dispositivo soporta biometria
      if (!isDeviceSupported) {
        setState(() {
          _message = '❌ Este dispositivo no soporta biometría.';
        });
        return;
      }

      //Validar si ya tiene registros biometricos en el dispositivo
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        setState(() {
          _message = '❌ No se encontraron métodos biométricos registrados.';
        });
        return;
      }

      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      debugPrint(
        'Biometrías disponibles: $availableBiometrics',
      ); // Útil en debug

      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para ingresar a la universidad',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN/patrón si no hay biometría
          stickyAuth: true,
        ),
      );

      // Validar si el usuario se autentico para generar la llave OTP
      if (authenticated) {
        setState(() {
          _message = '✅ Autenticado correctamente';
        });
        _generateAndShowOTP(); //Mostar la llave
      } else {
        setState(() {
          _message = '❌ Autenticación fallida o cancelada';
        });
      }
    } catch (e) {
      setState(() {
        _message = '⚠️ Error de autenticación: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si el servicio de ubicación está activo
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Los servicios de ubicación están desactivados.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Permisos de ubicación denegados.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage =
            "Permisos permanentemente denegados. Habilítalos desde ajustes.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy:
          LocationAccuracy.high, //high tiene un rango de error de hasta 20 mtrs
    );

    setState(() {
      _locationMessage =
          "Latitud: ${position.latitude}, Longitud: ${position.longitude}";
    });

    double distanciaMinima = double.infinity;
    Map<String, double> puntoMasCercano = {};

    //Calcular cual es la distancia mas cercana
    for (var punto in puntosUniversidad) {
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

    //Validar si esta o no dentro del rango de la u
    if (distanciaMinima <= 100) {
      _locationMessage =
          "✅ Estás dentro del rango.\n"
          "Punto más cercano a ${distanciaMinima.toStringAsFixed(2)} metros.\n"
          "Lat: ${puntoMasCercano['lat']}, Lon: ${puntoMasCercano['lon']}";

      //Automáticamente pedir autenticación
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   _mostrarAvisoYAutenticar();
      // });
    } else {
      //Si el usuario esta fuera del rango permitido no se le permite autenticarse
      setState(() {
        _locationMessage =
            "❌ Estás fuera del rango permitido.\n"
            "Punto más cercano: ${distanciaMinima.toStringAsFixed(2)} metros.";
      });
    }
    setState(() {
      if (distanciaMinima <= 100) {
        _locationMessage =
            "✅ Estás dentro del rango.\n"
            "Punto más cercano a ${distanciaMinima.toStringAsFixed(2)} metros.\n"
            "Lat: ${puntoMasCercano['lat']}, Lon: ${puntoMasCercano['lon']}";
      } else {
        _locationMessage =
            "Tu ubicacion:\n Lat: ${position.latitude}, Lon: ${position.longitude}.\n"
            "❌ Estás fuera del rango permitido.\n"
            "Punto más cercano a ${distanciaMinima.toStringAsFixed(2)} metros.\n"
            "Lat: ${puntoMasCercano['lat']}, Lon: ${puntoMasCercano['lon']}";
      }
    });
  }

  //cuadro de dialogo para la validacion
  void _mostrarAvisoYAutenticar() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bienvenido'),
            content: const Text('Vas a autenticarte para ingresar a la UPS.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _authenticate(); //Se pide la autenticacion
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
    );
  }

  void _generateAndShowOTP() {
    // Cancelar un timer anterior si existe
    _otpTimer?.cancel();

    // Clave secreta(base32)
    const String secret = 'JBSWY3DPEHPK3PXP';

    // Duración de la OTP en segundos
    const int interval = 300;

    // Generar el código TOTP
    String totp = OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: interval,
      length: 6, // 6 dígitos
      algorithm: Algorithm.SHA1, // SHA1 es estándar para TOTP
      isGoogle: true,
    );
    setState(() {
      _currentOtp = totp;
    });

    // Programar la expiración automática en segundos
    const int segundosDeVida = 5; // 5 minutos = 300 segundos

    debugPrint('✅ La OTP se genero correctamente con un tiempo valido deL: $segundosDeVida segundos.');
    // Mostrar el OTP en un cuadro de diálogo
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Llave Temporal Generada'),
            content: Text('Tu OTP es: $totp\n\n¡Expira en 5 minutos!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );

    // Programar la expiración automática
    _otpTimer = Timer(const Duration(seconds: segundosDeVida), () {
      setState(() {
        _currentOtp = null;
      });
      debugPrint(
        '⚠️ La OTP ha expirado automáticamente después de $segundosDeVida segundos.',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarAvisoYAutenticar();
    });
    _getCurrentLocation(); // obtener ubicacion automaticamente al abrir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Acceso + Ubicación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text(_locationMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(_validateDistance, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

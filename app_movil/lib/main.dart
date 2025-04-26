import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

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
      debugPrint('Biometrías disponibles: $availableBiometrics');// Útil en debug

      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para ingresar a la universidad',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN/patrón si no hay biometría
          stickyAuth: true,
        ),
      );

      setState(() {
        _message = authenticated
            ? '✅ Autenticado correctamente'
            : '❌ Autenticación fallida o cancelada';
      });
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
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationMessage = "Latitud: ${position.latitude}, Longitud: ${position.longitude}";
    });
  }

  //cuadro de dialogo para la validacion
  void _mostrarAvisoYAutenticar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          ],
        ),
      ),
    );
  }
}

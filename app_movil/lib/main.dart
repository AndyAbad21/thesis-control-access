import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autenticación Biométrica',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BiometricPage(),
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

      setState(() {
        _message =
            authenticated
                ? '✅ Autenticado correctamente'
                : '❌ Autenticación fallida o cancelada';
      });
    } catch (e) {
      setState(() {
        _message = '⚠️ Error de autenticación: $e';
      });
    }
  }

  //Cuadro de dialogo de bienvenida
  void _mostrarAvisoYAutenticar() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Bienvenido'),
            content: Text('Vas a autenticarte para ingresar a la UPS.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _authenticate(); // Se pide la autenticacion
                },
                child: Text('Continuar'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    //Mostrar el cuadro de diagolo de bienvenida
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarAvisoYAutenticar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Control de Acceso')),
      body: Center(child: Text(_message, style: TextStyle(fontSize: 20))),
    );
  }
}

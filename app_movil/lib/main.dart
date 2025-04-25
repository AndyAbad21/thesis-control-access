import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autenticación Biométrica',
      home: BiometricPage(),
    );
  }
}

class BiometricPage extends StatefulWidget {
  @override
  _BiometricPageState createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _message = 'Esperando autenticación...';

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para acceder',
        options: const AuthenticationOptions(
          biometricOnly: false, // true: que unicamente usa biometria. false: usa demas metodos
          stickyAuth: true, // persistencia de la autenticacion al salirse.
        ),
      );

      setState(() {
        _message = authenticated ? '✅ Autenticado con éxito' : '❌ Falló la autenticación';
      });
    } catch (e) {
      setState(() {
        _message = '⚠️ Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate(); // inicia la autenticación al abrir la app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Control de Acceso')),
      body: Center(child: Text(_message, style: TextStyle(fontSize: 20))),
    );
  }
}

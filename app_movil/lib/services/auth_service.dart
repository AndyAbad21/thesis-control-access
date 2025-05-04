import 'package:local_auth/local_auth.dart';

class AuthService {
  // --- VARIABLES SEGURAS SOLO PARA ESTA CLASE ---
  static final LocalAuthentication _auth = LocalAuthentication();

  static const String _localizedReason =
      'Autentícate para ingresar a la universidad';
  static const bool _biometricOnly =
      false; // Permite PIN/patrón si no hay biometría
  static const bool _stickyAuth =
      true; // Mantener la autenticación si se minimiza la app

  // Método para realizar la autenticación biométrica
  static Future<bool> authenticate() async {
    try {
      // Validar si el dispositivo soporta autenticación
      bool isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) {
        return false;
      }
      // Verifica si se puede hacer la comprobación biométrica
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      print('Biometrías disponibles: $availableBiometrics'); // Útil en debug
      // Solicita la autenticación biométrica
      bool authenticated = await _auth.authenticate(
        localizedReason: _localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: _biometricOnly, // Solo biometría
          stickyAuth: _stickyAuth, // Mantener la autenticación
        ),
      );

      return authenticated; // Retorna true si autenticado, false si no
    } catch (e) {
      print('Error de autenticación: $e');
      return false; // Retorna false si hubo un error
    }
  }
}

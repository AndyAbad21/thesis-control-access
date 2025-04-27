import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Crear instancia del almacenamiento seguro
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Guardar el secreto OTP de forma segura
  static Future<void> guardarSecretoOTP(String secreto) async {
    await _secureStorage.write(key: 'secreto_otp', value: secreto);
  }

  // Leer el secreto OTP de forma segura
  static Future<String?> obtenerSecretoOTP() async {
    return await _secureStorage.read(key: 'secreto_otp');
  }

  // Eliminar el secreto OTP (por si deseas cerrar sesión o limpiar datos)
  static Future<void> eliminarSecretoOTP() async {
    await _secureStorage.delete(key: 'secreto_otp');
  }
}

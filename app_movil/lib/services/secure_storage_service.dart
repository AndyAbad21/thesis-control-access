import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Crear instancia del almacenamiento seguro
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Guardar el secreto OTP de forma segura
  static Future<void> guardarSecretoOTP(String secreto) async {
    debugPrint('🔐 Guardando secreto OTP: $secreto');
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

  // Guardar valor genérico
  static Future<void> guardarValor(String key, String valor) async {
    await _secureStorage.write(key: key, value: valor);
  }

  // Obtener valor genérico
  static Future<String?> obtenerValor(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Eliminar valor genérico
  static Future<void> eliminarValor(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> limpiarTodo() async {
    debugPrint('❌ Se eliminaron Nombres, Apellidos y el secreto del usuario');
    await _secureStorage.deleteAll();
  }
}

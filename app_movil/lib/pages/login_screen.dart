import 'package:app_movil/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para email y password
  final TextEditingController emailController = TextEditingController(
    text: 'aabadf@est.ups.edu.ec',
  );
  final TextEditingController passwordController = TextEditingController(
    text: 'contrasena123',
  );

  // Para mostrar carga mientras esperamos respuesta
  bool _isLoading = false;

  // Para mostrar u ocultar la contraseña
  bool _obscurePassword = true;

  // Función para hacer login llamando al backend
  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Por favor, ingresa email y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.194:5000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Imprimir el JSON completo en consola para depuración
        debugPrint('Respuesta del backend: $jsonResponse');

        if (jsonResponse['status'] == 'success') {
          // Guardar nombres, apellidos y secreto en secure storage
          await SecureStorageService.guardarSecretoOTP(
            jsonResponse['secreto'] ?? '',
          );
          await SecureStorageService.guardarValor(
            'nombres',
            jsonResponse['nombres'] ?? '',
          );
          await SecureStorageService.guardarValor(
            'apellidos',
            jsonResponse['apellidos'] ?? '',
          );
          // Login exitoso, navegar a home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showMessage(jsonResponse['message'] ?? 'Credenciales inválidas');
        }
      } else if (response.statusCode == 401) {
        _showMessage('Credenciales incorrectas');
      } else {
        _showMessage('Error en la conexión al servidor');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error: $e');
    }
  }

  // Mostrar mensaje en Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: Stack(
        children: [
          // --- Elementos del fondo (no se deben mover) ---
          Positioned(
            top: -100,
            left: -250,
            child: Transform.rotate(
              angle: 0.785398, // 45 grados
              child: Container(
                width: 508,
                height: 340,
                color: const Color(0xFF013B72),
              ),
            ),
          ),

          Positioned(
            top: 210,
            right: -60,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset('assets/logo_ups_unico.png', width: 250),
            ),
          ),

          // --- Elementos que sí deben moverse (Ícono y Formulario) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono del usuario
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: const Color(0xFFFEC455),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFF013B72),
                      child: Image.asset('assets/user.png', width: 95),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Contenedor azul
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.43,
                    decoration: const BoxDecoration(
                      color: Color(0xFF013B72),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Email
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'E-mail',
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Botón Login o indicador de carga
                        SizedBox(
                          width: double.infinity,
                          child:
                              _isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF013B72),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

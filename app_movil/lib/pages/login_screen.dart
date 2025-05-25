import 'package:app_movil/services/login_service.dart';
import 'package:flutter/material.dart';
import 'package:app_movil/services/secure_storage_service.dart';
import 'package:app_movil/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'aabadf@est.ups.edu.ec');
  final passwordController = TextEditingController(text: 'contrasena123');
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

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
      final jsonResponse = await LoginService.login(email, password);

      if (jsonResponse['status'] == 'success') {
        await SecureStorageService.guardarSecretoOTP(jsonResponse['secreto'] ?? '');
        await SecureStorageService.guardarValor('nombres', jsonResponse['nombres'] ?? '');
        await SecureStorageService.guardarValor('apellidos', jsonResponse['apellidos'] ?? '');

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage(jsonResponse['message'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -250,
            child: Transform.rotate(
              angle: 0.785398,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  LoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                    obscurePassword: _obscurePassword,
                    togglePasswordVisibility: _togglePasswordVisibility,
                    onLoginPressed: _login,
                    isLoading: _isLoading,
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

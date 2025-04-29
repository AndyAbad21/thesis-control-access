import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                color: Color(0xFF013B72),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono del usuario
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Color(0xFFFEC455),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          hintText: 'E-mail',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
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
                      const SizedBox(height: 20),
                      // Password
                      TextField(
                        obscureText: true,
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
                      // Botón Login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF013B72),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
        ],
      ),
    );
  }
}

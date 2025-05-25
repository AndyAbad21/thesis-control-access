import 'package:app_movil/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notify = false; // Estado del Switch

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF013B72), // Color azul oscuro
        statusBarIconBrightness:
            Brightness.light, // Íconos de la barra en color blanco
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Eliminar todos los datos almacenados en SecureStorage
    await SecureStorageService.limpiarTodo();

    // Navegar a login y eliminar todo el historial de navegación
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Fondo blanco general
      body: SafeArea(
        child: Row(
          children: [
            // 1️⃣ Panel azul (80%)
            Expanded(
              flex: 5, // 80% del ancho
              child: Container(
                color: const Color(0xFF013B72), // Azul institucional
                child: Stack(
                  children: [
                    // Logo de fondo
                    Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/logo_ups_unico.png',
                          width: 250,
                        ),
                      ),
                    ),
                    // Contenido
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Image.asset("assets/config.png", width: 40),
                              const SizedBox(width: 10),
                              const Text(
                                'Configuration',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Switch de notificaciones
                          Row(
                            children: [
                              const Spacer(),
                              const Icon(
                                Icons.notifications_on,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Notify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Transform.scale(
                                scale: 1.3,
                                child: Switch(
                                  value: notify,
                                  onChanged: (value) {
                                    setState(() {
                                      notify = value;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.white,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),

                          const Spacer(),

                          // Términos y condiciones
                          Row(
                            children: const [
                              Icon(
                                Icons.description,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Terms and conditions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Logout
                          GestureDetector(
                            onTap: () => _logout(context),
                            // Cierra el panel
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ), // Espacio pequeño entre texto y línea
                                Container(
                                  height: 2.5,
                                  width: 110,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2️⃣ Parte blanca (20%) que cierra al tocarla
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Animación inversa suave
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

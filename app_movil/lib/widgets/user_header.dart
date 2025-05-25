import 'package:flutter/material.dart';

class UserHeader extends StatelessWidget {
  final String nombres;
  final String apellidos;

  const UserHeader({
    super.key,
    required this.nombres,
    required this.apellidos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          nombres,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        Text(
          apellidos,
          style: const TextStyle(color: Colors.white, fontSize: 25),
        ),
      ],
    );
  }
}

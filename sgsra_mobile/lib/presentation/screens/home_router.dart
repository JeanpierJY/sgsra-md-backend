import 'package:flutter/material.dart';
import 'administrador/admin_main_screen.dart';
import 'mecanico/mecanico_main_screen.dart';
import 'almacenista/almacenista_main_screen.dart';

class HomeRouter extends StatelessWidget {
  final String role;

  const HomeRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role.toUpperCase()) {
      case "MECANICO":
        return const MecanicoMainScreen();
      case "ADMINISTRADOR":
        return const AdminMainScreen();
      case "ALMACENISTA":
        return const AlmacenMainScreen();
      default:
        return const Scaffold(
          body: Center(
            child: Text(
              "Rol desconocido. Contacte a soporte de sistemas.",
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        );
    }
  }
}
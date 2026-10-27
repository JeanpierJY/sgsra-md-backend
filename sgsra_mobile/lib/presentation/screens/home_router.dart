import 'package:flutter/material.dart';
import 'mecanico/catalogo_screen.dart';
import 'administrador/gestion_usuarios_screen.dart';
import 'almacenista/dashboard_pañol_screen.dart';

class HomeRouter extends StatelessWidget {
  final String role;

  const HomeRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // RF02 y RF08: Intercepción de seguridad y carga de vistas según rol limpio
    switch (role.toUpperCase()) {
      case "MECANICO":
        return const CatalogoScreen();
      case "ADMINISTRADOR":
        return const GestionUsuariosScreen();
      case "ALMACENISTA":
        return const DashboardPanolScreen();
      default:
        return const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Error de Permisos:\nSu cuenta no registra vistas válidas en el catálogo maestro. Contacte a soporte técnico.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
    }
  }
}


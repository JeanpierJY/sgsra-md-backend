import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class HomeRouter extends StatelessWidget {
  final String role;

  const HomeRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // RF02, RF08: Intercepción de seguridad por roles para denegar accesos cruzados
    switch (role) {
      case "MECANICO":
        return const CatalogoScreen();
      case "ADMINISTRADOR":
        return const Scaffold(
          body: Center(child: Text("Bandeja del Administrador\nEvaluación de solicitudes autorizada.", textAlign: TextAlign.center)),
        );
      case "ALMACENISTA":
        return const Scaffold(
          body: Center(child: Text("Dashboard del Almacenista\nControl óptico por QR disponible.", textAlign: TextAlign.center)),
        );
      default:
        return const Scaffold(
          body: Center(child: Text("Error: Rol no parametrizado en soporte Técnico.")),
        );
    }
  }
}

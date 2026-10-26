import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'almacen_scan_screen.dart'; 
import 'admin_solicitudes_screen.dart';

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
        return const AdminSolicitudesScreen(); 
      case "ALMACENISTA":
        return const AlmacenScanScreen(); 
      default:
        return const Scaffold(
          body: Center(
            child: Text("Error: Rol no parametrizado en soporte Técnico.", textAlign: TextAlign.center),
          ),
        );
    }
  }
}

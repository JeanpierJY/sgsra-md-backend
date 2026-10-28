import 'package:flutter/material.dart';
import 'mecanico/mecanico_router.dart';
import 'administrador/gestion_usuarios_tab.dart'; 
import 'almacenista/dashboard_panol_screen.dart'; 

class HomeRouter extends StatelessWidget {
  final String role;

  const HomeRouter({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role.toUpperCase()) {
      case "MECANICO":
        return const MecanicoRouter();
        
      case "ADMINISTRADOR":
        return const GestionUsuariosTab(); 
        
      case "ALMACENISTA":
        return const DashboardPanolScreen(); 
        
      default:
        return const Scaffold(
          body: Center(child: Text("Error de Privilegios")),
        );
    }
  }
}

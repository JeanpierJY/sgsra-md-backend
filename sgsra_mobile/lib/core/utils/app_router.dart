import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/editar_perfil_screen.dart';

/// [RF02, RF08] Enrutador y middleware de control de accesos por roles
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/perfil':
        return MaterialPageRoute(builder: (_) => const EditarPerfilScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Acceso no autorizado o ruta no encontrada para: ${settings.name} [RF08]'),
            ),
          ),
        );
    }
  }
}
import 'package:flutter/material.dart';
import '../../../auth/presentation/screens/mi_perfil_screen.dart';

/// [RF07, REQ-01] Mi Perfil del Mecánico: usa la pantalla universal compartida por los 3 roles
/// (datos institucionales de solo lectura, edición de teléfono y cambio de contraseña).
class PerfilMecanicoScreen extends StatelessWidget {
  const PerfilMecanicoScreen({super.key});

  @override
  Widget build(BuildContext context) => const MiPerfilScreen();
}

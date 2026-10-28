import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48)),
          onPressed: () {},
          child: const Text("Guardar Cambios de Perfil"),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SEGURIDAD &\nMANTENIMIENTO DEL SISTEMA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                _buildOptionItem("Autenticación Biométrica", "Sensor de huella digital y reconocimiento facial configurados en el dispositivo.", "ACTIVO Y VINCULADO", Colors.green),
                const Divider(height: 32),
                _buildOptionItem("Restablecer Datos de Demostración", "Restaura todas las solicitudes, herramientas y registros a los valores iniciales de fábrica.", "Reiniciar Base de Datos Local", Colors.blue),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text("Cerrar Sesión Activa (RF03)"),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
        )
      ],
    );
  }

  Widget _buildOptionItem(String titulo, String desc, String estadoAccion, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Text(estadoAccion, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}


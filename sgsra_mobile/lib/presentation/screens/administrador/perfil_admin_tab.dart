import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';

class PerfilAdminTab extends StatelessWidget {
  const PerfilAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Ficha de Identificación del Administrador (Imagen 2)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 46, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text("Leao Chura", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: const Text("ADMINISTRADOR", style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(height: 12),
                const Text("Código Operativo: ADM-1002", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                const Text("🏢 Jefatura de Mantenimiento & Flota", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Sección de Datos de Contacto (Imagen 2)
        const Text("DATOS PERSONALES DE CONTACTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: "Nombre Completo del Operario"),
          controller: const TextEditingController(text: "Leao Chura"),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(labelText: "Teléfono de Contacto (9 dígitos)", prefixIcon: Icon(Icons.phone_android, size: 18)),
          controller: const TextEditingController(text: "987654330"),
        ),
        const SizedBox(height: 24),
        // Botón de Cierre de Sesión (Imagen 7)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade200),
            minimumSize: const Size(double.infinity, 48),
          ),
          icon: const Icon(Icons.logout, size: 16),
          label: const Text("Cerrar Sesión Activa"),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
        )
      ],
    );
  }
}

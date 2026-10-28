import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../login_screen.dart';

class PerfilAdminTab extends StatelessWidget {
  const PerfilAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil Corporativo")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Card(
            color: Color(0xFF1E1E1E),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFFFB300),
                    child: Icon(Icons.person, size: 36, color: Colors.black),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Leao Chura", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Administrador de Taller Mina", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("INFORMACIÓN DE CONTACTO", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Correo Corporativo"),
            controller: TextEditingController(text: "leao.chura@masterdrilling.com"),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Teléfono de Contacto"),
            controller: TextEditingController(text: "987654330"),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            icon: const Icon(Icons.logout),
            label: const Text("CERRAR SESIÓN SEGURA"),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
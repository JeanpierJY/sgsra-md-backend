import 'package:flutter/material.dart';
import 'bandeja_solicitudes_tab.dart';
import 'gestion_usuarios_screen.dart';
import 'perfil_admin_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const BandejaSolicitudesTab(),
    const GestionUsuariosContent(),
    const PerfilAdminTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Bandeja"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Personal"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Perfil"),
        ],
      ),
    );
  }
}
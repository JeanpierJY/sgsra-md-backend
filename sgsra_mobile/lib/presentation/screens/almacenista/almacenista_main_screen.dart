import 'package:flutter/material.dart';
import 'dashboard_panol_screen.dart';
import 'registro_prestamo_tab.dart';
import '../administrador/perfil_admin_tab.dart';

class AlmacenistaMainScreen extends StatefulWidget {
  const AlmacenistaMainScreen({super.key});

  @override
  State<AlmacenistaMainScreen> createState() => _AlmacenistaMainScreenState();
}

class _AlmacenistaMainScreenState extends State<AlmacenistaMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardPanolScreen(),
    const RegistroPrestamoTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Pañol"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Préstamos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
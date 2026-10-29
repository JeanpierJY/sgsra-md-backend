import 'package:flutter/material.dart';
import '../../../core/utils/session_timeout_wrapper.dart';
import 'dashboard_panol_screen.dart';
import 'despacho_herramientas_screen.dart';
import '../administrador/perfil_admin_tab.dart';

class AlmacenMainScreen extends StatefulWidget {
  const AlmacenMainScreen({super.key});

  @override
  State<AlmacenMainScreen> createState() => _AlmacenMainScreenState();
}

class _AlmacenMainScreenState extends State<AlmacenMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardPanolScreen(),
    const DespachoHerramientasScreen(),
    const PerfilAdminTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return SessionTimeoutWrapper(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF0D47A1),
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Panol"),
            BottomNavigationBarItem(icon: Icon(Icons.archive), label: "Prestamos"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          ],
        ),
      ),
    );
  }
}
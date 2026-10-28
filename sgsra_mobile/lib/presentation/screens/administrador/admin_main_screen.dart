import 'package:flutter/material.dart';
import 'bandeja_solicitudes_tab.dart';
import 'metricas_admin_tab.dart';
import 'auditoria_admin_tab.dart';
import '../mecanico/catalogo_screen.dart';
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
    const MetricasAdminTab(),
    const AuditoriaAdminTab(),
    const CatalogoScreen(),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.all_inbox), label: "Bandeja"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Métricas"),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: "Auditoría"),
          BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: "Catálogo"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Mi Perfil"),
        ],
      ),
    );
  }
}
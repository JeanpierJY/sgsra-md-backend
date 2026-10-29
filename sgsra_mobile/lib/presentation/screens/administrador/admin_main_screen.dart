import 'package:flutter/material.dart';
import '../../../core/utils/session_timeout_wrapper.dart';
import 'bandeja_solicitudes_tab.dart';
import 'metricas_admin_tab.dart';
import 'auditoria_admin_tab.dart';
import 'gestion_personal_tab.dart';
import 'gestion_catalogo_tab.dart';
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
    const GestionPersonalTab(),
    const GestionCatalogoTab(),
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
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.all_inbox), label: "Bandeja"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Metricas"),
            BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: "Auditoria"),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Personal"),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Catalogo"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Mi Perfil"),
          ],
        ),
      ),
    );
  }
}
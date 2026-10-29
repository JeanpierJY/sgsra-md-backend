import 'package:flutter/material.dart';
import '../../../core/utils/session_timeout_wrapper.dart';
import 'catalogo_screen.dart';
import 'historial_pedidos_tab.dart';
import '../almacenista/dashboard_panol_screen.dart';
import '../administrador/perfil_admin_tab.dart';

class MecanicoMainScreen extends StatefulWidget {
  const MecanicoMainScreen({super.key});

  @override
  State<MecanicoMainScreen> createState() => _MecanicoMainScreenState();
}

class _MecanicoMainScreenState extends State<MecanicoMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const CatalogoScreen(),
    const HistorialPedidosTab(),
    const DashboardPanolScreen(),
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
          selectedItemColor: const Color(0xFF0D47A1),
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Catalogo"),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Mis Pedidos"),
            BottomNavigationBarItem(icon: Icon(Icons.build), label: "Herramientas"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Mi Perfil"),
          ],
        ),
      ),
    );
  }
}
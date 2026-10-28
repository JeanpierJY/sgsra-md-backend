import 'package:flutter/material.dart';
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
          BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: "Catálogo"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Mis Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Herramientas"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Mi Perfil"),
        ],
      ),
    );
  }
}
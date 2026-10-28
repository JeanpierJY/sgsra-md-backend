import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'historial_pedidos_tab.dart';
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
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: "Catálogo"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Mis Órdenes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
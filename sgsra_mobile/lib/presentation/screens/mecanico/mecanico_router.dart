import 'package:flutter/material.dart';
import 'catalogo_tab.dart';
import 'solicitudes_tab.dart'; // Tu archivo con nombre corregido
import 'herramientas_mecanico_tab.dart';
import 'perfil_mecanico_tab.dart';

class MecanicoRouter extends StatefulWidget {
  const MecanicoRouter({super.key});

  @override
  State<MecanicoRouter> createState() => _MecanicoRouterState();
}

class _MecanicoRouterState extends State<MecanicoRouter> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const CatalogoTab(),
    const SolicitudesTab(), // Nombre corregido según tu estructura
    const HerramientasMecanicoTab(),
    const PerfilMecanicoTab(),
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
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: const Color(0xFF94A3B8),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Catálogo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Mis Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined),
            label: "Herramientas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_outlined),
            label: "Mi Perfil",
          ),
        ],
      ),
    );
  }
}

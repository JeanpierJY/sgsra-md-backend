import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/repuesto_entity.dart';
import 'catalogo_screen.dart';
import 'carrito_pedido_screen.dart';
import 'historial_solicitudes_screen.dart';
import 'herramientas_prestadas_screen.dart';
import 'perfil_mecanico_screen.dart';

class MecanicoMainScreen extends StatefulWidget {
  const MecanicoMainScreen({Key? key}) : super(key: key);

  @override
  State<MecanicoMainScreen> createState() => _MecanicoMainScreenState();
}

class _MecanicoMainScreenState extends State<MecanicoMainScreen> {
  int _currentIndex = 0;
  final Map<RepuestoEntity, int> _carritoGlobal = {};
  // Cada visita a una pestaña de consulta vuelve a crear la pantalla para traer datos frescos
  // (el stock del catálogo y los pedidos cambian por acciones de otros roles)
  final List<int> _visitas = [0, 0, 0, 0, 0];
  String? _solicitudRecienCreada;

  void _irA(int index) {
    setState(() {
      if (index != 1 && index != _currentIndex) _visitas[index]++;
      _currentIndex = index;
    });
  }

  void _onPedidoEnviado(String solicitudNum) {
    setState(() {
      _visitas[0]++; // catálogo con stock reservado actualizado
      _visitas[2]++;
      _solicitudRecienCreada = solicitudNum;
      _currentIndex = 2;
    });
  }

  String? _consumirRecienCreada() {
    final n = _solicitudRecienCreada;
    _solicitudRecienCreada = null;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CatalogoScreen(
        key: ValueKey('cat-${_visitas[0]}'),
        carritoGlobal: _carritoGlobal,
        onCarritoActualizado: () => setState(() {}),
      ),
      CarritoPedidoScreen(
        carrito: _carritoGlobal,
        onCarritoActualizado: () => setState(() {}),
        onPedidoEnviado: _onPedidoEnviado,
      ),
      HistorialSolicitudesScreen(
        key: ValueKey('hist-${_visitas[2]}'),
        solicitudResaltada: _consumirRecienCreada(),
      ),
      HerramientasPrestadasScreen(key: ValueKey('herr-${_visitas[3]}')),
      const PerfilMecanicoScreen(),
    ];

    final int cantCarrito = _carritoGlobal.values.fold(0, (a, b) => a + b);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _irA,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.pureWhite,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Catalogo'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cantCarrito > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                      child: Text('$cantCarrito', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
          const BottomNavigationBarItem(icon: Icon(Icons.handyman_outlined), label: 'Herramientas'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mi Perfil'),
        ],
      ),
    );
  }
}
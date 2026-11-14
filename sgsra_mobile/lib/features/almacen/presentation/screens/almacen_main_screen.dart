import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dashboard_almacen_screen.dart';
import 'despacho_screen.dart';
import 'devolucion_inspeccion_screen.dart';
import 'escanear_qr_screen.dart';
import 'registrar_herramienta_screen.dart';
import 'perfil_almacenista_screen.dart';

class AlmacenMainScreen extends StatefulWidget {
  const AlmacenMainScreen({Key? key}) : super(key: key);

  @override
  State<AlmacenMainScreen> createState() => _AlmacenMainScreenState();
}

class _AlmacenMainScreenState extends State<AlmacenMainScreen> {
  int _currentIndex = 0;

  // Dashboard, despacho y retorno se vuelven a crear en cada visita para mostrar datos actualizados
  final List<int> _visitas = [0, 0, 0];

  void _irA(int index) {
    setState(() {
      if (index < _visitas.length && index != _currentIndex) _visitas[index]++;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardAlmacenScreen(key: ValueKey('dash-${_visitas[0]}')),
      DespachoScreen(key: ValueKey('desp-${_visitas[1]}')),
      DevolucionInspeccionScreen(key: ValueKey('dev-${_visitas[2]}')),
      const EscanearQrScreen(),
      const RegistrarHerramientaScreen(),
      const PerfilAlmacenistaScreen(),
    ];
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_outlined), label: 'Despacho'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_return_outlined), label: 'Retorno'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), label: 'Escanear QR'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman_outlined), label: 'Activos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mi Perfil'),
        ],
      ),
    );
  }
}
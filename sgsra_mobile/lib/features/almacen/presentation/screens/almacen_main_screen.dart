import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dashboard_almacen_screen.dart';
import 'registrar_prestamo_screen.dart';
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

  final List<Widget> _screens = const [
    DashboardAlmacenScreen(),
    RegistrarPrestamoScreen(),
    DevolucionInspeccionScreen(),
    EscanearQrScreen(),
    RegistrarHerramientaScreen(),
    PerfilAlmacenistaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
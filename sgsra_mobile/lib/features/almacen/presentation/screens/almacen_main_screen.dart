import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dashboard_almacen_screen.dart';
import 'despacho_screen.dart';
import 'retorno_qr_screen.dart';
import 'registrar_herramienta_screen.dart';

/// Módulo Almacenista: 4 pestañas de trabajo. "Mi Perfil" se abre desde el avatar
/// de la esquina superior derecha (GEN-02) y el escáner QR está dentro de Retorno (ALM-03).
class AlmacenMainScreen extends StatefulWidget {
  const AlmacenMainScreen({Key? key}) : super(key: key);

  @override
  State<AlmacenMainScreen> createState() => _AlmacenMainScreenState();
}

class _AlmacenMainScreenState extends State<AlmacenMainScreen> {
  int _currentIndex = 0;

  // Cada pestaña se vuelve a crear al visitarla para mostrar datos actualizados
  final List<int> _visitas = [0, 0, 0, 0];

  void _irA(int index) {
    setState(() {
      if (index != _currentIndex) _visitas[index]++;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardAlmacenScreen(key: ValueKey('dash-${_visitas[0]}')),
      DespachoScreen(key: ValueKey('desp-${_visitas[1]}')),
      // La cámara solo se crea cuando la pestaña Retorno está visible
      _currentIndex == 2 ? RetornoQrScreen(key: ValueKey('ret-${_visitas[2]}')) : const SizedBox.shrink(),
      RegistrarHerramientaScreen(key: ValueKey('herr-${_visitas[3]}')),
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
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'Retorno'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman_outlined), label: 'Herramientas'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'bandeja_solicitudes_screen.dart';
import 'auditoria_screen.dart';
import 'mantenimiento_catalogo_screen.dart';
import 'reportes_analiticos_screen.dart';
import 'gestion_personal_screen.dart';
import 'perfil_admin_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // [ADM-02] Cada visita a Bandeja, Auditoría o Personal recarga sus datos
  // (antes la bitácora se cargaba una sola vez y no mostraba las acciones nuevas)
  final List<int> _visitas = List.filled(6, 0);

  void _irA(int index) {
    setState(() {
      if (index != _currentIndex && (index == 0 || index == 1 || index == 4)) _visitas[index]++;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      BandejaSolicitudesScreen(key: ValueKey('bandeja-${_visitas[0]}')),
      AuditoriaScreen(key: ValueKey('audit-${_visitas[1]}')),
      const MantenimientoCatalogoScreen(),
      const ReportesAnaliticosScreen(),
      GestionPersonalScreen(key: ValueKey('personal-${_visitas[4]}')),
      const PerfilAdminScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_rounded),
            label: 'Bandeja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_rounded),
            label: 'Auditoria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Catalogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Personal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Mi Perfil',
          ),
        ],
      ),
    );
  }
}
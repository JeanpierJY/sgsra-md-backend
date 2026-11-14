import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import 'despacho_repuestos_tab.dart';
import 'registrar_prestamo_screen.dart';

/// [ALM-01, RF36] Pestaña Despacho del almacenista con sus dos salidas formales:
/// repuestos por solicitud aprobada y préstamo de herramientas de pañol.
class DespachoScreen extends StatefulWidget {
  const DespachoScreen({super.key});

  @override
  State<DespachoScreen> createState() => _DespachoScreenState();
}

class _DespachoScreenState extends State<DespachoScreen> {
  int? _pendientes;
  int _recargas = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          title: const Text('Despacho', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          actions: [
            const NotificacionBell(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Actualizar',
              onPressed: () => setState(() => _recargas++),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Flexible(child: Text('Repuestos', overflow: TextOverflow.ellipsis)),
                  if ((_pendientes ?? 0) > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.errorRed, borderRadius: BorderRadius.circular(10)),
                      child: Text('$_pendientes',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
              ),
              const Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.handyman_outlined, size: 18),
                  SizedBox(width: 6),
                  Flexible(child: Text('Herramientas', overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DespachoRepuestosTab(
              key: ValueKey('rep-$_recargas'),
              onPendientes: (n) {
                if (mounted && n != _pendientes) setState(() => _pendientes = n);
              },
            ),
            RegistrarPrestamoScreen(key: ValueKey('her-$_recargas'), embebido: true),
          ],
        ),
      ),
    );
  }
}

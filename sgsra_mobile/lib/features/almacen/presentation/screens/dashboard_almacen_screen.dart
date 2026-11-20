import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

class DashboardAlmacenScreen extends StatefulWidget {
  const DashboardAlmacenScreen({Key? key}) : super(key: key);

  @override
  State<DashboardAlmacenScreen> createState() => _DashboardAlmacenScreenState();
}

class _DashboardAlmacenScreenState extends State<DashboardAlmacenScreen> {
  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());
  bool _isLoading = true;
  DashboardStockEntity? _dashboard;
  List<PrestamoEntity> _prestamos = [];
  List<dynamic> _solicitudesAprobadas = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dash = await _dataSource.obtenerDashboard();
      final prestamos = await _dataSource.listarPrestamos();
      final solicitudes = await _dataSource.listarSolicitudesAprobadas();
      setState(() {
        _dashboard = dash;
        _prestamos = prestamos;
        _solicitudesAprobadas = solicitudes;
        _isLoading = false;
      });
    } catch (e) {
      // ALM-06: sin datos de ejemplo; se informa el problema
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'No se pudo conectar con el servidor. Deslice hacia abajo para reintentar.';
      });
    }
  }

  Widget _tarjetaKpi(String label, int val, Color color, IconData icon) {
    return Card(
      color: AppColors.pureWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text('$val', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _dashboard;
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Dashboard de Pañol [RF33]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarDatos),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null)
                  Card(
                    color: AppColors.errorRed.withValues(alpha: 0.08),
                    child: ListTile(
                      leading: const Icon(Icons.cloud_off_rounded, color: AppColors.errorRed),
                      title: Text(_error!, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                const Text('Stock Actual de Herramientas [RF33]:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.55,
                  children: [
                    _tarjetaKpi('Disponibles', d?.totalDisponibles ?? 0, Colors.green[700]!, Icons.check_circle_outline),
                    _tarjetaKpi('Prestadas', d?.totalPrestadas ?? 0, AppColors.primaryBlue, Icons.handyman_outlined),
                    _tarjetaKpi('En mora', d?.totalEnMora ?? 0, Colors.orange[800]!, Icons.access_time_rounded),
                    _tarjetaKpi('Mantenimiento', d?.totalEnMantenimiento ?? 0, Colors.amber[900]!, Icons.build_circle_outlined),
                    _tarjetaKpi('Extraviadas', d?.totalExtraviadas ?? 0, AppColors.errorRed, Icons.warning_amber_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Repuestos Aprobados para Retiro Físico:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 8),
                if (_solicitudesAprobadas.isEmpty)
                  Card(
                    color: AppColors.pureWhite,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay solicitudes de repuestos pendientes de despacho.'),
                    ),
                  )
                else
                  ..._solicitudesAprobadas.map((s) => Card(
                        color: AppColors.pureWhite,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2, color: Colors.teal),
                          title: Text('Orden: ${s['solicitudNum']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Mecánico: ${s['nombreMecanico']} | Máquina: ${s['codMaquinaria']}'),
                          trailing: const Chip(label: Text('AUTORIZADO', style: TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: Colors.teal),
                        ),
                      )),
                const SizedBox(height: 24),
                const Text('Control y Listado de Préstamos [RF36, RF43]:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 8),
                if (_prestamos.isEmpty)
                  Card(
                    color: AppColors.pureWhite,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No existen registros de préstamos de herramientas en curso.'),
                    ),
                  )
                else
                  ..._prestamos.map((p) => Card(
                        color: AppColors.pureWhite,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () => mostrarDetallePrestamo(context, p.raw.isEmpty
                              ? {'prestamoNum': p.prestamoNum, 'nombreMecanico': p.nombreMecanico, 'dniMecanico': p.dniMecanico,
                                 'estadoPrestamo': p.estadoPrestamo, 'fechaPrestamo': p.fechaPrestamo, 'horaSalida': p.horaSalida}
                              : p.raw),
                          leading: CircleAvatar(backgroundColor: colorEstadoPrestamo(p.estadoPrestamo), child: const Icon(Icons.handyman, color: Colors.white, size: 20)),
                          title: Text('${p.prestamoNum} | Mecánico: ${p.nombreMecanico}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('DNI: ${p.dniMecanico} | Fecha: ${p.fechaPrestamo} ${p.horaSalida}\nHerramientas: ${p.herramientas.join(", ")}\nToque para ver el antes y después'),
                          trailing: Chip(
                            label: Text(etiquetaEstadoPrestamo(p.estadoPrestamo), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: colorEstadoPrestamo(p.estadoPrestamo),
                          ),
                          isThreeLine: true,
                        ),
                      )),
              ],
            ),
            ),
    );
  }
}

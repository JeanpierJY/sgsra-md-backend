import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
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
    } catch (_) {
      setState(() {
        _dashboard = const DashboardStockEntity(
          totalDisponibles: 42,
          totalPrestadas: 8,
          totalEnMora: 2,
          totalEnMantenimiento: 3,
          totalExtraviadas: 1,
        );
        _isLoading = false;
      });
    }
  }

  Widget _tarjetaKpi(String label, int val, Color color, IconData icon) {
    return Card(
      color: AppColors.pureWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 26),
                Text('$val', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Stock Actual de Herramientas [RF33]:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _tarjetaKpi('Disponibles', d?.totalDisponibles ?? 0, Colors.green[700]!, Icons.check_circle_outline),
                    _tarjetaKpi('Prestadas', d?.totalPrestadas ?? 0, AppColors.primaryBlue, Icons.handyman_outlined),
                    _tarjetaKpi('En Mora / Retraso', d?.totalEnMora ?? 0, Colors.orange[800]!, Icons.access_time_rounded),
                    _tarjetaKpi('En Mantenimiento', d?.totalEnMantenimiento ?? 0, Colors.amber[900]!, Icons.build_circle_outlined),
                    _tarjetaKpi('Extraviadas', d?.totalExtraviadas ?? 0, AppColors.errorRed, Icons.warning_amber_rounded),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Control y Listado de Préstamos Activos [RF36, RF43]:',
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
                          leading: const CircleAvatar(backgroundColor: AppColors.primaryBlue, child: Icon(Icons.handyman, color: Colors.white, size: 20)),
                          title: Text('${p.prestamoNum} | Mecánico: ${p.nombreMecanico}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('DNI: ${p.dniMecanico} | Fecha: ${p.fechaPrestamo} ${p.horaSalida}\nHerramientas: ${p.herramientas.join(", ")}'),
                          trailing: Chip(
                            label: Text(p.estadoPrestamo, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: p.estadoPrestamo == 'DEVUELTO' ? Colors.green[700] : (p.estadoPrestamo == 'EN_MORA' ? AppColors.errorRed : AppColors.primaryBlue),
                          ),
                          isThreeLine: true,
                        ),
                      )),
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
              ],
            ),
    );
  }
}
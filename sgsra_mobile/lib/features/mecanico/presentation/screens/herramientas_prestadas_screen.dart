import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';

/// [RF36, PRE-01] Herramientas del mecánico: préstamos en curso e historial.
/// Al tocar un préstamo se ve el antes (entrega) y el después (devolución).
class HerramientasPrestadasScreen extends StatefulWidget {
  const HerramientasPrestadasScreen({super.key});

  @override
  State<HerramientasPrestadasScreen> createState() => _HerramientasPrestadasScreenState();
}

class _HerramientasPrestadasScreenState extends State<HerramientasPrestadasScreen> {
  final RepuestoRemoteDataSource _dataSource = RepuestoRemoteDataSource(DioClient());
  bool _isLoading = true;
  List<Map<String, dynamic>> _prestamos = [];

  @override
  void initState() {
    super.initState();
    _cargarHerramientas();
  }

  Future<void> _cargarHerramientas() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dataSource.listarHerramientasCustodia();
      final data = list.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        ..sort((a, b) => '${b['fechaPrestamo']} ${b['horaSalida']}'.compareTo('${a['fechaPrestamo']} ${a['horaSalida']}'));
      if (!mounted) return;
      setState(() {
        _prestamos = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _enCurso(Map p) {
    final e = p['estadoPrestamo']?.toString() ?? '';
    return e != 'CERRADO' && e != 'DEVUELTO';
  }

  @override
  Widget build(BuildContext context) {
    final enCurso = _prestamos.where(_enCurso).toList();
    final historial = _prestamos.where((p) => !_enCurso(p)).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Herramientas en Custodia [RF36]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          const NotificacionBell(),
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarHerramientas),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : RefreshIndicator(
              onRefresh: _cargarHerramientas,
              child: _prestamos.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 90),
                      Icon(Icons.handyman_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 8),
                      Center(child: Text('Usted no registra préstamos de herramientas.')),
                    ])
                  : ListView(
                      padding: const EdgeInsets.all(14),
                      children: [
                        _titulo('En su poder', enCurso.length, Icons.back_hand_outlined),
                        if (enCurso.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text('No tiene herramientas pendientes de devolver.', style: TextStyle(color: Colors.grey)),
                          ),
                        ...enCurso.map(_tarjeta),
                        if (historial.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _titulo('Historial de préstamos', historial.length, Icons.history_rounded),
                          ...historial.map(_tarjeta),
                        ],
                      ],
                    ),
            ),
    );
  }

  Widget _titulo(String t, int n, IconData i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(i, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text('$t ($n)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
        ]),
      );

  Widget _tarjeta(Map<String, dynamic> p) {
    final estado = p['estadoPrestamo']?.toString() ?? 'ACTIVO';
    final color = colorEstadoPrestamo(estado);
    final herramientas = (p['herramientas'] as List?)?.map((h) => h['nombreHerramienta'] ?? h['codHerramienta']).join(', ') ?? '';
    return Card(
      color: AppColors.pureWhite,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () => mostrarDetallePrestamo(context, p),
        leading: CircleAvatar(backgroundColor: color, child: const Icon(Icons.build, color: Colors.white)),
        title: Text('Préstamo ${p['prestamoNum'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$herramientas\nSalida: ${p['fechaPrestamo']}  ·  Toque para ver el detalle',
            maxLines: 3, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(etiquetaEstadoPrestamo(estado),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ),
    );
  }
}

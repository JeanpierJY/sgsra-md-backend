import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF36, PRE-01] Herramientas del mecánico: préstamos en curso, retraso/extravíos e historial devueltas.
/// Organizado en pestañas para total claridad operativa.
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

  bool _tieneExtraviada(Map p) {
    final list = p['herramientas'] as List?;
    if (list == null) return false;
    return list.any((h) {
      final ef = (h['estadoFisicoActual'] ?? '').toString().toLowerCase();
      final eh = (h['estadoHerramienta'] ?? '').toString().toLowerCase();
      return ef.contains('extraviad') || eh.contains('extraviad');
    });
  }

  bool _esRetrasoOExtravio(Map p) {
    final estado = (p['estadoPrestamo'] ?? '').toString().toUpperCase();
    return estado == 'MORA' || _tieneExtraviada(p);
  }

  bool _esDevuelto(Map p) {
    final estado = (p['estadoPrestamo'] ?? '').toString().toUpperCase();
    return (estado == 'CERRADO' || estado == 'DEVUELTO') && !_tieneExtraviada(p);
  }

  bool _esEnCurso(Map p) {
    final estado = (p['estadoPrestamo'] ?? '').toString().toUpperCase();
    return estado == 'ACTIVO' && !_tieneExtraviada(p);
  }

  @override
  Widget build(BuildContext context) {
    final enCurso = _prestamos.where(_esEnCurso).toList();
    final retrasosOExtravios = _prestamos.where(_esRetrasoOExtravio).toList();
    final historial = _prestamos.where(_esDevuelto).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          title: const Text('Herramientas en Custodia [RF36]', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primaryBlue,
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarHerramientas),
            const NotificacionBell(),
            const PerfilBoton(),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: const Icon(Icons.handyman_outlined, size: 20),
                text: 'En curso (${enCurso.length})',
              ),
              Tab(
                icon: const Icon(Icons.warning_amber_rounded, size: 20),
                text: 'Retraso/Alerta (${retrasosOExtravios.length})',
              ),
              Tab(
                icon: const Icon(Icons.history_rounded, size: 20),
                text: 'Devueltas (${historial.length})',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : RefreshIndicator(
                onRefresh: _cargarHerramientas,
                child: TabBarView(
                  children: [
                    _buildLista(
                      enCurso,
                      'No tiene herramientas activas pendientes de devolver.',
                      Icons.handyman_outlined,
                    ),
                    _buildLista(
                      retrasosOExtravios,
                      'No tiene herramientas con retraso ni extravíos registrados.',
                      Icons.verified_user_outlined,
                    ),
                    _buildLista(
                      historial,
                      'No registra historial de herramientas devueltas.',
                      Icons.history_rounded,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLista(List<Map<String, dynamic>> lista, String mensajeVacio, IconData iconoVacio) {
    if (lista.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Icon(iconoVacio, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Center(
            child: Text(mensajeVacio, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: lista.length,
      itemBuilder: (context, i) => _tarjeta(lista[i]),
    );
  }

  Widget _tarjeta(Map<String, dynamic> p) {
    final estado = p['estadoPrestamo']?.toString() ?? 'ACTIVO';
    final tieneExtravio = _tieneExtraviada(p);
    final esMora = estado == 'MORA';

    Color color = colorEstadoPrestamo(estado);
    String label = etiquetaEstadoPrestamo(estado);

    if (tieneExtravio) {
      color = AppColors.errorRed;
      label = 'Extravío reportado';
    } else if (esMora) {
      color = Colors.orange.shade800;
      label = 'En Mora / Retraso';
    }

    final herramientas = (p['herramientas'] as List?)?.map((h) => h['nombreHerramienta'] ?? h['codHerramienta']).join(', ') ?? '';
    return Card(
      color: AppColors.pureWhite,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () => mostrarDetallePrestamo(context, p),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(tieneExtravio ? Icons.report_problem_rounded : Icons.build, color: Colors.white),
        ),
        title: Text('Préstamo ${p['prestamoNum'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '$herramientas\nSalida: ${p['fechaPrestamo']}  ·  Toque para ver detalle',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

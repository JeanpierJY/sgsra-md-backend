import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/widgets/detalle_solicitud_sheet.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';

/// [RF19, MEC-02, MEC-03] Pedidos del mecánico. Se recarga cada vez que se abre la pestaña
/// y al tocar una solicitud muestra su detalle (incluido el motivo si fue rechazada).
class HistorialSolicitudesScreen extends StatefulWidget {
  /// Solicitud recién creada que se abre automáticamente al entrar
  final String? solicitudResaltada;
  const HistorialSolicitudesScreen({Key? key, this.solicitudResaltada}) : super(key: key);

  @override
  State<HistorialSolicitudesScreen> createState() => _HistorialSolicitudesScreenState();
}

class _HistorialSolicitudesScreenState extends State<HistorialSolicitudesScreen> {
  final RepuestoRemoteDataSource _dataSource = RepuestoRemoteDataSource(DioClient());
  bool _isLoading = true;
  String? _error;
  List<dynamic> _historial = [];
  String _filtro = 'TODAS';

  static const _filtros = {
    'TODAS': 'Todas',
    'PENDIENTE': 'Pendientes',
    'APROBADA': 'Aprobadas',
    'RECHAZADA': 'Rechazadas',
    'ENTREGADA': 'Entregadas',
  };

  @override
  void initState() {
    super.initState();
    _cargarHistorial().then((_) {
      final num = widget.solicitudResaltada;
      if (num != null && mounted) mostrarDetalleSolicitud(context, num);
    });
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _dataSource.listarHistorial();
      if (!mounted) return;
      setState(() {
        _historial = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = mensajeDeError(e);
      });
    }
  }

  List<dynamic> get _filtradas {
    if (_filtro == 'TODAS') return _historial;
    return _historial.where((s) {
      final e = s['estado']?.toString() ?? '';
      return _filtro == 'APROBADA' ? e.startsWith('APROBADA') : e == _filtro;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Mis Solicitudes [RF19]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          const NotificacionBell(),
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarHistorial),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: _filtros.entries.map((f) {
                final sel = _filtro == f.key;
                final n = f.key == 'TODAS'
                    ? _historial.length
                    : _historial.where((s) {
                        final e = s['estado']?.toString() ?? '';
                        return f.key == 'APROBADA' ? e.startsWith('APROBADA') : e == f.key;
                      }).length;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${f.value} ($n)'),
                    selected: sel,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _filtro = f.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _cargarHistorial,
                    child: _error != null
                        ? ListView(children: [
                            const SizedBox(height: 80),
                            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
                            const SizedBox(height: 8),
                            Center(child: Text(_error!, textAlign: TextAlign.center)),
                            Center(
                              child: TextButton.icon(
                                  onPressed: _cargarHistorial, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                            ),
                          ])
                        : lista.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 80),
                                Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
                                SizedBox(height: 8),
                                Center(child: Text('No hay solicitudes en esta categoría.')),
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.all(14),
                                itemCount: lista.length,
                                itemBuilder: (context, index) => _tarjeta(lista[index]),
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(dynamic item) {
    final estado = item['estado']?.toString() ?? 'PENDIENTE';
    final color = colorEstadoSolicitud(estado);
    final rechazada = estado == 'RECHAZADA';
    final num = '${item['solicitudNum']}';
    return Card(
      color: AppColors.pureWhite,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => mostrarDetalleSolicitud(context, num),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(num, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(etiquetaEstadoSolicitud(estado),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 18),
              Text('Maquinaria: ${item['codMaquinaria']} | Prioridad: ${item['prioridad']}'),
              Text('Fecha de emisión: ${item['fechaEmision']}  ·  ${item['totalComponentes'] ?? 0} repuesto(s)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(rechazada ? Icons.info_outline_rounded : Icons.touch_app_outlined,
                      size: 16, color: rechazada ? AppColors.errorRed : AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    rechazada ? 'Toque para ver el motivo del rechazo' : 'Toque para ver el detalle',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: rechazada ? AppColors.errorRed : AppColors.primaryBlue,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

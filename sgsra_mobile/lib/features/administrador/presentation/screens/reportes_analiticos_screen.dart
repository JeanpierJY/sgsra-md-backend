import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF29, RF30, REQ-04, ADM-07] Métricas del periodo elegido (30, 60, 90 o 180 días):
/// resumen de solicitudes, repuestos más pedidos, prioridades, stock crítico y exportación.
class ReportesAnaliticosScreen extends StatefulWidget {
  const ReportesAnaliticosScreen({Key? key}) : super(key: key);

  @override
  State<ReportesAnaliticosScreen> createState() => _ReportesAnaliticosScreenState();
}

class _ReportesAnaliticosScreenState extends State<ReportesAnaliticosScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  String? _error;
  int _dias = 30;
  bool _exportando = false;

  List<Map<String, dynamic>> _demanda = [];
  List<Map<String, dynamic>> _solicitudes = [];
  List<Map<String, dynamic>> _stockCritico = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  String _fecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime get _inicio => DateTime.now().subtract(Duration(days: _dias));

  Future<void> _cargar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rango = {'inicio': _fecha(_inicio), 'fin': _fecha(DateTime.now())};
      final r = await Future.wait([
        _dioClient.dio.get('/reportes/demanda', queryParameters: rango),
        _dioClient.dio.get('/solicitudes/bandeja'),
        _dioClient.dio.get('/catalogo', queryParameters: {'size': 300}),
      ]);
      List<Map<String, dynamic>> aLista(dynamic d) {
        final l = d is Map && d['content'] != null ? d['content'] as List : (d is List ? d : const []);
        return l.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      final desde = DateTime(_inicio.year, _inicio.month, _inicio.day);
      final sols = aLista(r[1].data).where((s) {
        final f = DateTime.tryParse('${s['fechaEmision']}');
        return f == null || !f.isBefore(desde);
      }).toList();
      final criticos = aLista(r[2].data)
          .where((x) =>
              (x['activo'] ?? true) == true &&
              ((x['stockActual'] as num?) ?? 0) <= ((x['stockMinimo'] as num?) ?? 0))
          .toList()
        ..sort((a, b) => ((a['stockActual'] as num?) ?? 0).compareTo((b['stockActual'] as num?) ?? 0));

      if (!mounted) return;
      setState(() {
        _demanda = aLista(r[0].data);
        _solicitudes = sols;
        _stockCritico = criticos;
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

  Future<void> _exportarArchivo(String formato) async {
    setState(() => _exportando = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final res = await _dioClient.dio.get(
        '/reportes/exportar',
        queryParameters: {'formato': formato, 'inicio': _fecha(_inicio), 'fin': _fecha(DateTime.now())},
        options: Options(responseType: ResponseType.bytes, headers: {'Accept': '*/*'}),
      );
      final nombre = formato == 'EXCEL'
          ? 'Reporte_SGSRA_${_dias}dias_${_fecha(DateTime.now())}.xlsx'
          : 'Reporte_SGSRA_${_dias}dias_${_fecha(DateTime.now())}.csv';
      final ruta = await guardarYAbrirArchivo(res.data as List<int>, nombre);
      messenger.showSnackBar(SnackBar(content: Text('Reporte guardado: $ruta'), backgroundColor: Colors.green[700]));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('No se pudo exportar: ${mensajeDeError(e)}'), backgroundColor: AppColors.errorRed));
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  int _contar(bool Function(String e) f) => _solicitudes.where((s) => f('${s['estado']}')).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Métricas y Reportes [RF29]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargar),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // Periodo [REQ-04]
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30 días')),
                ButtonSegment(value: 60, label: Text('60 días')),
                ButtonSegment(value: 90, label: Text('90 días')),
                ButtonSegment(value: 180, label: Text('180 días')),
              ],
              selected: {_dias},
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                backgroundColor: AppColors.pureWhite,
                selectedBackgroundColor: AppColors.primaryBlue,
                selectedForegroundColor: Colors.white,
              ),
              onSelectionChanged: (v) {
                setState(() => _dias = v.first);
                _cargar();
              },
            ),
            const SizedBox(height: 4),
            Text('Del ${_fecha(_inicio)} al ${_fecha(DateTime.now())}',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              _Tarjeta(
                titulo: 'No se pudieron cargar las métricas',
                icono: Icons.cloud_off_rounded,
                child: Column(children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton.icon(onPressed: _cargar, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                ]),
              )
            else ...[
              _resumen(),
              const SizedBox(height: 12),
              _topDemanda(),
              const SizedBox(height: 12),
              _prioridades(),
              const SizedBox(height: 12),
              _criticos(),
            ],
            const SizedBox(height: 12),
            _exportacion(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _resumen() {
    final total = _solicitudes.length;
    final pend = _contar((e) => e == 'PENDIENTE');
    final apr = _contar((e) => e.startsWith('APROBADA') || e == 'ORDEN_CONTACTADA');
    final ent = _contar((e) => e == 'ENTREGADA');
    final rech = _contar((e) => e == 'RECHAZADA');
    final evaluadas = total - pend;
    final tasa = evaluadas == 0 ? 0 : (((apr + ent) / evaluadas) * 100).round();
    return _Tarjeta(
      titulo: 'Resumen de solicitudes',
      icono: Icons.dashboard_customize_outlined,
      child: Column(children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.45,
          children: [
            _Kpi('Total', total, AppColors.primaryBlue, Icons.receipt_long_rounded),
            _Kpi('Pendientes', pend, Colors.amber[800]!, Icons.hourglass_top_rounded),
            _Kpi('Aprobadas', apr, Colors.green[700]!, Icons.check_circle_outline),
            _Kpi('Entregadas', ent, Colors.teal, Icons.local_shipping_outlined),
            _Kpi('Rechazadas', rech, AppColors.errorRed, Icons.cancel_outlined),
            _Kpi('Aprobación', tasa, Colors.indigo, Icons.percent_rounded, sufijo: '%'),
          ],
        ),
      ]),
    );
  }

  Widget _topDemanda() {
    final maxVal = _demanda.isEmpty
        ? 1
        : _demanda.map((e) => (e['cantidadTotalSolicitada'] as num?)?.toInt() ?? 0).reduce((a, b) => a > b ? a : b);
    return _Tarjeta(
      titulo: 'Repuestos más solicitados',
      icono: Icons.insights_rounded,
      child: _demanda.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hubo solicitudes de repuestos en este periodo.', style: TextStyle(color: Colors.grey)),
            )
          : Column(
              children: _demanda.take(10).toList().asMap().entries.map((en) {
                final item = en.value;
                final cant = (item['cantidadTotalSolicitada'] as num?)?.toInt() ?? 0;
                final factor = (cant / (maxVal == 0 ? 1 : maxVal)).clamp(0.04, 1.0);
                final medalla = [Colors.amber[700], Colors.blueGrey[300], Colors.brown[300]];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: en.key < 3 ? medalla[en.key] : Colors.grey[200],
                      child: Text('${en.key + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: en.key < 3 ? Colors.white : Colors.black54)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                            child: Text('${item['nombreRepuesto']}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                          Text('$cant u.',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        ]),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: factor.toDouble(),
                            minHeight: 9,
                            backgroundColor: Colors.grey[200],
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Text('${item['codParte']}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                      ]),
                    ),
                  ]),
                );
              }).toList(),
            ),
    );
  }

  Widget _prioridades() {
    final total = _solicitudes.isEmpty ? 1 : _solicitudes.length;
    Widget barra(String p, Color c) {
      final n = _solicitudes.where((s) => s['prioridad'] == p).length;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(width: 60, child: Text(p, style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 12.5))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: n / total, minHeight: 14, backgroundColor: Colors.grey[200], color: c),
            ),
          ),
          SizedBox(width: 70, child: Text('  $n (${(n * 100 / total).round()}%)', style: const TextStyle(fontSize: 12.5))),
        ]),
      );
    }

    return _Tarjeta(
      titulo: 'Solicitudes por prioridad',
      icono: Icons.flag_outlined,
      child: Column(children: [
        barra('ALTA', AppColors.errorRed),
        barra('MEDIA', Colors.amber[800]!),
        barra('BAJA', Colors.blueGrey),
      ]),
    );
  }

  Widget _criticos() {
    return _Tarjeta(
      titulo: 'Repuestos en stock mínimo (${_stockCritico.length})',
      icono: Icons.warning_amber_rounded,
      color: _stockCritico.isEmpty ? Colors.green[700]! : Colors.orange[800]!,
      child: _stockCritico.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Todo el catálogo está por encima de su stock mínimo.', style: TextStyle(color: Colors.grey)),
            )
          : Column(
              children: _stockCritico.take(8).map((r) {
                final act = (r['stockActual'] as num?)?.toInt() ?? 0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: ImagenProducto(url: r['imagenUrl']?.toString(), size: 40),
                  title: Text('${r['nombreRepuesto']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r['codParte']}  ·  Mínimo: ${r['stockMinimo']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (act == 0 ? AppColors.errorRed : Colors.orange[800]!).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(act == 0 ? 'Agotado' : 'Quedan $act',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: act == 0 ? AppColors.errorRed : Colors.orange[800])),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _exportacion() {
    return _Tarjeta(
      titulo: 'Exportar reporte [RF30]',
      icono: Icons.download_rounded,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Incluye las solicitudes de los últimos $_dias días.',
            style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _exportando ? null : () => _exportarArchivo('EXCEL'),
              icon: const Icon(Icons.table_view_rounded),
              label: const Text('Excel'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _exportando ? null : () => _exportarArchivo('CSV'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('CSV'),
            ),
          ),
        ]),
        if (_exportando)
          const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator()),
      ]),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;
  final Color color;
  const _Tarjeta({required this.titulo, required this.icono, required this.child, this.color = AppColors.primaryBlue});

  @override
  Widget build(BuildContext context) => Card(
        color: AppColors.pureWhite,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icono, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color))),
            ]),
            const Divider(height: 18),
            child,
          ]),
        ),
      );
}

class _Kpi extends StatelessWidget {
  final String etiqueta;
  final int valor;
  final Color color;
  final IconData icono;
  final String sufijo;
  const _Kpi(this.etiqueta, this.valor, this.color, this.icono, {this.sufijo = ''});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 4),
              Text('$valor$sufijo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: color)),
            ]),
            const SizedBox(height: 2),
            Text(etiqueta, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
          ],
        ),
      );
}

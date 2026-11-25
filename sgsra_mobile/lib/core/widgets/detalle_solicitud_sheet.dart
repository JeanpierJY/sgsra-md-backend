import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../errors/exceptions.dart';
import '../network/dio_client.dart';
import '../session/session_manager.dart';
import 'imagen_producto.dart';

/// [MEC-02, MEC-03, ADM-04] Detalle de una solicitud de repuestos (GET /solicitudes/{num}).
/// Muestra repuestos, estado y, si fue rechazada, el motivo del rechazo.
/// Si [accionesAdmin] es true y la solicitud está PENDIENTE, permite aprobar o rechazar.
/// Devuelve true si el administrador cambió el estado.
Future<bool?> mostrarDetalleSolicitud(BuildContext context, String solicitudNum, {bool accionesAdmin = false}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundGray,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    // [H-ADM-02] El panel se eleva junto con el teclado al escribir el motivo
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (ctx, scroll) => _DetalleSolicitud(num: solicitudNum, scroll: scroll, accionesAdmin: accionesAdmin),
      ),
    ),
  );
}

/// Extrae el código de solicitud (SOL-2026-0001) de un texto, p. ej. el mensaje de una notificación
String? extraerCodigoSolicitud(String texto) => RegExp(r'SOL-\d{4}-\d+').firstMatch(texto)?.group(0);

Color colorEstadoSolicitud(String estado) {
  switch (estado.toUpperCase()) {
    case 'APROBADA':
    case 'ENTREGADA':
      return Colors.green[700]!;
    case 'APROBADA_PARCIAL':
      return Colors.lightGreen[800]!;
    case 'RECHAZADA':
      return AppColors.errorRed;
    case 'ORDEN_CONTACTADA':
      return Colors.teal;
    default:
      return Colors.amber[800]!;
  }
}

String etiquetaEstadoSolicitud(String estado) {
  switch (estado.toUpperCase()) {
    case 'PENDIENTE':
      return 'Pendiente';
    case 'APROBADA':
      return 'Aprobada';
    case 'APROBADA_PARCIAL':
      return 'Aprobada parcial';
    case 'RECHAZADA':
      return 'Rechazada';
    case 'ORDEN_CONTACTADA':
      return 'Orden a proveedor';
    case 'ENTREGADA':
      return 'Entregada';
    default:
      return estado;
  }
}

class _DetalleSolicitud extends StatefulWidget {
  final String num;
  final ScrollController scroll;
  final bool accionesAdmin;
  const _DetalleSolicitud({required this.num, required this.scroll, required this.accionesAdmin});

  @override
  State<_DetalleSolicitud> createState() => _DetalleSolicitudState();
}

class _DetalleSolicitudState extends State<_DetalleSolicitud> {
  final DioClient _dio = DioClient();
  Map<String, dynamic>? _d;
  String? _error;
  bool _procesando = false;
  /// [ADM-05] Dictamen por repuesto (número de ítem -> aprobado)
  final Map<dynamic, bool> _dictamen = {};
  final _motivoCtrl = TextEditingController();
  final FocusNode _motivoFocus = FocusNode();
  String? _motivoError;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _motivoFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final res = await _dio.dio.get('/solicitudes/${widget.num}');
      setState(() => _d = Map<String, dynamic>.from(res.data));
    } catch (e) {
      setState(() => _error = mensajeDeError(e));
    }
  }

  Future<void> _aprobar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprobar solicitud'),
        content: Text('¿Confirma la aprobación total de ${widget.num}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _ejecutar(() async {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/solicitudes/${widget.num}/aprobar', queryParameters: {'correoAdmin': correo});
    }, 'Solicitud aprobada');
  }

  Future<void> _rechazar() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              hintText: 'El mecánico verá este motivo',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 15) ? 'Mínimo 15 caracteres' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _ejecutar(() async {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/solicitudes/${widget.num}/rechazar',
          queryParameters: {'correoAdmin': correo}, data: {'justificacionRechazo': ctrl.text.trim()});
    }, 'Solicitud rechazada');
  }

  /// [ADM-05, RF26] Aprueba unos repuestos y rechaza otros
  Future<void> _aprobarParcial(List<Map> repuestos) async {
    final rechazados = repuestos.where((r) => _dictamen[r['item']] == false).toList();
    final motivo = _motivoCtrl.text.trim();
    if (motivo.length < 10) {
      setState(() => _motivoError = 'Escriba el motivo de los repuestos rechazados (mínimo 10 caracteres).');
      _motivoFocus.requestFocus();
      return;
    }
    setState(() => _motivoError = null);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprobar parcialmente'),
        content: Text('Se aprobarán ${repuestos.length - rechazados.length} de ${repuestos.length} repuestos.\n'
            'Rechazados: ${rechazados.map((r) => r['nombreRepuesto']).join(', ')}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen[800], foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _ejecutar(() async {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/solicitudes/${widget.num}/aprobar-parcial', queryParameters: {'correoAdmin': correo}, data: {
        'items': repuestos
            .map((r) => {
                  'item': r['item'],
                  'aprobado': _dictamen[r['item']] != false,
                  if (_dictamen[r['item']] == false) 'motivoRechazoItem': motivo,
                })
            .toList(),
      });
    }, 'Solicitud aprobada parcialmente');
  }

  /// Todos los repuestos rechazados: rechazo total con el motivo escrito
  Future<void> _rechazarConMotivo() async {
    final motivo = _motivoCtrl.text.trim();
    if (motivo.length < 15) {
      setState(() => _motivoError = 'Para rechazar toda la solicitud, el motivo debe tener al menos 15 caracteres.');
      _motivoFocus.requestFocus();
      return;
    }
    setState(() => _motivoError = null);
    await _ejecutar(() async {
      final correo = await SessionManager.correo();
      await _dio.dio.put('/solicitudes/${widget.num}/rechazar',
          queryParameters: {'correoAdmin': correo}, data: {'justificacionRechazo': motivo});
    }, 'Solicitud rechazada');
  }

  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    setState(() => _procesando = true);
    try {
      await accion();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exito), backgroundColor: Colors.green[700]));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final handle = Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)),
      ),
    );
    if (_error != null) {
      return ListView(controller: widget.scroll, padding: const EdgeInsets.all(24), children: [
        handle,
        const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
        const SizedBox(height: 10),
        Text('No se pudo cargar ${widget.num}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      ]);
    }
    if (_d == null) {
      return ListView(controller: widget.scroll, children: [
        const SizedBox(height: 20),
        handle,
        const SizedBox(height: 60),
        const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      ]);
    }
    final d = _d!;
    final estado = d['estado']?.toString() ?? 'PENDIENTE';
    final repuestos = (d['repuestos'] as List?)?.cast<Map>() ?? const [];
    final rechazo = d['rechazo'] as Map?;
    final color = colorEstadoSolicitud(estado);
    final evaluando = widget.accionesAdmin && estado == 'PENDIENTE';
    final nRechazados = repuestos.where((r) => _dictamen[r['item']] == false).length;

    return ListView(
      controller: widget.scroll,
      // [H-GEN-07] Margen inferior que respeta la barra de navegación del teléfono
      padding: EdgeInsets.fromLTRB(16, 8, 16, 32 + MediaQuery.of(context).padding.bottom),
      children: [
        handle,
        Row(
          children: [
            Expanded(
              child: Text(widget.num,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Text(etiquetaEstadoSolicitud(estado),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Motivo del rechazo destacado (MEC-03)
        if (estado == 'RECHAZADA' || rechazo != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cancel_outlined, color: AppColors.errorRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Motivo del rechazo',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                      const SizedBox(height: 4),
                      Text(rechazo?['justificacionRechazo']?.toString() ?? 'Administración no registró un motivo.'),
                      if (rechazo?['evaluador'] != null || rechazo?['fechaEvaluacion'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (rechazo?['evaluador'] != null) 'Por: ${rechazo!['evaluador']}',
                            if (rechazo?['fechaEvaluacion'] != null) 'Fecha: ${rechazo!['fechaEvaluacion']}',
                          ].join('  ·  '),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        _Seccion(children: [
          _Dato(icono: Icons.event_rounded, etiqueta: 'Emitida', valor: '${d['fechaEmision'] ?? ''} ${(d['horaEmision'] ?? '').toString().split('.').first}'),
          _Dato(icono: Icons.flag_rounded, etiqueta: 'Prioridad', valor: '${d['prioridad'] ?? '-'}'),
          _Dato(icono: Icons.precision_manufacturing_rounded, etiqueta: 'Maquinaria', valor: '${d['codMaquinaria'] ?? '-'} ${d['modeloMaquinaria'] ?? ''}'),
          _Dato(icono: Icons.engineering_rounded, etiqueta: 'Mecánico', valor: '${d['nombreMecanico'] ?? '-'}'),
          if ((d['justificacionTecnica'] ?? '').toString().isNotEmpty)
            _Dato(icono: Icons.notes_rounded, etiqueta: 'Justificación', valor: '${d['justificacionTecnica']}'),
        ]),
        const SizedBox(height: 14),
        Text('Repuestos solicitados (${repuestos.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        if (evaluando)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.touch_app_outlined, size: 18, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text('Decida repuesto por repuesto. Puede aprobar solo los que correspondan.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primaryBlue)),
              ),
            ]),
          ),
        ...repuestos.map((r) {
          final ei = r['estadoItem']?.toString() ?? 'PENDIENTE';
          final c = ei == 'APROBADO' ? Colors.green[700]! : ei == 'RECHAZADO' ? AppColors.errorRed : Colors.amber[800]!;
          final item = r['item'];
          final aprobado = _dictamen[item] != false;
          final stock = (r['stockActual'] as num?)?.toInt();
          final cant = (r['cantidadSolicitada'] as num?)?.toInt() ?? 0;
          return Card(
            color: evaluando && !aprobado ? AppColors.errorRed.withValues(alpha: 0.05) : AppColors.pureWhite,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: evaluando
                  ? BorderSide(color: aprobado ? Colors.green.shade300 : AppColors.errorRed.withValues(alpha: 0.5))
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Row(children: [
                  ImagenProducto(url: r['imagenUrl']?.toString(), size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${r['nombreRepuesto'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${r['codParte'] ?? ''}  ·  Cantidad: $cant',
                          style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                      if (evaluando && stock != null)
                        Text('Stock actual: $stock',
                            style: TextStyle(fontSize: 12, color: stock < cant ? AppColors.errorRed : Colors.green[700])),
                    ]),
                  ),
                  if (!evaluando)
                    Text(ei[0] + ei.substring(1).toLowerCase(),
                        style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
                if (evaluando) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, icon: Icon(Icons.check_rounded), label: Text('Aprobar')),
                        ButtonSegment(value: false, icon: Icon(Icons.close_rounded), label: Text('Rechazar')),
                      ],
                      selected: {aprobado},
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        selectedBackgroundColor: aprobado ? Colors.green[700] : AppColors.errorRed,
                        selectedForegroundColor: Colors.white,
                      ),
                      onSelectionChanged: (v) => setState(() => _dictamen[item] = v.first),
                    ),
                  ),
                ],
              ]),
            ),
          );
        }),
        if (evaluando) ...[
          if (nRechazados > 0) ...[
            const SizedBox(height: 6),
            TextField(
              controller: _motivoCtrl,
              focusNode: _motivoFocus,
              maxLines: 2,
              // [H-ADM-02] Mantiene visibles los botones de decisión bajo el campo
              scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
              onChanged: (v) {
                if (_motivoError != null) setState(() => _motivoError = null);
              },
              decoration: InputDecoration(
                labelText: nRechazados == repuestos.length
                    ? 'Motivo del rechazo (mín. 15 caracteres)'
                    : 'Motivo de los repuestos rechazados (mín. 10 caracteres)',
                helperText: 'El mecánico verá este motivo en su historial',
                errorText: _motivoError,
                filled: true,
                fillColor: AppColors.pureWhite,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (nRechazados == 0)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _procesando ? null : _rechazar,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Rechazar todo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _procesando ? null : _aprobar,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aprobar todo'),
                  ),
                ),
              ],
            )
          else if (nRechazados < repuestos.length)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _procesando ? null : () => _aprobarParcial(repuestos),
              icon: const Icon(Icons.rule_rounded),
              label: Text('Aprobar parcialmente (${repuestos.length - nRechazados} de ${repuestos.length})'),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _procesando ? null : _rechazarConMotivo,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Rechazar solicitud'),
            ),
        ],
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  final List<Widget> children;
  const _Seccion({required this.children});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12)),
        child: Column(children: children),
      );
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _Dato({required this.icono, required this.etiqueta, required this.valor});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            SizedBox(width: 95, child: Text(etiqueta, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

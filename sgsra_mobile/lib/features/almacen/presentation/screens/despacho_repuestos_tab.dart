import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/detalle_solicitud_sheet.dart';
import '../../data/datasources/almacen_remote_datasource.dart';

/// [ALM-01] Salida formal de repuestos por solicitud.
/// Lista las solicitudes aprobadas por administración (urgentes primero) y permite
/// confirmar el despacho, que descuenta el stock en todos los roles.
class DespachoRepuestosTab extends StatefulWidget {
  /// Informa cuántas solicitudes faltan despachar (para el contador de la pestaña)
  final ValueChanged<int>? onPendientes;
  const DespachoRepuestosTab({super.key, this.onPendientes});

  @override
  State<DespachoRepuestosTab> createState() => _DespachoRepuestosTabState();
}

class _DespachoRepuestosTabState extends State<DespachoRepuestosTab> {
  final AlmacenRemoteDataSource _ds = AlmacenRemoteDataSource(DioClient());
  bool _cargando = true;
  String? _error;
  bool _verEntregadas = false;
  List<Map<String, dynamic>> _porDespachar = [];
  List<Map<String, dynamic>> _entregadas = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await Future.wait([
        _ds.listarSolicitudesPorEstado('APROBADA'),
        _ds.listarSolicitudesPorEstado('APROBADA_PARCIAL'),
        _ds.listarSolicitudesPorEstado('ENTREGADA'),
      ]);
      final pendientes = [...r[0], ...r[1]]
        // Urgentes primero y, dentro de la misma prioridad, la más antigua primero
        ..sort((a, b) {
          final p = _pesoPrioridad(a['prioridad']).compareTo(_pesoPrioridad(b['prioridad']));
          return p != 0 ? p : _fechaHora(a).compareTo(_fechaHora(b));
        });
      final entregadas = r[2]..sort((a, b) => _fechaHora(b).compareTo(_fechaHora(a)));
      if (!mounted) return;
      setState(() {
        _porDespachar = pendientes;
        _entregadas = entregadas;
        _cargando = false;
      });
      widget.onPendientes?.call(pendientes.length);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = mensajeDeError(e);
      });
    }
  }

  static int _pesoPrioridad(dynamic p) => switch ('$p'.toUpperCase()) { 'ALTA' => 0, 'MEDIA' => 1, _ => 2 };
  static String _fechaHora(Map s) => '${s['fechaEmision'] ?? ''} ${s['horaEmision'] ?? ''}';

  Future<void> _abrir(Map<String, dynamic> s) async {
    final num = '${s['solicitudNum']}';
    if (_verEntregadas) {
      await mostrarDetalleSolicitud(context, num);
      return;
    }
    final despachada = await mostrarDespachoSolicitud(context, num);
    if (despachada == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    final lista = _verEntregadas ? _entregadas : _porDespachar;
    final urgentes = _porDespachar.where((s) => _pesoPrioridad(s['prioridad']) == 0).length;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Salida Formal de Repuestos por Solicitud',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  const SizedBox(height: 4),
                  const Text('Entregue los repuestos aprobados por administración. Al confirmar se descuenta el stock.',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                          value: false,
                          icon: const Icon(Icons.local_shipping_outlined),
                          label: Text('Por despachar (${_porDespachar.length})')),
                      ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.task_alt_rounded),
                          label: Text('Entregadas (${_entregadas.length})')),
                    ],
                    selected: {_verEntregadas},
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.primaryBlue,
                      selectedForegroundColor: Colors.white,
                    ),
                    onSelectionChanged: (v) => setState(() => _verEntregadas = v.first),
                  ),
                  const SizedBox(height: 12),
                  if (!_verEntregadas && urgentes > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.priority_high_rounded, color: AppColors.errorRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            urgentes == 1
                                ? '1 solicitud urgente (prioridad ALTA). Atiéndala primero.'
                                : '$urgentes solicitudes urgentes (prioridad ALTA). Atiéndalas primero.',
                            style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                    ),
                  if (_error != null)
                    _Vacio(
                      icono: Icons.cloud_off_rounded,
                      titulo: 'No se pudieron cargar las solicitudes',
                      detalle: _error!,
                      onReintentar: _cargar,
                    )
                  else if (lista.isEmpty)
                    _Vacio(
                      icono: _verEntregadas ? Icons.inventory_outlined : Icons.check_circle_outline_rounded,
                      titulo: _verEntregadas ? 'Aún no hay entregas' : 'Todo despachado',
                      detalle: _verEntregadas
                          ? 'Aquí aparecerán las solicitudes que ya entregó.'
                          : 'No hay solicitudes aprobadas esperando sus repuestos.',
                    )
                  else
                    ...lista.map((s) => _TarjetaSolicitud(s: s, entregada: _verEntregadas, onTap: () => _abrir(s))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color colorPrioridad(dynamic p) => switch ('$p'.toUpperCase()) {
      'ALTA' => AppColors.errorRed,
      'MEDIA' => Colors.amber[800]!,
      _ => Colors.blueGrey,
    };

class _TarjetaSolicitud extends StatelessWidget {
  final Map<String, dynamic> s;
  final bool entregada;
  final VoidCallback onTap;
  const _TarjetaSolicitud({required this.s, required this.entregada, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prioridad = '${s['prioridad'] ?? 'MEDIA'}';
    final cp = colorPrioridad(prioridad);
    final estado = '${s['estado'] ?? ''}';
    final hora = '${s['horaEmision'] ?? ''}'.split('.').first;
    final hora5 = hora.length >= 5 ? hora.substring(0, 5) : hora;
    return Card(
      color: AppColors.pureWhite,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: entregada ? Colors.green[700] : cp),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text('${s['solicitudNum']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                        ),
                        _Pill(
                          texto: entregada ? 'Entregada' : 'Prioridad ${prioridad[0]}${prioridad.substring(1).toLowerCase()}',
                          color: entregada ? Colors.green[700]! : cp,
                        ),
                      ]),
                      const SizedBox(height: 8),
                      _Linea(Icons.engineering_rounded, '${s['nombreMecanico'] ?? 'Mecánico'}'),
                      _Linea(Icons.precision_manufacturing_rounded,
                          '${s['codMaquinaria'] ?? '-'} ${s['modeloMaquinaria'] ?? ''}'.trim()),
                      _Linea(Icons.event_rounded,
                          '${s['fechaEmision'] ?? ''} $hora5  ·  ${s['totalComponentes'] ?? 0} repuesto(s)'),
                      if (!entregada && estado == 'APROBADA_PARCIAL')
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('Aprobada parcialmente: solo se entregan los repuestos aprobados',
                              style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
                        ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: entregada
                            ? const Text('Ver detalle ›',
                                style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600))
                            : FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                                onPressed: onTap,
                                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                label: const Text('Preparar despacho'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [ALM-01] Hoja de despacho: lista de verificación de repuestos con el stock antes y después.
/// Devuelve true si el despacho se registró.
Future<bool?> mostrarDespachoSolicitud(BuildContext context, String solicitudNum) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundGray,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => _HojaDespacho(num: solicitudNum, scroll: scroll),
    ),
  );
}

class _HojaDespacho extends StatefulWidget {
  final String num;
  final ScrollController scroll;
  const _HojaDespacho({required this.num, required this.scroll});

  @override
  State<_HojaDespacho> createState() => _HojaDespachoState();
}

class _HojaDespachoState extends State<_HojaDespacho> {
  final AlmacenRemoteDataSource _ds = AlmacenRemoteDataSource(DioClient());
  Map<String, dynamic>? _d;
  String? _error;
  bool _enviando = false;
  final Set<String> _preparados = {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final d = await _ds.obtenerDetalleSolicitud(widget.num);
      if (mounted) setState(() => _d = d);
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeError(e));
    }
  }

  List<Map> get _items => (_d?['repuestos'] as List?)?.cast<Map>() ?? const [];
  List<Map> get _aprobados => _items.where((r) => '${r['estadoItem']}' == 'APROBADO').toList();
  List<Map> get _noEntregables => _items.where((r) => '${r['estadoItem']}' != 'APROBADO').toList();

  static int _cant(Map r) => (r['cantidadSolicitada'] as num?)?.toInt() ?? 0;
  static int? _stock(Map r) => (r['stockActual'] as num?)?.toInt();
  static bool _insuficiente(Map r) => _stock(r) != null && _stock(r)! < _cant(r);

  Future<void> _confirmar() async {
    final aprobados = _aprobados;
    final unidades = aprobados.fold<int>(0, (a, r) => a + _cant(r));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar despacho'),
        content: Text(
          'Entregará ${aprobados.length} repuesto(s) ($unidades unidad(es)) a ${_d?['nombreMecanico'] ?? 'el mecánico'}.\n\n'
          'Se descontará del stock y el mecánico recibirá una notificación. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Sí, despachar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _enviando = true);
    try {
      final mensaje = await _ds.despacharSolicitud(widget.num);
      if (!mounted) return;
      await _mostrarExito(mensaje);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed));
    }
  }

  Future<void> _mostrarExito(String mensaje) {
    // El backend devuelve el resumen como "[COD: antes -> después]"
    final cambios = RegExp(r'\[([^:\]]+): (\d+) -> (\d+)\]').allMatches(mensaje).map((m) {
      final cod = m.group(1)!.trim();
      final r = _aprobados.firstWhere((x) => '${x['codParte']}' == cod, orElse: () => {});
      final despues = int.parse(m.group(3)!);
      final minimo = (r['stockMinimo'] as num?)?.toInt();
      return (
        nombre: '${r['nombreRepuesto'] ?? cod}',
        antes: int.parse(m.group(2)!),
        despues: despues,
        bajo: minimo != null && despues <= minimo,
      );
    }).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: Colors.green[700], size: 56),
        title: const Text('Despacho registrado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.num} quedó como Entregada y se notificó al mecánico.', textAlign: TextAlign.center),
              if (cambios.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('Stock actualizado', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...cambios.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Expanded(child: Text(c.nombre, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        Text('${c.antes}', style: const TextStyle(color: Colors.black54)),
                        const Icon(Icons.arrow_right_alt_rounded, size: 18, color: Colors.black54),
                        Text('${c.despues}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: c.bajo ? Colors.orange[800] : Colors.green[700])),
                      ]),
                    )),
                if (cambios.any((c) => c.bajo)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Algunos repuestos llegaron a su stock mínimo. Se avisó a administración para reponer.',
                            style: TextStyle(fontSize: 12.5)),
                      ),
                    ]),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
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
        _Vacio(icono: Icons.cloud_off_rounded, titulo: 'No se pudo cargar ${widget.num}', detalle: _error!),
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
    final estado = '${d['estado'] ?? ''}';
    final despachable = estado == 'APROBADA' || estado == 'APROBADA_PARCIAL';
    final aprobados = _aprobados;
    final hayInsuficiente = aprobados.any(_insuficiente);
    final todosListos = aprobados.isNotEmpty && aprobados.every((r) => _preparados.contains('${r['codParte']}'));
    final prioridad = '${d['prioridad'] ?? 'MEDIA'}';

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: widget.scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              handle,
              Row(children: [
                Expanded(
                  child: Text(widget.num,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ),
                _Pill(texto: etiquetaEstadoSolicitud(estado), color: colorEstadoSolicitud(estado)),
              ]),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.pureWhite, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _Dato(Icons.engineering_rounded, 'Entregar a', '${d['nombreMecanico'] ?? '-'}'),
                  if (d['dniMecanico'] != null) _Dato(Icons.badge_outlined, 'DNI', '${d['dniMecanico']}'),
                  if ((d['telefonoMecanico'] ?? '').toString().isNotEmpty)
                    _Dato(Icons.phone_outlined, 'Teléfono', '${d['telefonoMecanico']}'),
                  _Dato(Icons.precision_manufacturing_rounded, 'Maquinaria',
                      '${d['codMaquinaria'] ?? '-'} ${d['modeloMaquinaria'] ?? ''}'),
                  _Dato(Icons.flag_rounded, 'Prioridad', prioridad, color: colorPrioridad(prioridad)),
                ]),
              ),
              const SizedBox(height: 16),
              if (!despachable)
                _Aviso(
                  icono: Icons.info_outline_rounded,
                  color: AppColors.primaryBlue,
                  texto: estado == 'ENTREGADA'
                      ? 'Esta solicitud ya fue entregada.'
                      : 'Esta solicitud está "${etiquetaEstadoSolicitud(estado)}" y todavía no se puede despachar.',
                ),
              Row(children: [
                Expanded(
                  child: Text('Repuestos a entregar (${aprobados.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (despachable && aprobados.isNotEmpty && !todosListos)
                  TextButton(
                    onPressed: () => setState(() => _preparados.addAll(aprobados.map((r) => '${r['codParte']}'))),
                    child: const Text('Marcar todos'),
                  ),
              ]),
              if (despachable)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Marque cada repuesto cuando lo tenga listo para entregar.',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                ),
              ...aprobados.map((r) => _ItemDespacho(
                    r: r,
                    seleccionable: despachable,
                    marcado: _preparados.contains('${r['codParte']}'),
                    insuficiente: _insuficiente(r),
                    onChanged: (v) => setState(() {
                      final cod = '${r['codParte']}';
                      v ? _preparados.add(cod) : _preparados.remove(cod);
                    }),
                  )),
              if (_noEntregables.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('No se entregan (${_noEntregables.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 6),
                ..._noEntregables.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        const Icon(Icons.block_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${r['nombreRepuesto']} x${_cant(r)}',
                              style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        ),
                        Text('Rechazado por admin', style: TextStyle(fontSize: 11.5, color: Colors.grey[600])),
                      ]),
                    )),
              ],
            ],
          ),
        ),
        if (despachable)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(color: AppColors.pureWhite, boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2)),
              ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hayInsuficiente)
                    const _Aviso(
                      icono: Icons.error_outline_rounded,
                      color: AppColors.errorRed,
                      texto: 'No hay stock suficiente para todos los repuestos. Reponga el inventario antes de despachar.',
                    )
                  else if (!todosListos)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Preparados ${_preparados.length} de ${aprobados.length}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: (_enviando || hayInsuficiente || !todosListos) ? null : _confirmar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.local_shipping_rounded),
                    label: Text(_enviando ? 'Registrando…' : 'Confirmar despacho',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemDespacho extends StatelessWidget {
  final Map r;
  final bool seleccionable;
  final bool marcado;
  final bool insuficiente;
  final ValueChanged<bool> onChanged;
  const _ItemDespacho({
    required this.r,
    required this.seleccionable,
    required this.marcado,
    required this.insuficiente,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cant = (r['cantidadSolicitada'] as num?)?.toInt() ?? 0;
    final stock = (r['stockActual'] as num?)?.toInt();
    final minimo = (r['stockMinimo'] as num?)?.toInt();
    final despues = stock == null ? null : stock - cant;
    final bajo = despues != null && minimo != null && despues <= minimo;

    Widget stockInfo;
    if (stock == null) {
      stockInfo = const SizedBox.shrink();
    } else if (insuficiente) {
      stockInfo = Text('Stock insuficiente: hay $stock',
          style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600, fontSize: 12.5));
    } else {
      stockInfo = Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Stock: $stock', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
        const Icon(Icons.arrow_right_alt_rounded, size: 16, color: Colors.black54),
        Text('$despues',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.bold, color: bajo ? Colors.orange[800] : Colors.green[700])),
        if (bajo)
          Text('  (llega al mínimo)', style: TextStyle(fontSize: 11.5, color: Colors.orange[800])),
      ]);
    }

    return Card(
      color: marcado ? Colors.green[50] : AppColors.pureWhite,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: insuficiente
                ? AppColors.errorRed.withValues(alpha: 0.6)
                : marcado
                    ? Colors.green[300]!
                    : Colors.transparent),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: seleccionable && !insuficiente ? () => onChanged(!marcado) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(children: [
            if (seleccionable)
              Checkbox(
                value: marcado,
                activeColor: Colors.green[700],
                onChanged: insuficiente ? null : (v) => onChanged(v ?? false),
              ),
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('x$cant',
                  style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r['nombreRepuesto'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${r['codParte'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 3),
                  stockInfo,
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String texto;
  final Color color;
  const _Pill({required this.texto, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(texto, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11.5)),
      );
}

class _Linea extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Linea(this.icono, this.texto);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Icon(icono, size: 16, color: Colors.black45),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13.5))),
        ]),
      );
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color? color;
  const _Dato(this.icono, this.etiqueta, this.valor, {this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icono, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          SizedBox(width: 90, child: Text(etiqueta, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(valor, style: TextStyle(fontWeight: FontWeight.w600, color: color))),
        ]),
      );
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  const _Aviso({required this.icono, required this.color, required this.texto});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: TextStyle(color: color, fontSize: 13))),
        ]),
      );
}

class _Vacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback? onReintentar;
  const _Vacio({required this.icono, required this.titulo, required this.detalle, this.onReintentar});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Column(children: [
          Icon(icono, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(detalle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          if (onReintentar != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: onReintentar, icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
          ],
        ]),
      );
}

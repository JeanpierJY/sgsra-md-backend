import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/widgets/detalle_solicitud_sheet.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF21, RF22, RF31, ADM-05, ADM-06] Bandeja con todas las solicitudes del taller.
/// Filtros por estado (con contador), periodo y texto. Al tocar una solicitud se abre su
/// detalle, donde el administrador decide repuesto por repuesto.
class BandejaSolicitudesScreen extends StatefulWidget {
  const BandejaSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<BandejaSolicitudesScreen> createState() =>
      _BandejaSolicitudesScreenState();
}

class _BandejaSolicitudesScreenState extends State<BandejaSolicitudesScreen> {
  final DioClient _dioClient = DioClient();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _solicitudes = [];
  String _filtroEstado = 'TODAS';
  int _periodoDias = 0; // 0 = todo
  String _busqueda = '';

  static const _estados = {
    'TODAS': 'Todas',
    'PENDIENTE': 'Pendientes',
    'APROBADA': 'Aprobadas',
    'ENTREGADA': 'Entregadas',
    'RECHAZADA': 'Rechazadas',
  };

  @override
  void initState() {
    super.initState();
    _cargarBandeja();
  }

  Future<void> _cargarBandeja() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _dioClient.dio.get('/solicitudes/bandeja');
      final lista = (res.data is List ? res.data as List : const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList()
        ..sort((a, b) => '${b['fechaEmision']} ${b['horaEmision']}'
            .compareTo('${a['fechaEmision']} ${a['horaEmision']}'));
      if (!mounted) return;
      setState(() {
        _solicitudes = lista;
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

  bool _coincideEstado(Map s, String filtro) {
    final e = '${s['estado']}';
    if (filtro == 'TODAS') return true;
    if (filtro == 'APROBADA') return e == 'APROBADA' || e == 'APROBADA_PARCIAL';
    return e == filtro;
  }

  bool _enPeriodo(Map s) {
    if (_periodoDias == 0) return true;
    final f = DateTime.tryParse('${s['fechaEmision']}');
    if (f == null) return true;
    final hoy = DateTime.now();
    final desde = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(Duration(days: _periodoDias - 1));
    return !f.isBefore(desde);
  }

  bool _coincideTexto(Map s) {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '${s['solicitudNum']} ${s['nombreMecanico']} ${s['codMaquinaria']} ${s['modeloMaquinaria']}'
        .toLowerCase()
        .contains(q);
  }

  Future<void> _abrir(Map s) async {
    final cambio = await mostrarDetalleSolicitud(
        context, '${s['solicitudNum']}',
        accionesAdmin: true);
    if (cambio == true) _cargarBandeja();
  }

  void _mostrarModalContactarProveedor(String solicitudNum) {
    final formKey = GlobalKey<FormState>();
    final cotizacionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Orden a proveedor: $solicitudNum'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: cotizacionCtrl,
            decoration: const InputDecoration(
              labelText: 'Código de cotización (ej. COT-2026-99)',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Ingrese el número de cotización'
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final correo = await SessionManager.correo();
                await _dioClient.dio.put(
                  '/solicitudes/$solicitudNum/contactar',
                  queryParameters: {'correoAdmin': correo},
                  data: {'codigoCotizacion': cotizacionCtrl.text.trim()},
                );
                messenger.showSnackBar(const SnackBar(
                    content: Text(
                        'Orden marcada como contactada con el proveedor')));
                _cargarBandeja();
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                    content: Text(mensajeDeError(e)),
                    backgroundColor: AppColors.errorRed));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base =
        _solicitudes.where((s) => _enPeriodo(s) && _coincideTexto(s)).toList();
    final lista = base.where((s) => _coincideEstado(s, _filtroEstado)).toList();
    final pendientes =
        _solicitudes.where((s) => s['estado'] == 'PENDIENTE').toList();
    final urgentes = pendientes.where((s) => s['prioridad'] == 'ALTA').length;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Bandeja de Solicitudes [RF21]',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Actualizar',
              onPressed: _cargarBandeja),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por código, mecánico o máquina',
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.backgroundGray,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() => _busqueda = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    tooltip: 'Periodo [RF31]',
                    initialValue: _periodoDias,
                    onSelected: (v) => setState(() => _periodoDias = v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 0, child: Text('Todo')),
                      PopupMenuItem(value: 1, child: Text('Hoy')),
                      PopupMenuItem(value: 7, child: Text('Últimos 7 días')),
                      PopupMenuItem(value: 30, child: Text('Últimos 30 días')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: _periodoDias == 0
                            ? AppColors.backgroundGray
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.date_range_rounded,
                            size: 18,
                            color: _periodoDias == 0
                                ? Colors.black54
                                : Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          switch (_periodoDias) {
                            0 => 'Todo',
                            1 => 'Hoy',
                            _ => '$_periodoDias d'
                          },
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _periodoDias == 0
                                  ? Colors.black54
                                  : Colors.white),
                        ),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _estados.entries.map((f) {
                      final sel = _filtroEstado == f.key;
                      final n =
                          base.where((s) => _coincideEstado(s, f.key)).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${f.value} ($n)'),
                          selected: sel,
                          showCheckmark: false,
                          selectedColor: f.key == 'TODAS'
                              ? AppColors.primaryBlue
                              : colorEstadoSolicitud(f.key),
                          labelStyle: TextStyle(
                              color: sel ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600),
                          onSelected: (_) =>
                              setState(() => _filtroEstado = f.key),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading &&
              pendientes.isNotEmpty &&
              _filtroEstado != 'PENDIENTE')
            Material(
              color: Colors.amber[50],
              child: InkWell(
                onTap: () => setState(() => _filtroEstado = 'PENDIENTE'),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Icon(Icons.pending_actions_rounded,
                        color: Colors.amber[900]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${pendientes.length} pendiente(s) por evaluar${urgentes > 0 ? ' · $urgentes urgente(s)' : ''}',
                        style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('Ver',
                        style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _cargarBandeja,
                    child: _error != null
                        ? ListView(children: [
                            const SizedBox(height: 80),
                            const Icon(Icons.cloud_off_rounded,
                                size: 60, color: Colors.grey),
                            const SizedBox(height: 8),
                            Center(
                                child:
                                    Text(_error!, textAlign: TextAlign.center)),
                            Center(
                              child: TextButton.icon(
                                  onPressed: _cargarBandeja,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar')),
                            ),
                          ])
                        : lista.isEmpty
                            ? ListView(children: [
                                const SizedBox(height: 80),
                                Icon(Icons.inbox_outlined,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    _filtroEstado == 'PENDIENTE'
                                        ? '¡Todo al día! No hay solicitudes por evaluar.'
                                        : 'No hay solicitudes con estos filtros.',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.all(14),
                                itemCount: lista.length,
                                itemBuilder: (context, index) =>
                                    _tarjeta(lista[index]),
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> sol) {
    final estado = '${sol['estado'] ?? 'PENDIENTE'}';
    final esPendiente = estado == 'PENDIENTE';
    final esAprobada = estado == 'APROBADA' || estado == 'APROBADA_PARCIAL';
    final prioridad = '${sol['prioridad'] ?? 'MEDIA'}';
    final cPrioridad = switch (prioridad) {
      'ALTA' => AppColors.errorRed,
      'MEDIA' => Colors.amber[800]!,
      _ => Colors.blueGrey
    };
    final cEstado = colorEstadoSolicitud(estado);
    final hora = '${sol['horaEmision'] ?? ''}';

    return Card(
      color: AppColors.pureWhite,
      elevation: esPendiente ? 3 : 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _abrir(sol),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: esPendiente ? cPrioridad : cEstado),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text('${sol['solicitudNum'] ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryBlue)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: cEstado,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(etiquetaEstadoSolicitud(estado),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      _linea(Icons.engineering_rounded,
                          '${sol['nombreMecanico'] ?? 'Mecánico'}'),
                      _linea(
                          Icons.precision_manufacturing_rounded,
                          '${sol['codMaquinaria'] ?? '-'} ${sol['modeloMaquinaria'] ?? ''}'
                              .trim()),
                      Row(children: [
                        Expanded(
                          child: _linea(Icons.event_rounded,
                              '${sol['fechaEmision'] ?? ''} ${hora.length >= 5 ? hora.substring(0, 5) : hora}  ·  ${sol['totalComponentes'] ?? 0} repuesto(s)'),
                        ),
                        Text(
                            'Prioridad ${prioridad[0]}${prioridad.substring(1).toLowerCase()}',
                            style: TextStyle(
                                color: cPrioridad,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (esPendiente)
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue),
                              onPressed: () => _abrir(sol),
                              icon: const Icon(Icons.fact_check_outlined,
                                  size: 18),
                              label: const Text('Evaluar'),
                            )
                          else
                            const Text('Ver detalle ›',
                                style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600)),
                        ],
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

  Widget _linea(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(children: [
          Icon(i, size: 16, color: Colors.black45),
          const SizedBox(width: 6),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 13.5))),
        ]),
      );
}

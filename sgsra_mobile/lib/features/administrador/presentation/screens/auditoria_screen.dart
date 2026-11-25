import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF49, ADM-02, ADM-03] Bitácora de auditoría.
/// Muestra solo datos reales del servidor, en lenguaje claro, agrupados por día,
/// con filtros por categoría y periodo. El hash SHA-256 queda disponible al expandir.
class AuditoriaScreen extends StatefulWidget {
  const AuditoriaScreen({super.key});

  @override
  State<AuditoriaScreen> createState() => _AuditoriaScreenState();
}

class _Categoria {
  final String nombre;
  final IconData icono;
  final Color color;
  const _Categoria(this.nombre, this.icono, this.color);
}

class _AuditoriaScreenState extends State<AuditoriaScreen> {
  final DioClient _dioClient = DioClient();
  final TextEditingController _buscarCtrl = TextEditingController();

  bool _isLoading = true;
  bool _cargandoMas = false;
  bool _hayMas = false;
  int _pagina = 0;
  String? _error;
  List<Map<String, dynamic>> _logs = [];
  String _categoria = 'Todas';
  int _dias = 7;

  static const _periodos = {1: 'Hoy', 7: '7 días', 30: '30 días', 180: '6 meses'};

  static final Map<String, _Categoria> _categorias = {
    'Solicitudes': _Categoria('Solicitudes', Icons.receipt_long_rounded, AppColors.primaryBlue),
    'Préstamos': _Categoria('Préstamos', Icons.handyman_rounded, Colors.teal),
    'Seguridad': _Categoria('Seguridad', Icons.shield_outlined, AppColors.errorRed),
    'Sesiones': _Categoria('Sesiones', Icons.login_rounded, Colors.indigo),
    'Personal': _Categoria('Personal', Icons.people_alt_outlined, Colors.deepPurple),
    'Inventario': _Categoria('Inventario', Icons.inventory_2_outlined, Colors.brown),
    'Otros': _Categoria('Otros', Icons.history_rounded, Colors.blueGrey),
  };

  /// Traducción de los códigos de acción a lenguaje natural
  static const Map<String, String> _acciones = {
    'SOLICITUD_CREADA': 'Creó una solicitud de repuestos',
    'SOLICITUD_APROBADA_TOTAL': 'Aprobó una solicitud',
    'SOLICITUD_APROBADA_PARCIAL': 'Aprobó parcialmente una solicitud',
    'SOLICITUD_RECHAZADA_TOTAL': 'Rechazó una solicitud',
    'ORDEN_CONTACTADA_PROVEEDOR': 'Contactó al proveedor por una solicitud',
    'ENTREGA_DESPACHO_REPUESTOS': 'Entregó los repuestos de una solicitud',
    'PRESTAMO_HERRAMIENTAS': 'Registró un préstamo de herramientas',
    'DEVOLUCION_HERRAMIENTAS': 'Recibió la devolución de herramientas',
    'LOGIN_EXITOSO': 'Inició sesión',
    'SESION_INICIADA': 'Inició sesión',
    'LOGIN_FALLIDO': 'Intento de acceso fallido',
    'CONTRASENA_INCORRECTA': 'Ingresó una contraseña incorrecta',
    'INTENTO_CUENTA_BLOQUEADA': 'Intentó ingresar con la cuenta bloqueada',
    'BLOQUEO_TOTAL_POR_INTENTOS': 'Cuenta bloqueada por intentos fallidos',
    'RECUPERACION_CLAVE_APROBADA': 'Aprobó una recuperación de contraseña',
    'RECUPERACION_CLAVE_RECHAZADA': 'Rechazó una recuperación de contraseña',
    'DATOS_PERSONAL_ACTUALIZADOS': 'Actualizó los datos de un trabajador',
  };

  @override
  void initState() {
    super.initState();
    _cargarAuditoria();
  }

  static String _textoAccion(String accion) {
    if (_acciones.containsKey(accion)) return _acciones[accion]!;
    if (accion.startsWith('BLOQUEO_TEMPORAL_')) {
      return 'Cuenta bloqueada ${accion.replaceAll(RegExp(r'[^0-9]'), '')} minutos por intentos fallidos';
    }
    if (accion.startsWith('EXTRAVIO_IMPUTADO')) return 'Reportó el extravío de una herramienta';
    final t = accion.replaceAll('_', ' ').toLowerCase();
    return t.isEmpty ? accion : t[0].toUpperCase() + t.substring(1);
  }

  static _Categoria _categoriaDe(Map log) {
    final a = (log['accion'] ?? '').toString();
    final op = (log['idOperacion'] ?? '').toString();
    if (a.contains('SOLICITUD') || a.contains('ORDEN') || a.contains('ENTREGA') || op.startsWith('SOL-')) {
      return _categorias['Solicitudes']!;
    }
    if (a.contains('PRESTAMO') || a.contains('DEVOLUCION') || a.contains('EXTRAVIO')) return _categorias['Préstamos']!;
    if (a.contains('BLOQUEO') || a.contains('FALLIDO') || a.contains('RECUPERACION') || a.contains('CONTRASENA') || a.contains('BLOQUEADA')) {
      return _categorias['Seguridad']!;
    }
    if (a.contains('LOGIN') || a.contains('SESION')) return _categorias['Sesiones']!;
    if (a.contains('PERSONAL') || a.contains('USUARIO') || a.contains('CUENTA')) return _categorias['Personal']!;
    if (a.contains('REPUESTO') || a.contains('HERRAMIENTA') || a.contains('CATALOGO') || a.contains('STOCK')) {
      return _categorias['Inventario']!;
    }
    return _categorias['Otros']!;
  }

  Future<void> _cargarAuditoria({bool mas = false}) async {
    setState(() {
      if (mas) {
        _cargandoMas = true;
      } else {
        _isLoading = true;
        _error = null;
        _pagina = 0;
      }
    });
    try {
      final ahora = DateTime.now();
      final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
      final fechaInicio = inicioHoy.subtract(Duration(days: _dias - 1));
      final fechaFin = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
      final pagina = mas ? _pagina + 1 : 0;

      final params = <String, dynamic>{
        'page': pagina,
        'size': 50,
        'inicio': fechaInicio.toIso8601String(),
        'fin': fechaFin.toIso8601String(),
      };
      final busqueda = _buscarCtrl.text.trim();
      if (busqueda.isNotEmpty) params['idOperacion'] = busqueda;

      final res = await _dioClient.dio.get('/auditoria', queryParameters: params);
      final contenido = (res.data is Map && res.data['content'] is List)
          ? (res.data['content'] as List).map((e) => Map<String, dynamic>.from(e)).toList()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _logs = mas ? [..._logs, ...contenido] : contenido;
        _pagina = pagina;
        _hayMas = res.data is Map && res.data['last'] == false;
        _isLoading = false;
        _cargandoMas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _cargandoMas = false;
        _error = mensajeDeError(e);
      });
    }
  }

  List<Map<String, dynamic>> get _filtrados =>
      _categoria == 'Todas' ? _logs : _logs.where((l) => _categoriaDe(l).nombre == _categoria).toList();

  static String _etiquetaDia(DateTime d) {
    final hoy = DateTime.now();
    final h = DateTime(hoy.year, hoy.month, hoy.day);
    final x = DateTime(d.year, d.month, d.day);
    final diff = h.difference(x).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${meses[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;
    final filas = <Widget>[];
    String? diaActual;
    for (final log in lista) {
      final ts = DateTime.tryParse('${log['timestamp']}');
      final dia = ts == null ? 'Sin fecha' : _etiquetaDia(ts);
      if (dia != diaActual) {
        diaActual = dia;
        filas.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(dia, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        ));
      }
      filas.add(_EventoTile(log: log, categoria: _categoriaDe(log), texto: _textoAccion('${log['accion']}')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Bitacora de Auditoria', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarAuditoria),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              children: [
                TextField(
                  controller: _buscarCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar código (SOL-..., PRES-...) o acción',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      tooltip: 'Buscar',
                      onPressed: _cargarAuditoria,
                    ),
                  ),
                  onSubmitted: (_) => _cargarAuditoria(),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.date_range_rounded, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(visualDensity: VisualDensity.compact),
                      segments: _periodos.entries
                          .map((e) => ButtonSegment<int>(value: e.key, label: Text(e.value, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      selected: {_dias},
                      onSelectionChanged: (s) {
                        setState(() => _dias = s.first);
                        _cargarAuditoria();
                      },
                    ),
                  ),
                ]),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: ['Todas', ..._categorias.keys].map((c) {
                      final sel = _categoria == c;
                      final cat = _categorias[c];
                      final n = c == 'Todas' ? _logs.length : _logs.where((l) => _categoriaDe(l).nombre == c).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: cat == null ? null : Icon(cat.icono, size: 16, color: sel ? Colors.white : cat.color),
                          label: Text('$c ($n)'),
                          selected: sel,
                          showCheckmark: false,
                          selectedColor: cat?.color ?? AppColors.primaryBlue,
                          labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12.5),
                          onSelected: (_) => setState(() => _categoria = c),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _cargarAuditoria,
                    child: _error != null
                        ? ListView(children: [
                            const SizedBox(height: 70),
                            const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('No se pudo cargar la bitácora.\n$_error', textAlign: TextAlign.center),
                            ),
                            Center(
                              child: OutlinedButton.icon(
                                  onPressed: _cargarAuditoria, icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
                            ),
                          ])
                        : lista.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 70),
                                Icon(Icons.fact_check_outlined, size: 56, color: Colors.grey),
                                SizedBox(height: 8),
                                Center(child: Text('No hay registros para este filtro y periodo.')),
                              ])
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                                children: [
                                  ...filas,
                                  if (_hayMas)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Center(
                                        child: _cargandoMas
                                            ? const CircularProgressIndicator()
                                            : OutlinedButton.icon(
                                                onPressed: () => _cargarAuditoria(mas: true),
                                                icon: const Icon(Icons.expand_more_rounded),
                                                label: const Text('Cargar más registros'),
                                              ),
                                      ),
                                    ),
                                ],
                              ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final _Categoria categoria;
  final String texto;
  const _EventoTile({required this.log, required this.categoria, required this.texto});

  @override
  Widget build(BuildContext context) {
    final ts = DateTime.tryParse('${log['timestamp']}');
    final hora = ts == null ? '' : '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
    final usuario = log['nombreUsuario'] ?? 'Usuario #${log['idUsuario'] ?? '-'}';
    final rol = log['rolUsuario'];
    final hash = '${log['hashSha256'] ?? ''}';

    return Card(
      color: AppColors.pureWhite,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: categoria.color.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: CircleAvatar(
            backgroundColor: categoria.color.withValues(alpha: 0.12),
            child: Icon(categoria.icono, color: categoria.color, size: 20),
          ),
          title: Text(texto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(
            '$usuario${rol != null ? ' · ${rol.toString()[0]}${rol.toString().substring(1).toLowerCase()}' : ''}\n'
            '${log['idOperacion'] ?? ''}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(hora, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          children: [
            _fila('Código de operación', '${log['idOperacion'] ?? '-'}'),
            _fila('Acción registrada', '${log['accion'] ?? '-'}'),
            _fila('IP de origen', '${log['ipOrigen'] ?? '-'}'),
            _fila('Fecha y hora', '${log['timestamp'] ?? '-'}'.replaceFirst('T', ' ').split('.').first),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.backgroundGray, borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                const Icon(Icons.verified_rounded, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('SHA-256: $hash',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5)),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copiar hash',
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: hash));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hash copiado')));
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 140, child: Text(k, style: const TextStyle(fontSize: 12.5, color: Colors.black54))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12.5))),
        ]),
      );
}

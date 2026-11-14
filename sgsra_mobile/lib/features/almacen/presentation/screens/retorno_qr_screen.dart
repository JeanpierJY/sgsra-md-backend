import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../../../core/widgets/selector_buscable.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF34, RF35, RF38 - RF40, ALM-03] Retorno de herramientas con escáner QR integrado.
/// Arriba se escanea el QR de la herramienta; abajo se completa el retorno. Si la herramienta
/// está prestada, el préstamo, el mecánico y la herramienta se rellenan solos.
class RetornoQrScreen extends StatefulWidget {
  const RetornoQrScreen({super.key});

  @override
  State<RetornoQrScreen> createState() => _RetornoQrScreenState();
}

class _RetornoQrScreenState extends State<RetornoQrScreen> {
  final AlmacenRemoteDataSource _ds = AlmacenRemoteDataSource(DioClient());
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  final _obsCtrl = TextEditingController();

  bool _cargando = true;
  bool _enviando = false;
  bool _procesandoQr = false;
  bool _camaraActiva = true;
  List<PrestamoEntity> _activos = [];

  PrestamoEntity? _prestamo;
  String? _herramienta; // código de la herramienta que vuelve
  String _estadoFisico = 'BUEN_ESTADO';

  String? _ultimoCodigo;
  /// Resultado del último escaneo cuando la herramienta no está prestada
  HerramientaEntity? _fichaEscaneada;
  String? _avisoEscaneo;

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  @override
  void dispose() {
    _scanner.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPrestamos() async {
    setState(() => _cargando = true);
    try {
      final todos = await _ds.listarPrestamos();
      final activos = todos.where((p) => p.estadoPrestamo != 'CERRADO' && p.estadoPrestamo != 'DEVUELTO').toList()
        ..sort((a, b) {
          // En mora primero
          final m = (a.estadoPrestamo.contains('MORA') ? 0 : 1).compareTo(b.estadoPrestamo.contains('MORA') ? 0 : 1);
          return m != 0 ? m : a.fechaPrestamo.compareTo(b.fechaPrestamo);
        });
      if (!mounted) return;
      setState(() {
        _activos = activos;
        if (_prestamo != null && !activos.any((p) => p.prestamoNum == _prestamo!.prestamoNum)) {
          _prestamo = null;
          _herramienta = null;
        }
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed));
    }
  }

  List<Map<String, dynamic>> _itemsDe(PrestamoEntity p) {
    final raw = p.raw['herramientas'];
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return p.herramientas.map((c) => {'codHerramienta': c, 'nombreHerramienta': c}).toList();
  }

  void _seleccionarPrestamo(PrestamoEntity p, {String? herramienta}) {
    final items = _itemsDe(p);
    setState(() {
      _prestamo = p;
      _herramienta = herramienta ?? (items.length == 1 ? '${items.first['codHerramienta']}' : null);
    });
  }

  /// [ALM-03] Busca la herramienta escaneada en los préstamos activos y rellena el formulario
  Future<void> _procesarCodigo(String raw) async {
    final codigo = raw.trim().toUpperCase();
    if (_procesandoQr || codigo.isEmpty || codigo == _ultimoCodigo) return;
    setState(() {
      _procesandoQr = true;
      _ultimoCodigo = codigo;
      _fichaEscaneada = null;
      _avisoEscaneo = null;
    });

    final prestamo = _activos.where((p) => p.herramientas.map((e) => e.toUpperCase()).contains(codigo)).firstOrNull;
    if (prestamo != null) {
      final cod = prestamo.herramientas.firstWhere((e) => e.toUpperCase() == codigo);
      _seleccionarPrestamo(prestamo, herramienta: cod);
      setState(() => _procesandoQr = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$cod encontrada en el préstamo ${prestamo.prestamoNum} de ${prestamo.nombreMecanico}'),
        backgroundColor: Colors.green[700],
      ));
      return;
    }
    // No está prestada: se muestra su ficha
    try {
      final h = await _ds.consultarHerramienta(codigo);
      if (!mounted) return;
      setState(() {
        _fichaEscaneada = h;
        _avisoEscaneo = 'Esta herramienta no tiene un préstamo activo.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _avisoEscaneo = 'El código $codigo no está registrado en el pañol.');
    } finally {
      if (mounted) setState(() => _procesandoQr = false);
    }
  }

  Future<void> _ingresarCodigoManual() async {
    final ctrl = TextEditingController();
    final cod = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ingresar código'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Código de herramienta', hintText: 'HER-TOR-004'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Buscar')),
        ],
      ),
    );
    if (cod != null && cod.trim().isNotEmpty) {
      _ultimoCodigo = null;
      _procesarCodigo(cod);
    }
  }

  Future<void> _elegirPrestamo() async {
    final p = await mostrarSelectorBuscable<PrestamoEntity>(
      context: context,
      titulo: 'Préstamo a recibir',
      hint: 'Buscar por préstamo, mecánico o herramienta',
      items: _activos,
      textoBusqueda: (p) => '${p.prestamoNum} ${p.nombreMecanico} ${p.dniMecanico} ${p.herramientas.join(' ')} '
          '${_itemsDe(p).map((i) => i['nombreHerramienta']).join(' ')}',
      construir: (_, p) => Row(children: [
        CircleAvatar(
          backgroundColor: colorEstadoPrestamo(p.estadoPrestamo),
          child: const Icon(Icons.handyman, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${p.prestamoNum} · ${p.nombreMecanico}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${_itemsDe(p).map((i) => i['nombreHerramienta']).join(', ')}',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text('Salida: ${p.fechaPrestamo}', style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
          ]),
        ),
        Text(etiquetaEstadoPrestamo(p.estadoPrestamo),
            style: TextStyle(color: colorEstadoPrestamo(p.estadoPrestamo), fontWeight: FontWeight.bold, fontSize: 11.5)),
      ]),
    );
    if (p != null) _seleccionarPrestamo(p);
  }

  Future<void> _confirmarRetorno() async {
    final p = _prestamo;
    final cod = _herramienta;
    if (p == null || cod == null) return;
    setState(() => _enviando = true);
    try {
      await _ds.registrarDevolucion(p.prestamoNum, cod, _estadoFisico, _obsCtrl.text.trim());
      // [PRE-01] Se muestra el antes y después del préstamo
      Map<String, dynamic>? detalle;
      try {
        final todos = await _ds.listarPrestamos();
        detalle = todos.where((x) => x.prestamoNum == p.prestamoNum).map((x) => x.raw).firstOrNull;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _prestamo = null;
        _herramienta = null;
        _estadoFisico = 'BUEN_ESTADO';
        _ultimoCodigo = null;
        _fichaEscaneada = null;
        _avisoEscaneo = null;
      });
      _obsCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Herramienta $cod recibida (${p.prestamoNum}).'),
        backgroundColor: Colors.green[700],
      ));
      if (detalle != null && detalle.isNotEmpty) await mostrarDetallePrestamo(context, detalle);
      _cargarPrestamos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar el retorno: ${mensajeDeError(e)}'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Retorno de Herramientas [RF38]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarPrestamos),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarPrestamos,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _tarjetaEscaner(),
            if (_avisoEscaneo != null) ...[
              const SizedBox(height: 10),
              _resultadoEscaneo(),
            ],
            const SizedBox(height: 14),
            _formularioRetorno(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEscaner() {
    return Card(
      color: AppColors.pureWhite,
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        SizedBox(
          height: _camaraActiva ? 210 : 0,
          width: double.infinity,
          child: _camaraActiva
              ? Stack(alignment: Alignment.center, children: [
                  Container(color: Colors.black),
                  MobileScanner(
                    controller: _scanner,
                    onDetect: (capture) {
                      for (final b in capture.barcodes) {
                        final v = b.rawValue;
                        if (v != null && v.isNotEmpty) {
                          _procesarCodigo(v);
                          break;
                        }
                      }
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No se pudo abrir la cámara. Use "Ingresar código".',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Row(children: [
                      _botonCamara(Icons.flash_on_rounded, 'Linterna', () => _scanner.toggleTorch()),
                      _botonCamara(Icons.flip_camera_ios_rounded, 'Cambiar cámara', () => _scanner.switchCamera()),
                    ]),
                  ),
                  if (_procesandoQr)
                    Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                ])
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Escanee el QR de la herramienta que devuelven [RF34]',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54)),
            ),
            IconButton(
              tooltip: _camaraActiva ? 'Ocultar cámara' : 'Mostrar cámara',
              icon: Icon(_camaraActiva ? Icons.videocam_off_outlined : Icons.videocam_outlined),
              onPressed: () {
                setState(() => _camaraActiva = !_camaraActiva);
                _camaraActiva ? _scanner.start() : _scanner.stop();
              },
            ),
            TextButton(onPressed: _ingresarCodigoManual, child: const Text('Ingresar código')),
          ]),
        ),
      ]),
    );
  }

  Widget _botonCamara(IconData i, String t, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: Colors.black45,
          shape: const CircleBorder(),
          child: IconButton(tooltip: t, icon: Icon(i, color: Colors.white, size: 20), onPressed: f),
        ),
      );

  Widget _resultadoEscaneo() {
    final h = _fichaEscaneada;
    return Card(
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline_rounded, color: Colors.amber[900]),
            const SizedBox(width: 8),
            Expanded(child: Text(_avisoEscaneo!, style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w600))),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => setState(() {
                _avisoEscaneo = null;
                _fichaEscaneada = null;
                _ultimoCodigo = null;
              }),
            ),
          ]),
          if (h != null) ...[
            const Divider(),
            const Text('FICHA DEL ACTIVO [RF35]',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            FilaHerramienta(h, tamanoImagen: 60),
            const SizedBox(height: 4),
            Text('Categoría: ${h.categoria}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ],
        ]),
      ),
    );
  }

  Widget _formularioRetorno() {
    final p = _prestamo;
    final items = p == null ? const <Map<String, dynamic>>[] : _itemsDe(p);
    return Card(
      color: AppColors.pureWhite,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Inspección de entrada al pañol',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          Text(_cargando ? 'Cargando préstamos…' : '${_activos.length} préstamo(s) activos',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Divider(height: 22),
          if (!_cargando && _activos.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: const Text('No hay préstamos activos pendientes de devolución.'),
            )
          else ...[
            CampoSelector(
              etiqueta: 'Préstamo a recibir',
              icono: Icons.assignment_return_outlined,
              placeholder: 'Escanee el QR o toque para buscar',
              onTap: _cargando ? null : _elegirPrestamo,
              valor: p == null
                  ? null
                  : Text('${p.prestamoNum} · ${p.nombreMecanico}', style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (p != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.event_rounded, size: 16, color: Colors.black45),
                const SizedBox(width: 6),
                Text('Salida: ${p.fechaPrestamo} ${p.horaSalida.length >= 5 ? p.horaSalida.substring(0, 5) : p.horaSalida}',
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                const Spacer(),
                Text(etiquetaEstadoPrestamo(p.estadoPrestamo),
                    style: TextStyle(color: colorEstadoPrestamo(p.estadoPrestamo), fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              Text(items.length == 1 ? 'Herramienta que vuelve' : '¿Qué herramienta vuelve?',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ...items.map((i) {
                final cod = '${i['codHerramienta']}';
                final sel = _herramienta == cod;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _herramienta = cod),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryBlue.withValues(alpha: 0.07) : AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppColors.primaryBlue : Colors.transparent),
                    ),
                    child: Row(children: [
                      ImagenProducto(url: i['imagenUrl']?.toString(), size: 44, iconoVacio: Icons.handyman_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${i['nombreHerramienta'] ?? cod}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(cod, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ]),
                      ),
                      Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: sel ? AppColors.primaryBlue : Colors.grey),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text('Estado en que vuelve [RF39]', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                _opcionEstado('BUEN_ESTADO', 'Buen estado', Icons.check_circle_outline, Colors.green[700]!),
                const SizedBox(width: 6),
                _opcionEstado('CON_AVERIA', 'Con avería', Icons.build_circle_outlined, Colors.amber[900]!),
                const SizedBox(width: 6),
                _opcionEstado('INCOMPLETA', 'Incompleta', Icons.remove_circle_outline, AppColors.errorRed),
              ]),
              const SizedBox(height: 6),
              Text(
                switch (_estadoFisico) {
                  'BUEN_ESTADO' => 'Vuelve a quedar disponible para préstamo [RF40].',
                  'CON_AVERIA' => 'Pasa a mantenimiento [RF40]. Describa la avería.',
                  _ => 'Requiere informe técnico. Indique qué falta.',
                },
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _obsCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _estadoFisico == 'BUEN_ESTADO' ? 'Observaciones (opcional)' : 'Detalle de la avería o faltante',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (_enviando || _herramienta == null) ? null : _confirmarRetorno,
                icon: _enviando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.assignment_return_rounded),
                label: Text(_herramienta == null ? 'Elija la herramienta que vuelve' : 'Confirmar retorno [RF40]'),
              ),
            ],
          ],
        ]),
      ),
    );
  }

  Widget _opcionEstado(String valor, String texto, IconData icono, Color color) {
    final sel = _estadoFisico == valor;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _estadoFisico = valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : Colors.grey.shade300),
          ),
          child: Column(children: [
            Icon(icono, color: sel ? Colors.white : color),
            const SizedBox(height: 2),
            Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : color)),
          ]),
        ),
      ),
    );
  }
}

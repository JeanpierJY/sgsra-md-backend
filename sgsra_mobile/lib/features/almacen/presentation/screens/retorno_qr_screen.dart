import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/detalle_prestamo_sheet.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// Modelo ligero para representar cada herramienta prestada pendiente de devolución
class ItemPrestamoHerramienta {
  final PrestamoEntity prestamo;
  final String codHerramienta;
  final String nombreHerramienta;
  final String? imagenUrl;
  final String? estadoAlDevolver;

  const ItemPrestamoHerramienta({
    required this.prestamo,
    required this.codHerramienta,
    required this.nombreHerramienta,
    this.imagenUrl,
    this.estadoAlDevolver,
  });

  bool get pendienteRetorno => estadoAlDevolver == null || estadoAlDevolver!.isEmpty;
}

/// [RF34, RF35, RF38 - RF40, ALM-03] Retorno de herramientas con escáner QR integrado,
/// buscador predictivo como el catálogo, listado automático de herramientas prestadas,
/// y modal de inspección/confirmación al seleccionar la herramienta.
class RetornoQrScreen extends StatefulWidget {
  const RetornoQrScreen({super.key});

  @override
  State<RetornoQrScreen> createState() => _RetornoQrScreenState();
}

class _RetornoQrScreenState extends State<RetornoQrScreen> with WidgetsBindingObserver {
  final AlmacenRemoteDataSource _ds = AlmacenRemoteDataSource(DioClient());
  late final MobileScannerController _scanner;
  final TextEditingController _buscarCtrl = TextEditingController();

  bool _cargando = true;
  bool _procesandoQr = false;
  bool _camaraActiva = true;
  bool _modalAbierto = false;
  List<PrestamoEntity> _activos = [];

  String? _ultimoCodigo;
  DateTime? _ultimoEscaneo;
  HerramientaEntity? _fichaEscaneada;
  String? _avisoEscaneo;

  @override
  void initState() {
    super.initState();
    _scanner = MobileScannerController(
      // [H-ALM-04] "noDuplicates" impedía volver a leer el mismo QR; el control de repetidos
      // se hace en _procesarCodigo
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
    );
    WidgetsBinding.instance.addObserver(this);
    _cargarPrestamos();
  }

  /// [H-ALM-04] Con un controller propio, mobile_scanner NO gestiona el ciclo de vida:
  /// tras el diálogo de permisos o al volver de segundo plano la cámara quedaba en negro.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scanner.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_camaraActiva) unawaited(_scanner.start());
      case AppLifecycleState.inactive:
        unawaited(_scanner.stop());
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanner.dispose();
    _buscarCtrl.dispose();
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
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed));
    }
  }

  /// Lista aplanada de todas las herramientas actualmente en posesión que no han sido devueltas
  List<ItemPrestamoHerramienta> get _herramientasPendientes {
    final List<ItemPrestamoHerramienta> lista = [];
    for (final p in _activos) {
      final rawList = p.raw['herramientas'];
      if (rawList is List && rawList.isNotEmpty && rawList.first is Map) {
        for (final raw in rawList) {
          final m = Map<String, dynamic>.from(raw as Map);
          final estadoDev = m['estadoAlDevolver']?.toString();
          if (estadoDev == null || estadoDev.isEmpty) {
            lista.add(ItemPrestamoHerramienta(
              prestamo: p,
              codHerramienta: '${m['codHerramienta'] ?? ''}',
              nombreHerramienta: '${m['nombreHerramienta'] ?? m['codHerramienta'] ?? ''}',
              imagenUrl: m['imagenUrl']?.toString(),
              estadoAlDevolver: estadoDev,
            ));
          }
        }
      } else {
        for (final cod in p.herramientas) {
          lista.add(ItemPrestamoHerramienta(
            prestamo: p,
            codHerramienta: cod,
            nombreHerramienta: cod,
            imagenUrl: null,
            estadoAlDevolver: null,
          ));
        }
      }
    }
    return lista;
  }

  /// Filtro predictivo sobre el listado automático (como en el catálogo)
  List<ItemPrestamoHerramienta> get _filtradas {
    final pendientes = _herramientasPendientes;
    final q = _buscarCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return pendientes;
    return pendientes.where((item) {
      final matchCod = item.codHerramienta.toLowerCase().contains(q);
      final matchNom = item.nombreHerramienta.toLowerCase().contains(q);
      final matchMec = item.prestamo.nombreMecanico.toLowerCase().contains(q);
      final matchDni = item.prestamo.dniMecanico.toLowerCase().contains(q);
      final matchPres = item.prestamo.prestamoNum.toLowerCase().contains(q);
      return matchCod || matchNom || matchMec || matchDni || matchPres;
    }).toList();
  }

  /// Procesa el código QR capturado por la cámara
  Future<void> _procesarCodigo(String raw) async {
    final codigo = raw.trim().toUpperCase();
    // [H-ALM-04] El mismo QR puede volver a leerse pasados unos segundos (antes quedaba bloqueado)
    final ahora = DateTime.now();
    final repetido = codigo == _ultimoCodigo &&
        _ultimoEscaneo != null &&
        ahora.difference(_ultimoEscaneo!) < const Duration(seconds: 3);
    if (_procesandoQr || _modalAbierto || codigo.isEmpty || repetido) return;
    _ultimoEscaneo = ahora;
    setState(() {
      _procesandoQr = true;
      _ultimoCodigo = codigo;
      _fichaEscaneada = null;
      _avisoEscaneo = null;
    });

    final item = _herramientasPendientes.where((h) => h.codHerramienta.toUpperCase() == codigo).firstOrNull;
    if (item != null) {
      setState(() => _procesandoQr = false);
      _abrirModalRetorno(item);
      return;
    }

    // No está prestada: se consulta su ficha en el inventario general
    try {
      final h = await _ds.consultarHerramienta(codigo);
      if (!mounted) return;
      setState(() {
        _fichaEscaneada = h;
        _avisoEscaneo = 'La herramienta $codigo (${h.nombre}) no cuenta con un préstamo activo pendiente de devolución.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _avisoEscaneo = 'El código $codigo no está registrado en el pañol.');
    } finally {
      if (mounted) setState(() => _procesandoQr = false);
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scanner.toggleTorch();
    } catch (e) {
      debugPrint('Error en linterna: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _scanner.switchCamera();
    } catch (e) {
      debugPrint('Error en cambio de cámara: $e');
    }
  }

  String _mensajeErrorCamara(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Permiso de cámara denegado. Habilítelo en Ajustes > Aplicaciones > SGSRA > Permisos.';
      case MobileScannerErrorCode.unsupported:
        return 'El escáner no está soportado en esta plataforma.';
      default:
        return error.errorDetails?.message ?? 'No se pudo iniciar la cámara.';
    }
  }

  /// [RF39, RF40] Modal que aparece al seleccionar la herramienta en la lista o por QR
  Future<void> _abrirModalRetorno(ItemPrestamoHerramienta item) async {
    _modalAbierto = true;
    String estadoFisico = 'BUEN_ESTADO';
    final obsCtrl = TextEditingController();
    bool enviando = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 12,
            // [H-ALM-03] Suma la barra de navegación del teléfono para que "Confirmar retorno" no quede oculto
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + MediaQuery.of(modalCtx).padding.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Row(children: [
                  const Icon(Icons.assignment_return_rounded, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Retorno de Herramienta',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(modalCtx),
                  ),
                ]),
                const Divider(height: 16),
                // Resumen de la herramienta y préstamo seleccionado
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(children: [
                    ImagenProducto(url: item.imagenUrl, size: 52, iconoVacio: Icons.handyman_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.nombreHerramienta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('Código: ${item.codHerramienta}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                        Text('Mecánico: ${item.prestamo.nombreMecanico} (DNI ${item.prestamo.dniMecanico})',
                            style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        Text('Préstamo: ${item.prestamo.prestamoNum} · Salida: ${item.prestamo.fechaPrestamo}',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('Estado en que devuelve', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                const SizedBox(height: 8),
                Row(children: [
                  _opcionEstadoModal('BUEN_ESTADO', 'Buen estado', Icons.check_circle_outline, Colors.green[700]!,
                      estadoFisico, (v) => setModalState(() => estadoFisico = v)),
                  const SizedBox(width: 6),
                  _opcionEstadoModal('CON_AVERIA', 'Con avería', Icons.build_circle_outlined, Colors.amber[900]!,
                      estadoFisico, (v) => setModalState(() => estadoFisico = v)),
                  const SizedBox(width: 6),
                  _opcionEstadoModal('INCOMPLETA', 'Incompleta', Icons.remove_circle_outline, AppColors.errorRed,
                      estadoFisico, (v) => setModalState(() => estadoFisico = v)),
                ]),
                const SizedBox(height: 6),
                Text(
                  switch (estadoFisico) {
                    'BUEN_ESTADO' => 'Vuelve a quedar disponible para préstamo.',
                    'CON_AVERIA' => 'Pasa a mantenimiento. Describa la avería.',
                    _ => 'Requiere informe técnico. Indique qué falta.',
                  },
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: obsCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: estadoFisico == 'BUEN_ESTADO' ? 'Observaciones (opcional)' : 'Detalle de la avería o faltante',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: enviando
                      ? null
                      : () async {
                          setModalState(() => enviando = true);
                          final ok = await _ejecutarRetorno(item, estadoFisico, obsCtrl.text.trim());
                          if (ok && mounted) {
                            Navigator.pop(modalCtx);
                          } else {
                            setModalState(() => enviando = false);
                          }
                        },
                  icon: enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.assignment_turned_in_rounded),
                  label: Text(enviando ? 'Registrando...' : 'Confirmar retorno',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    obsCtrl.dispose();
    _modalAbierto = false;
  }

  Widget _opcionEstadoModal(String valor, String texto, IconData icono, Color color, String actual, ValueChanged<String> onSel) {
    final sel = actual == valor;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onSel(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? color : Colors.grey.shade300),
          ),
          child: Column(children: [
            Icon(icono, color: sel ? Colors.white : color, size: 20),
            const SizedBox(height: 2),
            Text(texto,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: sel ? Colors.white : color)),
          ]),
        ),
      ),
    );
  }

  Future<bool> _ejecutarRetorno(ItemPrestamoHerramienta item, String estadoFisico, String observaciones) async {
    try {
      await _ds.registrarDevolucion(item.prestamo.prestamoNum, item.codHerramienta, estadoFisico, observaciones);

      // Se consulta el detalle antes/después del préstamo [PRE-01]
      Map<String, dynamic>? detalle;
      try {
        final todos = await _ds.listarPrestamos();
        detalle = todos.where((x) => x.prestamoNum == item.prestamo.prestamoNum).map((x) => x.raw).firstOrNull;
      } catch (_) {}

      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Herramienta ${item.codHerramienta} recibida con éxito (${item.prestamo.prestamoNum}).'),
        backgroundColor: Colors.green[700],
      ));

      if (detalle != null && detalle.isNotEmpty) {
        await mostrarDetallePrestamo(context, detalle);
      }

      _cargarPrestamos();
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo registrar el retorno: ${mensajeDeError(e)}'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return false;
    }
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
                      if (_modalAbierto || _procesandoQr) return;
                      for (final b in capture.barcodes) {
                        final v = b.rawValue;
                        if (v != null && v.isNotEmpty) {
                          _procesarCodigo(v);
                          break;
                        }
                      }
                    },
                    errorBuilder: (ctx, err, child) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              _mensajeErrorCamara(err),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () async {
                                try {
                                  await _scanner.stop();
                                  await _scanner.start();
                                  if (mounted) setState(() {});
                                } catch (_) {}
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Reintentar cámara'),
                            ),
                          ],
                        ),
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
                      _botonCamara(Icons.flash_on_rounded, 'Linterna', _toggleTorch),
                      _botonCamara(Icons.flip_camera_ios_rounded, 'Cambiar cámara', _switchCamera),
                    ]),
                  ),
                  if (_procesandoQr)
                    Container(
                      color: Colors.black45,
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                ])
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Escanee el QR de la herramienta o elíjala de la lista inferior',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54)),
            ),
            IconButton(
              tooltip: _camaraActiva ? 'Ocultar cámara' : 'Mostrar cámara',
              icon: Icon(_camaraActiva ? Icons.videocam_off_outlined : Icons.videocam_outlined),
              // [H-ALM-04] El widget MobileScanner arranca/detiene la cámara al montarse/desmontarse
              // (autoStart); llamar además start()/stop() aquí provocaba arranques duplicados.
              onPressed: () => setState(() => _camaraActiva = !_camaraActiva),
            ),
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
            const Text('FICHA DEL ACTIVO',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            FilaHerramienta(h, tamanoImagen: 60),
            const SizedBox(height: 4),
            Text('Categoría: ${h.categoria} · Estado: ${h.estadoActual}',
                style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtradas;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Retorno de Herramientas', style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Buscador predictivo (estilo catálogo)
            TextField(
              controller: _buscarCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por herramienta, código, mecánico o préstamo...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                suffixIcon: _buscarCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _buscarCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.pureWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            // Encabezado del listado automático
            Row(children: [
              Text('Herramientas por retornar (${filtradas.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const Spacer(),
              Text('${_activos.length} préstamos activos', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
            const SizedBox(height: 4),
            const Text('Toque una herramienta para registrar su inspección y retorno.',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 10),
            if (_cargando)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.primaryBlue)))
            else if (_herramientasPendientes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 48),
                  SizedBox(height: 10),
                  Text('No hay herramientas pendientes de devolución.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Todos los préstamos de pañol están al día.',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ]),
              )
            else if (filtradas.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(children: [
                  Icon(Icons.search_off_rounded, color: Colors.grey[400], size: 48),
                  const SizedBox(height: 8),
                  Text('No se encontraron herramientas con "${_buscarCtrl.text.trim()}".',
                      style: const TextStyle(color: Colors.black54)),
                ]),
              )
            else
              ...filtradas.map((item) => Card(
                    color: AppColors.pureWhite,
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: item.prestamo.estadoPrestamo.contains('MORA')
                          ? BorderSide(color: AppColors.errorRed.withValues(alpha: 0.5), width: 1.5)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _abrirModalRetorno(item),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          ImagenProducto(url: item.imagenUrl, size: 54, iconoVacio: Icons.handyman_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(
                                  child: Text(item.nombreHerramienta,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                if (item.prestamo.estadoPrestamo.contains('MORA'))
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: AppColors.errorRed, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('EN MORA',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ]),
                              const SizedBox(height: 3),
                              Text('Cód: ${item.codHerramienta}',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                              const SizedBox(height: 2),
                              Text('Mecánico: ${item.prestamo.nombreMecanico}',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              Text('${item.prestamo.prestamoNum} · Salida: ${item.prestamo.fechaPrestamo}',
                                  style: const TextStyle(fontSize: 11, color: Colors.black45)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                              foregroundColor: AppColors.primaryBlue,
                            ),
                            onPressed: () => _abrirModalRetorno(item),
                            icon: const Icon(Icons.assignment_return_rounded, size: 16),
                            label: const Text('Retornar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),
                    ),
                  )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

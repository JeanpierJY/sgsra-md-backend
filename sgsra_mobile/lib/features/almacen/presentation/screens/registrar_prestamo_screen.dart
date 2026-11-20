import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/selector_buscable.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF36, RF37, ALM-02] Salida formal de herramientas de pañol.
/// El mecánico y las herramientas se eligen con buscadores (con foto de cada herramienta).
class RegistrarPrestamoScreen extends StatefulWidget {
  /// [ALM-01] true cuando se muestra como pestaña dentro de DespachoScreen (sin AppBar propio)
  final bool embebido;
  const RegistrarPrestamoScreen({Key? key, this.embebido = false}) : super(key: key);

  @override
  State<RegistrarPrestamoScreen> createState() => _RegistrarPrestamoScreenState();
}

class _RegistrarPrestamoScreenState extends State<RegistrarPrestamoScreen> {
  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());

  bool _cargando = true;
  bool _enviando = false;
  String? _error;
  List<Map<String, dynamic>> _mecanicos = [];
  List<HerramientaEntity> _herramientas = [];

  Map<String, dynamic>? _mecanico;
  final List<HerramientaEntity> _seleccionadas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await Future.wait([_dataSource.listarMecanicos(), _dataSource.listarHerramientas()]);
      final mecs = r[0].map((m) => Map<String, dynamic>.from(m as Map)).toList()
        ..sort((a, b) => '${a['nombre']}'.compareTo('${b['nombre']}'));
      final herrs = (r[1] as List<HerramientaEntity>)
        ..sort((a, b) {
          // Disponibles primero
          final d = (a.disponible ? 0 : 1).compareTo(b.disponible ? 0 : 1);
          return d != 0 ? d : a.codHerramienta.compareTo(b.codHerramienta);
        });
      if (!mounted) return;
      setState(() {
        _mecanicos = mecs;
        _herramientas = herrs;
        _seleccionadas.removeWhere((s) => !herrs.any((h) => h.codHerramienta == s.codHerramienta && h.disponible));
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = mensajeDeError(e);
      });
    }
  }

  Future<void> _elegirMecanico() async {
    final m = await mostrarSelectorBuscable<Map<String, dynamic>>(
      context: context,
      titulo: 'Mecánico que recibe',
      hint: 'Buscar por nombre o DNI',
      items: _mecanicos,
      textoBusqueda: (m) => '${m['nombre']} ${m['dni']}',
      construir: (_, m) => Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
          child: Text('${m['nombre']}'.isNotEmpty ? '${m['nombre']}'[0] : '?',
              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${m['nombre']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('DNI ${m['dni']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
      ]),
    );
    if (m != null) setState(() => _mecanico = m);
  }

  Future<void> _agregarHerramienta() async {
    final ya = _seleccionadas.map((e) => e.codHerramienta).toSet();
    final h = await mostrarSelectorBuscable<HerramientaEntity>(
      context: context,
      titulo: 'Herramienta a entregar',
      hint: 'Buscar por código, nombre o marca',
      items: _herramientas.where((h) => !ya.contains(h.codHerramienta)).toList(),
      textoBusqueda: (h) => '${h.codHerramienta} ${h.nombre} ${h.marca}',
      habilitado: (h) => h.disponible,
      vacio: 'No hay herramientas con ese texto',
      construir: (_, h) => FilaHerramienta(h,
          trailing: h.disponible ? const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue) : null),
    );
    if (h != null) setState(() => _seleccionadas.add(h));
  }

  Future<void> _despachar() async {
    if (_mecanico == null || _seleccionadas.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: Text('Entregará ${_seleccionadas.length} herramienta(s) a ${_mecanico!['nombre']}.\n\n'
            '${_seleccionadas.map((h) => '• ${h.nombre} (${h.codHerramienta})').join('\n')}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Revisar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Entregar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _enviando = true);
    try {
      final codPrestamo = await _dataSource.registrarPrestamo(
        '${_mecanico!['dni']}',
        _seleccionadas.map((h) => h.codHerramienta).toList(),
        'FIRMA_DIGITAL_RECEPCION_OK',
      );
      if (!mounted) return;
      setState(() => _enviando = false);
      final nombre = _mecanico!['nombre'];
      final n = _seleccionadas.length;
      setState(() {
        _seleccionadas.clear();
        _mecanico = null;
      });
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.check_circle_rounded, color: Colors.green[700], size: 52),
          title: const Text('Préstamo registrado [RF37]'),
          content: Text('$codPrestamo\n$n herramienta(s) entregadas a $nombre.\nSu estado ahora es "Prestada".',
              textAlign: TextAlign.center),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      _cargarDatos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disponibles = _herramientas.where((h) => h.disponible).length;
    final cuerpo = _cargando
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Card(
                    color: AppColors.pureWhite,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Salida Formal de Herramientas de Pañol',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                          const SizedBox(height: 4),
                          Text('$disponibles herramienta(s) disponibles para entregar.',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_error!, style: const TextStyle(color: AppColors.errorRed)),
                            ),
                          const Divider(height: 24),
                          CampoSelector(
                            etiqueta: 'Mecánico que recibe',
                            icono: Icons.engineering_rounded,
                            placeholder: 'Toque para buscar al mecánico',
                            onTap: _mecanicos.isEmpty ? null : _elegirMecanico,
                            valor: _mecanico == null
                                ? null
                                : Text('${_mecanico!['nombre']}  ·  DNI ${_mecanico!['dni']}',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 16),
                          CampoSelector(
                            etiqueta: 'Herramienta a entregar',
                            icono: Icons.handyman_outlined,
                            placeholder: disponibles == 0
                                ? 'No hay herramientas disponibles en el pañol'
                                : (_seleccionadas.isEmpty
                                    ? 'Toque para buscar y agregar herramienta'
                                    : 'Toque para buscar y agregar otra herramienta'),
                            onTap: disponibles == 0 ? null : _agregarHerramienta,
                            valor: null,
                          ),
                          if (_seleccionadas.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Row(children: [
                              Text('Herramientas seleccionadas (${_seleccionadas.length})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: disponibles == 0 ? null : _agregarHerramienta,
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                label: const Text('Agregar más'),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            ..._seleccionadas.map((h) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundGray,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FilaHerramienta(h,
                                      tamanoImagen: 46,
                                      trailing: IconButton(
                                        tooltip: 'Quitar',
                                        icon: const Icon(Icons.close_rounded, color: AppColors.errorRed),
                                        onPressed: () => setState(() => _seleccionadas.remove(h)),
                                      )),
                                )),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: (_enviando || _mecanico == null || _seleccionadas.isEmpty) ? null : _despachar,
                            icon: _enviando
                                ? const SizedBox(
                                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.assignment_turned_in),
                            label: Text(_enviando ? 'Registrando…' : 'Registrar entrega [RF36]',
                                style: const TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
    if (widget.embebido) {
      return RefreshIndicator(onRefresh: _cargarDatos, child: cuerpo);
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Despacho / Préstamo [RF36]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarDatos),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      body: cuerpo,
    );
  }
}

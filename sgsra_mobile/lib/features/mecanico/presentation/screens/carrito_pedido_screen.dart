import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../domain/entities/repuesto_entity.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../data/datasources/repuesto_local_datasource.dart';
import '../../data/models/solicitud_request.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF13 - RF17, MEC-04, MEC-05] Pestaña "Solicitudes": arma y envía la solicitud de repuestos.
class CarritoPedidoScreen extends StatefulWidget {
  final Map<RepuestoEntity, int> carrito;
  final VoidCallback onCarritoActualizado;
  /// Se invoca con el número de la solicitud creada para mostrarla en "Historial"
  final void Function(String solicitudNum)? onPedidoEnviado;
  /// Lleva al catálogo para agregar repuestos
  final VoidCallback? onIrCatalogo;

  const CarritoPedidoScreen({
    Key? key,
    required this.carrito,
    required this.onCarritoActualizado,
    this.onPedidoEnviado,
    this.onIrCatalogo,
  }) : super(key: key);

  @override
  State<CarritoPedidoScreen> createState() => _CarritoPedidoScreenState();
}

class _CarritoPedidoScreenState extends State<CarritoPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _justificacionCtrl = TextEditingController();
  final RepuestoRemoteDataSource _remoteDataSource = RepuestoRemoteDataSource(DioClient());
  final RepuestoLocalDataSource _localDataSource = RepuestoLocalDataSource();

  /// Máquina elegida en el buscador (MEC-05)
  Map<String, dynamic>? _maquina;
  String _prioridad = 'MEDIA';
  bool _enviando = false;

  int get _unidades => widget.carrito.values.fold(0, (a, b) => a + b);

  void _cambiarCantidad(RepuestoEntity r, int delta) {
    final actual = widget.carrito[r] ?? 0;
    final nueva = actual + delta;
    setState(() {
      if (nueva <= 0) {
        widget.carrito.remove(r);
      } else if (nueva <= r.stockLibre || delta < 0) {
        widget.carrito[r] = nueva;
      }
    });
    widget.onCarritoActualizado();
  }

  Future<void> _formalizarPedido() async {
    if (widget.carrito.isEmpty) return;
    if (_maquina == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione la máquina afectada'), backgroundColor: AppColors.errorRed),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviando = true);
    final codMaquinaria = _maquina!['codMaquinaria'].toString();
    final itemsDto = widget.carrito.entries
        .map((e) => ItemRepuestoDto(codParte: e.key.codParte, cantidad: e.value))
        .toList();
    final dto = SolicitudCreacionDto(
      codMaquinaria: codMaquinaria,
      prioridad: _prioridad,
      justificacionTecnica: _justificacionCtrl.text.trim(),
      items: itemsDto,
    );

    try {
      final codSolicitud = await _remoteDataSource.registrarSolicitud(dto);
      setState(() {
        _enviando = false;
        widget.carrito.clear();
        _maquina = null;
      });
      widget.onCarritoActualizado();
      _justificacionCtrl.clear();
      if (!mounted) return;
      final num = RegExp(r'SOL-\d{4}-\d+').firstMatch(codSolicitud)?.group(0) ?? codSolicitud;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(Icons.check_circle_rounded, color: Colors.green[700], size: 56),
          title: const Text('¡Solicitud enviada!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(num, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber[800], borderRadius: BorderRadius.circular(20)),
                child: const Text('Pendiente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Administración revisará su solicitud. Puede seguir su estado en la pestaña "Historial".\n'
                'El stock se descuenta cuando el almacén entrega los repuestos; mientras tanto figura como reservado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onIrCatalogo?.call();
              },
              child: const Text('Ir al catálogo'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onPedidoEnviado?.call(num);
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('Ver detalle'),
            ),
          ],
        ),
      );
    } catch (e) {
      // [RF18] Sin conexión: se guarda como borrador local
      for (final entry in widget.carrito.entries) {
        await _localDataSource.guardarBorrador(SolicitudEntity(
          correlativo: 'BORRADOR-${DateTime.now().millisecondsSinceEpoch}',
          codParte: entry.key.codParte,
          nombreRepuesto: entry.key.nombre,
          cantidad: entry.value,
          prioridad: _prioridad,
          codigoMaquinaria: codMaquinaria,
          justificacion: _justificacionCtrl.text.trim(),
          estado: 'OFFLINE_LOCAL',
          fechaCreacion: DateTime.now(),
        ));
      }
      setState(() {
        _enviando = false;
        widget.carrito.clear();
      });
      widget.onCarritoActualizado();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin conexión. La solicitud se guardó en el teléfono'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Nueva Solicitud', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [NotificacionBell(), PerfilBoton()],
        backgroundColor: AppColors.primaryBlue,
      ),
      body: widget.carrito.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.post_add_rounded, size: 70, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text('Su solicitud está vacía', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Agregue los repuestos que necesita desde el catálogo.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    if (widget.onIrCatalogo != null) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                        onPressed: widget.onIrCatalogo,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Ir al catálogo'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              // [H-GEN-07] Espacio extra al final para poder desplazar el botón por encima del teclado
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Paso(numero: 1, titulo: 'Repuestos (${widget.carrito.length}) · $_unidades unidad(es)'),
                    Card(
                      color: AppColors.pureWhite,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ...widget.carrito.entries.map((e) => _ItemSolicitud(
                                repuesto: e.key,
                                cantidad: e.value,
                                onMas: () => _cambiarCantidad(e.key, 1),
                                onMenos: () => _cambiarCantidad(e.key, -1),
                                onQuitar: () {
                                  setState(() => widget.carrito.remove(e.key));
                                  widget.onCarritoActualizado();
                                },
                              )),
                          if (widget.onIrCatalogo != null)
                            TextButton.icon(
                              onPressed: widget.onIrCatalogo,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Agregar más repuestos'),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Paso(numero: 2, titulo: 'Máquina afectada'),
                    _BuscadorMaquina(
                      datasource: _remoteDataSource,
                      seleccionada: _maquina,
                      onSeleccion: (m) => setState(() => _maquina = m),
                    ),
                    const SizedBox(height: 18),
                    const _Paso(numero: 3, titulo: 'Urgencia'),
                    Row(
                      children: [
                        _OpcionPrioridad('BAJA', 'Rutina', Icons.low_priority_rounded, Colors.blueGrey, _prioridad,
                            (v) => setState(() => _prioridad = v)),
                        const SizedBox(width: 8),
                        _OpcionPrioridad('MEDIA', 'Programado', Icons.schedule_rounded, Colors.amber[800]!, _prioridad,
                            (v) => setState(() => _prioridad = v)),
                        const SizedBox(width: 8),
                        _OpcionPrioridad('ALTA', 'Parada mina', Icons.priority_high_rounded, AppColors.errorRed, _prioridad,
                            (v) => setState(() => _prioridad = v)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _Paso(numero: 4, titulo: 'Justificación técnica'),
                    TextFormField(
                      controller: _justificacionCtrl,
                      maxLines: 3,
                      // [H-MEC-02] Al enfocar, desplaza también el botón "Enviar solicitud" sobre el teclado
                      scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                      decoration: const InputDecoration(
                        hintText: 'Describa por qué necesita cambiar estas piezas...',
                        filled: true,
                        fillColor: AppColors.pureWhite,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Escriba al menos 10 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _enviando ? null : _formalizarPedido,
                        icon: _enviando ? const SizedBox.shrink() : const Icon(Icons.send_rounded, color: Colors.white),
                        label: _enviando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Enviar solicitud', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Paso extends StatelessWidget {
  final int numero;
  final String titulo;
  const _Paso({required this.numero, required this.titulo});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primaryBlue,
            child: Text('$numero', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryBlue)),
          ),
        ]),
      );
}

class _ItemSolicitud extends StatelessWidget {
  final RepuestoEntity repuesto;
  final int cantidad;
  final VoidCallback onMas;
  final VoidCallback onMenos;
  final VoidCallback onQuitar;
  const _ItemSolicitud({
    required this.repuesto,
    required this.cantidad,
    required this.onMas,
    required this.onMenos,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final puedeMas = cantidad < repuesto.stockLibre;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(children: [
        ImagenProducto(url: repuesto.urlFoto, size: 50),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(repuesto.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(repuesto.codParte, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text('${repuesto.stockLibre} disponibles', style: TextStyle(fontSize: 11.5, color: Colors.green[700])),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(cantidad == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                  size: 18, color: cantidad == 1 ? AppColors.errorRed : null),
              onPressed: cantidad == 1 ? onQuitar : onMenos,
            ),
            Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_rounded, size: 18),
              onPressed: puedeMas ? onMas : null,
            ),
          ]),
        ),
      ]),
    );
  }
}

class _OpcionPrioridad extends StatelessWidget {
  final String valor;
  final String detalle;
  final IconData icono;
  final Color color;
  final String actual;
  final ValueChanged<String> onTap;
  const _OpcionPrioridad(this.valor, this.detalle, this.icono, this.color, this.actual, this.onTap);

  @override
  Widget build(BuildContext context) {
    final sel = valor == actual;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? color : Colors.grey.shade300),
          ),
          child: Column(children: [
            Icon(icono, color: sel ? Colors.white : color),
            const SizedBox(height: 2),
            Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: sel ? Colors.white : color)),
            Text(detalle, style: TextStyle(fontSize: 11, color: sel ? Colors.white70 : Colors.black54)),
          ]),
        ),
      ),
    );
  }
}

/// [MEC-05] Buscador de máquinas: sugiere mientras se escribe y permite elegir una
class _BuscadorMaquina extends StatefulWidget {
  final RepuestoRemoteDataSource datasource;
  final Map<String, dynamic>? seleccionada;
  final ValueChanged<Map<String, dynamic>?> onSeleccion;
  const _BuscadorMaquina({required this.datasource, required this.seleccionada, required this.onSeleccion});

  @override
  State<_BuscadorMaquina> createState() => _BuscadorMaquinaState();
}

class _BuscadorMaquinaState extends State<_BuscadorMaquina> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _resultados = [];
  bool _buscando = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onCambio(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() => _resultados = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _buscar(v.trim()));
  }

  Future<void> _buscar(String q) async {
    setState(() {
      _buscando = true;
      _error = null;
    });
    try {
      final r = await widget.datasource.buscarMaquinarias(q);
      if (mounted) setState(() => _resultados = r);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo buscar. Revise su conexión.');
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Color _colorEstado(String? e) => switch (e) {
        'OPERATIVA' => Colors.green[700]!,
        'EN_MANTENIMIENTO' => Colors.amber[800]!,
        'INOPERATIVA' || 'BAJA' => AppColors.errorRed,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    final m = widget.seleccionada;
    if (m != null) {
      return Card(
        color: AppColors.pureWhite,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primaryBlue),
        ),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            child: Icon(Icons.precision_manufacturing_rounded, color: Colors.white),
          ),
          title: Text('${m['codMaquinaria']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${m['modeloMaquinaria'] ?? ''}  ·  Serie ${m['serieFabricante'] ?? '-'}'),
          trailing: TextButton(
            onPressed: () {
              widget.onSeleccion(null);
              _ctrl.clear();
              setState(() => _resultados = []);
            },
            child: const Text('Cambiar'),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: 'Escriba código o modelo (ej. RB, 01...)',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _buscando
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
            filled: true,
            fillColor: AppColors.pureWhite,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onCambio,
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 12.5)),
          ),
        if (_resultados.isNotEmpty)
          Card(
            color: AppColors.pureWhite,
            margin: const EdgeInsets.only(top: 4),
            elevation: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _resultados.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = _resultados[i];
                  final est = r['estadoOperativo']?.toString();
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.precision_manufacturing_outlined, color: AppColors.primaryBlue),
                    title: Text('${r['codMaquinaria']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r['modeloMaquinaria'] ?? ''}'),
                    trailing: est == null
                        ? null
                        : Text(est.replaceAll('_', ' ').toLowerCase(),
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _colorEstado(est))),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      widget.onSeleccion(r);
                    },
                  );
                },
              ),
            ),
          )
        else if (_ctrl.text.trim().isNotEmpty && !_buscando && _error == null)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('No se encontraron máquinas con ese texto', style: TextStyle(color: Colors.black54, fontSize: 12.5)),
          ),
      ],
    );
  }
}

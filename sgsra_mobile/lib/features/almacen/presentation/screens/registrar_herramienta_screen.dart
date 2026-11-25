import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/imagen_producto.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import '../widgets/herramienta_ui.dart';
import 'detalle_herramienta_screen.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

/// [RF45, ALM-04, ALM-05] Pestaña "Herramientas": catálogo del pañol con buscador predictivo,
/// filtros, detalle de cada herramienta y botones flotantes para alta y extravío.
class RegistrarHerramientaScreen extends StatefulWidget {
  const RegistrarHerramientaScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarHerramientaScreen> createState() => _RegistrarHerramientaScreenState();
}

class _RegistrarHerramientaScreenState extends State<RegistrarHerramientaScreen> {
  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());
  final _buscarCtrl = TextEditingController();
  bool _isLoading = true;
  String? _error;
  List<HerramientaEntity> _herramientas = [];
  /// [H-ALM-06] Préstamo activo de cada herramienta (código → préstamo) para mostrar al custodio
  Map<String, PrestamoEntity> _custodios = {};
  String _categoria = 'TODAS';
  String _estado = 'TODOS';

  static const _categorias = {
    'TODAS': 'Todas',
    'MANUALES': 'Manuales',
    'HIDRAULICAS': 'Hidráulicas',
    'NEUMATICAS': 'Neumáticas',
    'ELECTRICAS': 'Eléctricas',
  };

  @override
  void initState() {
    super.initState();
    _cargarHerramientas();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<List<PrestamoEntity>> _prestamosSinFallar() async {
    try {
      return await _dataSource.listarPrestamos();
    } catch (_) {
      return [];
    }
  }

  Future<void> _cargarHerramientas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final r = await Future.wait([
        _dataSource.listarHerramientas(categoria: _categoria),
        // Si falla la consulta de préstamos, la lista de herramientas se muestra igual
        _prestamosSinFallar(),
      ]);
      final list = r[0] as List<HerramientaEntity>;
      final custodios = <String, PrestamoEntity>{};
      for (final p in r[1] as List<PrestamoEntity>) {
        if (p.estadoPrestamo.toUpperCase() == 'DEVUELTO') continue;
        for (final cod in p.herramientas) {
          custodios[cod] = p;
        }
      }
      if (!mounted) return;
      setState(() {
        _herramientas = list..sort((a, b) => a.codHerramienta.compareTo(b.codHerramienta));
        _custodios = custodios;
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

  List<HerramientaEntity> get _filtradas {
    final q = _buscarCtrl.text.trim().toLowerCase();
    return _herramientas.where((h) {
      final okTexto = q.isEmpty || '${h.codHerramienta} ${h.nombre} ${h.marca}'.toLowerCase().contains(q);
      final okEstado = _estado == 'TODOS' || claveEstadoHerramienta(h.estadoActual) == _estado;
      return okTexto && okEstado;
    }).toList();
  }

  Future<void> _abrirDetalle(HerramientaEntity h) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleHerramientaScreen(herramienta: h)));
    _cargarHerramientas();
  }

  void _abrirModalCrear() {
    final formKey = GlobalKey<FormState>();
    final codCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    String catSel = 'MANUALES';
    // [H-ALM-09] Foto opcional elegida antes de crear la herramienta
    XFile? foto;
    Uint8List? fotoBytes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
        title: const Text('Nueva herramienta'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // [H-ALM-09] Foto de la herramienta (opcional) desde el alta
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: fotoBytes != null
                          ? Image.memory(fotoBytes!, width: 64, height: 64, fit: BoxFit.cover)
                          : Container(
                              width: 64,
                              height: 64,
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              child: const Icon(Icons.handyman_outlined, color: AppColors.primaryBlue),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                          onPressed: () async {
                            final f = await elegirImagen(ctx, titulo: 'Foto de la herramienta');
                            if (f == null) return;
                            final b = await f.readAsBytes();
                            setDlg(() {
                              foto = f;
                              fotoBytes = b;
                            });
                          },
                          icon: Icon(fotoBytes == null ? Icons.add_a_photo_outlined : Icons.cached_rounded, size: 18),
                          label: Text(fotoBytes == null ? 'Agregar foto' : 'Cambiar foto'),
                        ),
                        if (fotoBytes != null)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero, alignment: Alignment.centerLeft, foregroundColor: Colors.black54),
                            onPressed: () => setDlg(() {
                              foto = null;
                              fotoBytes = null;
                            }),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: const Text('Quitar'),
                          )
                        else
                          const Text('Opcional', style: TextStyle(fontSize: 12, color: Colors.black45)),
                      ]),
                    ),
                  ]),
                ),
                TextFormField(
                  controller: codCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Código (ej. HER-TOR-099)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca / Fabricante')),
                DropdownButtonFormField<String>(
                  initialValue: catSel,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categorias.entries
                      .where((e) => e.key != 'TODAS')
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (val) => catSel = val ?? 'MANUALES',
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final cod = codCtrl.text.trim().toUpperCase();
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _dataSource.registrarNuevaHerramienta({
                  'codHerramienta': cod,
                  'nombreHerramienta': nomCtrl.text.trim(),
                  'marcaHerramienta': marcaCtrl.text.trim(),
                  'categoria': catSel,
                  'estadoActual': 'DISPONIBLE',
                });
              } catch (e) {
                messenger.showSnackBar(
                    SnackBar(content: Text(mensajeDeError(e)), backgroundColor: AppColors.errorRed));
                return;
              }
              // [H-ALM-09] La foto elegida en el formulario se sube justo después de crear el registro
              final fotoElegida = foto;
              if (fotoElegida != null && mounted) {
                await subirImagen(context, '/inventario/herramientas/$cod/imagen', fotoElegida);
              } else {
                messenger.showSnackBar(
                    SnackBar(content: Text('$cod registrada'), backgroundColor: Colors.green[700]));
              }
              await _cargarHerramientas();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtradas;
    final conteo = <String, int>{};
    for (final h in _herramientas) {
      final k = claveEstadoHerramienta(h.estadoActual);
      conteo[k] = (conteo[k] ?? 0) + 1;
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Herramientas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarHerramientas),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      // [H-ALM-05] Se retiró el botón flotante de extravío: el reporte se hace desde el detalle
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-nueva',
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _abrirModalCrear,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva herramienta'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(children: [
              TextField(
                controller: _buscarCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar por código, nombre o marca',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _buscarCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(_buscarCtrl.clear),
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.backgroundGray,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._categorias.entries.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(c.value),
                            selected: _categoria == c.key,
                            showCheckmark: false,
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                                color: _categoria == c.key ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                            onSelected: (_) {
                              setState(() => _categoria = c.key);
                              _cargarHerramientas();
                            },
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['TODOS', 'DISPONIBLE', 'PRESTADA', 'EN_MORA', 'EN_MANTENIMIENTO', 'EXTRAVIADA'].map((e) {
                    final sel = _estado == e;
                    final c = e == 'TODOS' ? AppColors.primaryBlue : colorEstadoHerramienta(e);
                    final n = e == 'TODOS' ? _herramientas.length : (conteo[e] ?? 0);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        visualDensity: VisualDensity.compact,
                        label: Text('${e == 'TODOS' ? 'Todos' : etiquetaEstadoHerramienta(e)} ($n)'),
                        selected: sel,
                        showCheckmark: false,
                        selectedColor: c.withValues(alpha: 0.18),
                        side: BorderSide(color: sel ? c : Colors.grey.shade300),
                        labelStyle: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
                        onSelected: (_) => setState(() => _estado = e),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _cargarHerramientas,
                    child: _error != null
                        ? ListView(children: [
                            const SizedBox(height: 80),
                            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
                            Center(child: Padding(padding: const EdgeInsets.all(12), child: Text(_error!, textAlign: TextAlign.center))),
                            Center(
                                child: TextButton.icon(
                                    onPressed: _cargarHerramientas, icon: const Icon(Icons.refresh), label: const Text('Reintentar'))),
                          ])
                        : lista.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 80),
                                Icon(Icons.handyman_outlined, size: 60, color: Colors.grey),
                                SizedBox(height: 8),
                                Center(child: Text('No hay herramientas que coincidan.')),
                              ])
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 140),
                                itemCount: lista.length,
                                itemBuilder: (context, index) {
                                  final h = lista[index];
                                  return Card(
                                    color: AppColors.pureWhite,
                                    elevation: 1.5,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _abrirDetalle(h),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FilaHerramienta(h,
                                                trailing:
                                                    const Icon(Icons.chevron_right_rounded, color: Colors.black38)),
                                            if (_custodios[h.codHerramienta] != null)
                                              _FilaCustodio(_custodios[h.codHerramienta]!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// [H-ALM-06] Nombre y DNI del mecánico que tiene la herramienta, visibles sin abrir el detalle
class _FilaCustodio extends StatelessWidget {
  final PrestamoEntity p;
  const _FilaCustodio(this.p);

  @override
  Widget build(BuildContext context) {
    final enMora = claveEstadoHerramienta(p.estadoPrestamo) == 'EN_MORA';
    final color = enMora ? colorEstadoHerramienta('EN_MORA') : AppColors.primaryBlue;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(Icons.person_pin_rounded, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: p.nombreMecanico, style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: '  ·  DNI ${p.dniMecanico}', style: const TextStyle(color: Colors.black54)),
            ]),
            style: const TextStyle(fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(p.prestamoNum, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

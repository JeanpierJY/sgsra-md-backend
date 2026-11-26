import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/imagen_producto.dart';
import 'proveedores_modal.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import '../../../../core/widgets/perfil_boton.dart';

class MantenimientoCatalogoScreen extends StatefulWidget {
  const MantenimientoCatalogoScreen({Key? key}) : super(key: key);

  @override
  State<MantenimientoCatalogoScreen> createState() =>
      _MantenimientoCatalogoScreenState();
}

class _MantenimientoCatalogoScreenState
    extends State<MantenimientoCatalogoScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<dynamic> _repuestos = [];
  String _busqueda = '';
  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/catalogo',
          // [H-ADM-01] Incluye repuestos deshabilitados para poder reactivarlos
          queryParameters: {'size': 300, 'incluirInactivos': true});
      final List<dynamic> recibidos;
      if (res.data is Map && res.data['content'] != null) {
        recibidos = List<dynamic>.from(res.data['content']);
      } else if (res.data is List) {
        recibidos = List<dynamic>.from(res.data);
      } else {
        recibidos = [];
      }
      // [H-ADM-01b] Si el servidor no devuelve un repuesto que ya se sabía deshabilitado
      // (backend sin el parámetro incluirInactivos), se conserva en la lista para poder reactivarlo
      final codigos = recibidos.map((r) => r['codParte']).toSet();
      final deshabilitadosConocidos = _repuestos
          .where((r) => r['activo'] == false && !codigos.contains(r['codParte']))
          .toList();
      if (!mounted) return;
      setState(() {
        _repuestos = [...recibidos, ...deshabilitadosConocidos]
          ..sort((a, b) => '${a['codParte']}'.compareTo('${b['codParte']}'));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al cargar catálogo: ${mensajeDeError(e)}',
          esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(texto),
          backgroundColor:
              esError ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  /// [H-ADM-01b] Actualiza solo la tarjeta del repuesto (sin recargar toda la lista, que
  /// hacía desaparecer el repuesto deshabilitado) y revierte el switch si la API falla.
  Future<void> _cambiarEstadoRepuesto(String codParte, bool activo) async {
    final item = _repuestos.firstWhere((r) => r['codParte'] == codParte, orElse: () => null);
    if (item == null) return;
    final anterior = item['activo'] ?? true;
    setState(() => item['activo'] = activo);
    try {
      await _dioClient.dio.put('/catalogo/$codParte/estado',
          queryParameters: {'activo': activo});
      _mostrarMensaje(activo
          ? 'Repuesto $codParte habilitado'
          : 'Repuesto $codParte deshabilitado: ya no aparece disponible para los mecánicos');
    } catch (e) {
      if (mounted) setState(() => item['activo'] = anterior);
      _mostrarMensaje('Error al cambiar estado: ${mensajeDeError(e)}',
          esError: true);
    }
  }

  /// [ADM-08] Sube o reemplaza la foto del repuesto
  Future<void> _cambiarImagen(dynamic item) async {
    final r = await seleccionarYSubirImagen(
        context, '/catalogo/${item['codParte']}/imagen');
    if (r != null) _cargarCatalogo();
  }

  void _abrirModalCrearRepuesto() {
    final formKey = GlobalKey<FormState>();
    final codCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir Repuesto',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: 'Código de Parte (Ej. P-REX-024)'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El código es obligatorio'
                      : null,
                ),
                TextFormField(
                  controller: nomCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre Técnico'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(labelText: 'Stock Inicial'),
                        validator: (v) => AppValidators.validarStock(v,
                            campo: 'Stock Inicial'),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Especificación Técnica'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                try {
                  await _dioClient.dio.post('/catalogo', data: {
                    'codParte': codCtrl.text.trim().toUpperCase(),
                    'nombreRepuesto': nomCtrl.text.trim(),
                    'stockActual': int.parse(stockCtrl.text.trim()),
                    'stockMinimo': 0, // [H-ADM-06] campo oculto en la UI; el backend lo exige
                    'descripcion': descCtrl.text.trim(),
                  });
                  _mostrarMensaje('Repuesto guardado en catálogo maestro');
                  _cargarCatalogo();
                } catch (e) {
                  _mostrarMensaje(
                      'No se pudo registrar el repuesto: ${mensajeDeError(e)}',
                      esError: true);
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirModalEditar(dynamic repuesto) {
    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: repuesto['nombreRepuesto']);
    final stockCtrl = TextEditingController(text: '${repuesto['stockActual']}');
    final descCtrl = TextEditingController(text: repuesto['descripcion'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Repuesto ${repuesto['codParte']}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre Técnico'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(labelText: 'Stock Actual'),
                        validator: (v) => AppValidators.validarStock(v,
                            campo: 'Stock Actual'),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                await _dioClient.dio
                    .put('/catalogo/${repuesto['codParte']}', data: {
                  'nombreRepuesto': nomCtrl.text.trim(),
                  'stockActual': int.parse(stockCtrl.text.trim()),
                  'stockMinimo': repuesto['stockMinimo'] ?? 0, // [H-ADM-06] se conserva el valor guardado
                  'descripcion': descCtrl.text.trim(),
                });
                _mostrarMensaje('Repuesto actualizado');
                _cargarCatalogo();
              } catch (e) {
                _mostrarMensaje('No se pudo actualizar: ${mensajeDeError(e)}',
                    esError: true);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Catálogo Maestro',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.business_center_rounded),
            tooltip: 'Proveedores Homologados',
            onPressed: () => mostrarModalProveedores(context),
          ),
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Actualizar',
              onPressed: _cargarCatalogo),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-anadir-repuesto',
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _abrirModalCrearRepuesto,
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Añadir repuesto',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        Container(
          color: AppColors.pureWhite,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar repuesto por nombre o código',
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.backgroundGray,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                onChanged: (v) =>
                    setState(() => _busqueda = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final entry in [
                      ('TODOS', 'Todos (${_repuestos.length})'),
                      (
                        'HABILITADOS',
                        'Habilitados (${_repuestos.where((r) => (r['activo'] ?? true) == true).length})'
                      ),
                      (
                        'DESHABILITADOS',
                        'Deshabilitados (${_repuestos.where((r) => (r['activo'] ?? true) == false).length})'
                      ),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.$2),
                          selected: _filtroEstado == entry.$1,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: _filtroEstado == entry.$1
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          onSelected: (_) =>
                              setState(() => _filtroEstado = entry.$1),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Builder(builder: (context) {
          final lista = _repuestos.where((r) {
            final coincideTexto = _busqueda.isEmpty ||
                '${r['nombreRepuesto']} ${r['codParte']}'
                    .toLowerCase()
                    .contains(_busqueda);
            final activo = (r['activo'] ?? true) == true;
            final coincideEstado = _filtroEstado == 'TODOS' ||
                (_filtroEstado == 'HABILITADOS' && activo) ||
                (_filtroEstado == 'DESHABILITADOS' && !activo);
            return coincideTexto && coincideEstado;
          }).toList();
          return _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue))
              : lista.isEmpty
                  ? const Center(child: Text('No hay repuestos que coincidan.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final item = lista[index];
                        final activo = item['activo'] ?? true;

                        return Card(
                          color: AppColors.pureWhite,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () => _cambiarImagen(item),
                              child: Stack(clipBehavior: Clip.none, children: [
                                ImagenProducto(
                                  url: item['imagenUrl']?.toString(),
                                  size: 54,
                                  ampliable: false,
                                  color: activo
                                      ? AppColors.primaryBlue
                                      : Colors.grey,
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: const Icon(
                                        Icons.photo_camera_rounded,
                                        size: 12,
                                        color: Colors.white),
                                  ),
                                ),
                              ]),
                            ),
                            title: Text(
                                '${item['nombreRepuesto']} (${item['codParte']})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${activo ? '' : 'DESHABILITADO · no visible para mecánicos\n'}'
                              'Stock Actual: ${item['stockActual']}\nDescripción: ${item['descripcion'] ?? 'Sin descripción'}',
                              style: activo ? null : const TextStyle(color: Colors.black45),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.primaryBlue),
                                  onPressed: () => _abrirModalEditar(item),
                                ),
                                Switch(
                                  value: activo,
                                  activeColor: AppColors.primaryBlue,
                                  onChanged: (val) => _cambiarEstadoRepuesto(
                                      item['codParte'], val),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
        })),
      ]),
    );
  }
}

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
  State<MantenimientoCatalogoScreen> createState() => _MantenimientoCatalogoScreenState();
}

class _MantenimientoCatalogoScreenState extends State<MantenimientoCatalogoScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<dynamic> _repuestos = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/catalogo', queryParameters: {'size': 300});
      setState(() {
        if (res.data is Map && res.data['content'] != null) {
          _repuestos = res.data['content'];
        } else if (res.data is List) {
          _repuestos = res.data;
        } else {
          _repuestos = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al cargar catálogo: ${mensajeDeError(e)}', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  Future<void> _cambiarEstadoRepuesto(String codParte, bool activo) async {
    try {
      await _dioClient.dio.put('/catalogo/$codParte/estado', queryParameters: {'activo': activo});
      _mostrarMensaje('Estado de $codParte actualizado');
      _cargarCatalogo();
    } catch (e) {
      _mostrarMensaje('Error al cambiar estado: ${mensajeDeError(e)}', esError: true);
    }
  }

  /// [ADM-08] Sube o reemplaza la foto del repuesto
  Future<void> _cambiarImagen(dynamic item) async {
    final r = await seleccionarYSubirImagen(context, '/catalogo/${item['codParte']}/imagen');
    if (r != null) _cargarCatalogo();
  }

  void _abrirModalCrearRepuesto() {
    final formKey = GlobalKey<FormState>();
    final codCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir Repuesto [RF32]', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Código de Parte (Ej. P-REX-024)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'El código es obligatorio' : null,
                ),
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre Técnico'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Stock Inicial'),
                        validator: (v) => AppValidators.validarStock(v, campo: 'Stock Inicial'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                        validator: (v) => AppValidators.validarStock(v, campo: 'Stock Mínimo'),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Proveedor / Especificación Técnica [RF27]'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                try {
                  await _dioClient.dio.post('/catalogo', data: {
                    'codParte': codCtrl.text.trim().toUpperCase(),
                    'nombreRepuesto': nomCtrl.text.trim(),
                    'stockActual': int.parse(stockCtrl.text.trim()),
                    'stockMinimo': int.parse(minCtrl.text.trim()),
                    'descripcion': descCtrl.text.trim(),
                  });
                  _mostrarMensaje('Repuesto guardado en catálogo maestro');
                  _cargarCatalogo();
                } catch (e) {
                  _mostrarMensaje('No se pudo registrar el repuesto: ${mensajeDeError(e)}', esError: true);
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
    final minCtrl = TextEditingController(text: '${repuesto['stockMinimo']}');
    final descCtrl = TextEditingController(text: repuesto['descripcion'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar Repuesto ${repuesto['codParte']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre Técnico'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Stock Actual'),
                        validator: (v) => AppValidators.validarStock(v, campo: 'Stock Actual'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                        validator: (v) => AppValidators.validarStock(v, campo: 'Stock Mínimo'),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                await _dioClient.dio.put('/catalogo/${repuesto['codParte']}', data: {
                  'nombreRepuesto': nomCtrl.text.trim(),
                  'stockActual': int.parse(stockCtrl.text.trim()),
                  'stockMinimo': int.parse(minCtrl.text.trim()),
                  'descripcion': descCtrl.text.trim(),
                });
                _mostrarMensaje('Repuesto actualizado');
                _cargarCatalogo();
              } catch (e) {
                _mostrarMensaje('No se pudo actualizar: ${mensajeDeError(e)}', esError: true);
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
        title: const Text('Catálogo Maestro [RF32]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'Actualizar', onPressed: _cargarCatalogo),
          const NotificacionBell(),
          const PerfilBoton(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab-proveedores',
            backgroundColor: AppColors.pureWhite,
            foregroundColor: AppColors.primaryBlue,
            elevation: 3,
            onPressed: () => mostrarModalProveedores(context),
            icon: const Icon(Icons.business_center_rounded, size: 20),
            label: const Text('Proveedores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'fab-anadir-repuesto',
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: _abrirModalCrearRepuesto,
            icon: const Icon(Icons.add_box_rounded),
            label: const Text('Añadir repuesto', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: AppColors.pureWhite,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar repuesto por nombre o código',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              filled: true,
              fillColor: AppColors.backgroundGray,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _busqueda = v.trim().toLowerCase()),
          ),
        ),
        Expanded(child: Builder(builder: (context) {
          final lista = _repuestos
              .where((r) => _busqueda.isEmpty ||
                  '${r['nombreRepuesto']} ${r['codParte']}'.toLowerCase().contains(_busqueda))
              .toList();
          return _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _cambiarImagen(item),
                          child: Stack(clipBehavior: Clip.none, children: [
                            ImagenProducto(
                              url: item['imagenUrl']?.toString(),
                              size: 54,
                              ampliable: false,
                              color: activo ? AppColors.primaryBlue : Colors.grey,
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Icon(Icons.photo_camera_rounded, size: 12, color: Colors.white),
                              ),
                            ),
                          ]),
                        ),
                        title: Text('${item['nombreRepuesto']} (${item['codParte']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Stock Actual: ${item['stockActual']} | Mínimo: ${item['stockMinimo']}\nDescripción: ${item['descripcion'] ?? 'Sin descripción'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                              onPressed: () => _abrirModalEditar(item),
                            ),
                            Switch(
                              value: activo,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (val) => _cambiarEstadoRepuesto(item['codParte'], val),
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

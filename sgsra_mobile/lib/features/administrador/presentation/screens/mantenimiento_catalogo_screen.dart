import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import 'proveedores_modal.dart';

class MantenimientoCatalogoScreen extends StatefulWidget {
  const MantenimientoCatalogoScreen({Key? key}) : super(key: key);

  @override
  State<MantenimientoCatalogoScreen> createState() => _MantenimientoCatalogoScreenState();
}

class _MantenimientoCatalogoScreenState extends State<MantenimientoCatalogoScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<dynamic> _repuestos = [];

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/catalogo', queryParameters: {'size': 50});
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
      _mostrarMensaje('Error al cargar catalogo: $e', esError: true);
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
      _mostrarMensaje('Error al cambiar estado: $e', esError: true);
    }
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
        title: const Text('Registrar Nuevo Repuesto Homologado [RF32]'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codCtrl,
                  decoration: const InputDecoration(labelText: 'Codigo de Parte (Ej. P-REX-024)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                TextFormField(
                  controller: nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre Tecnico'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock Inicial'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock Minimo'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Proveedor / Especificacion Tecnica [RF27]'),
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
                  _mostrarMensaje('Repuesto guardado en catalogo maestro');
                  _cargarCatalogo();
                } catch (e) {
                  _mostrarMensaje('Error al registrar repuesto: $e', esError: true);
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
        title: Text('Editar Repuesto ${repuesto['codParte']}'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre Tecnico')),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Actual'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Minimo'))),
                  ],
                ),
                TextFormField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripcion')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
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
                _mostrarMensaje('Error al actualizar: $e', esError: true);
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
        title: const Text('Catalogo Maestro de Repuestos [RF32]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.business_center_rounded),
            tooltip: 'Proveedores Homologados [RF27]',
            onPressed: () => mostrarModalProveedores(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            tooltip: 'Alta de Repuesto',
            onPressed: _abrirModalCrearRepuesto,
          ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarCatalogo),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _repuestos.isEmpty
              ? const Center(child: Text('No hay piezas registradas en el catalogo.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _repuestos.length,
                  itemBuilder: (context, index) {
                    final item = _repuestos[index];
                    final activo = item['activo'] ?? true;

                    return Card(
                      color: AppColors.pureWhite,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: activo ? AppColors.primaryBlue : Colors.grey,
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                        title: Text('${item['nombreRepuesto']} (${item['codParte']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Stock Actual: ${item['stockActual']} | Minimo: ${item['stockMinimo']}\nDescripcion: ${item['descripcion'] ?? 'Sin descripcion'}',
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
                ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';
import 'reportar_extravio_modal.dart';

class RegistrarHerramientaScreen extends StatefulWidget {
  const RegistrarHerramientaScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarHerramientaScreen> createState() => _RegistrarHerramientaScreenState();
}

class _RegistrarHerramientaScreenState extends State<RegistrarHerramientaScreen> {
  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());
  bool _isLoading = true;
  List<HerramientaEntity> _herramientas = [];
  String _filtro = 'TODAS';

  @override
  void initState() {
    super.initState();
    _cargarHerramientas();
  }

  Future<void> _cargarHerramientas() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dataSource.listarHerramientas(categoria: _filtro);
      setState(() {
        _herramientas = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _herramientas = const [
          HerramientaEntity(codHerramienta: 'HER-TOR-004', nombre: 'Torquímetro Industrial 3/4', marca: 'Enerpac', categoria: 'HIDRAULICAS', estadoActual: 'DISPONIBLE'),
          HerramientaEntity(codHerramienta: 'HER-LLA-012', nombre: 'Juego Llaves Corona', marca: 'SATA', categoria: 'MANUALES', estadoActual: 'PRESTADA'),
          HerramientaEntity(codHerramienta: 'HER-TAL-001', nombre: 'Taladro Percutor Neumático', marca: 'Atlas Copco', categoria: 'NEUMATICAS', estadoActual: 'EN_MANTENIMIENTO'),
        ];
        _isLoading = false;
      });
    }
  }

  void _abrirModalCrear() {
    final formKey = GlobalKey<FormState>();
    final codCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final marcaCtrl = TextEditingController();
    String catSel = 'MANUALES';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alta de Herramienta en Pañol'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: codCtrl, decoration: const InputDecoration(labelText: 'Código de Activo (ej. HER-TOR-099)'), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              TextFormField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nombre de Herramienta'), validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null),
              TextFormField(controller: marcaCtrl, decoration: const InputDecoration(labelText: 'Marca / Fabricante')),
              DropdownButtonFormField<String>(
                value: catSel,
                decoration: const InputDecoration(labelText: 'Categoría Técnica [RF45]'),
                items: const [
                  DropdownMenuItem(value: 'MANUALES', child: Text('Manuales')),
                  DropdownMenuItem(value: 'HIDRAULICAS', child: Text('Hidráulicas')),
                  DropdownMenuItem(value: 'NEUMATICAS', child: Text('Neumáticas')),
                  DropdownMenuItem(value: 'ELECTRICAS', child: Text('Eléctricas')),
                ],
                onChanged: (val) => catSel = val ?? 'MANUALES',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                await _dataSource.registrarNuevaHerramienta({
                  'codHerramienta': codCtrl.text.trim().toUpperCase(),
                  'nombreHerramienta': nomCtrl.text.trim(),
                  'marcaHerramienta': marcaCtrl.text.trim(),
                  'categoria': catSel,
                  'estadoActual': 'DISPONIBLE',
                });
                _cargarHerramientas();
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
        title: const Text('Catálogo de Herramientas [RF45]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: 'Reportar Extravío [RF41]',
            onPressed: () => mostrarModalReportarExtravio(context, _cargarHerramientas),
          ),
          IconButton(icon: const Icon(Icons.add_box_rounded), tooltip: 'Alta Herramienta', onPressed: _abrirModalCrear),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarHerramientas),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['TODAS', 'MANUALES', 'HIDRAULICAS', 'NEUMATICAS', 'ELECTRICAS'].map((c) {
                  final sel = _filtro == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      selected: sel,
                      label: Text(c),
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryBlue,
                      onSelected: (_) {
                        setState(() => _filtro = c);
                        _cargarHerramientas();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : _herramientas.isEmpty
                    ? const Center(child: Text('No hay herramientas registradas.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _herramientas.length,
                        itemBuilder: (context, index) {
                          final h = _herramientas[index];
                          final estado = h.estadoActual;

                          return Card(
                            color: AppColors.pureWhite,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: estado == 'DISPONIBLE'
                                    ? Colors.green[700]
                                    : (estado == 'PRESTADA' ? AppColors.primaryBlue : AppColors.errorRed),
                                child: const Icon(Icons.handyman, color: Colors.white, size: 20),
                              ),
                              title: Text('${h.nombre} (${h.codHerramienta})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Marca: ${h.marca} | Categoría: ${h.categoria}\nEstado: $estado'),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
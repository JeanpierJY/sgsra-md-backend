import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/almacen_remote_datasource.dart';
import '../../domain/entities/almacen_entities.dart';

class DevolucionInspeccionScreen extends StatefulWidget {
  const DevolucionInspeccionScreen({Key? key}) : super(key: key);

  @override
  State<DevolucionInspeccionScreen> createState() => _DevolucionInspeccionScreenState();
}

class _DevolucionInspeccionScreenState extends State<DevolucionInspeccionScreen> {
  final AlmacenRemoteDataSource _dataSource = AlmacenRemoteDataSource(DioClient());
  final _formKey = GlobalKey<FormState>();
  final _obsCtrl = TextEditingController(text: 'Inspeccion tecnica conforme');
  final _herramientaCtrl = TextEditingController();

  bool _cargando = true;
  bool _enviando = false;
  List<PrestamoEntity> _prestamosActivos = [];
  String? _prestamoSeleccionado;
  String _estadoFisico = 'BUEN_ESTADO';

  @override
  void initState() {
    super.initState();
    _cargarPrestamos();
  }

  Future<void> _cargarPrestamos() async {
    setState(() => _cargando = true);
    try {
      final todos = await _dataSource.listarPrestamos();
      final activos = todos.where((p) => p.estadoPrestamo != 'CERRADO' && p.estadoPrestamo != 'DEVUELTO').toList();
      setState(() {
        _prestamosActivos = activos;
        if (_prestamosActivos.isNotEmpty) {
          _seleccionarPrestamo(_prestamosActivos.first);
        } else {
          _prestamoSeleccionado = null;
          _herramientaCtrl.clear();
        }
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  void _seleccionarPrestamo(PrestamoEntity p) {
    _prestamoSeleccionado = p.prestamoNum;
    if (p.herramientas.isNotEmpty) {
      String codLimpio = p.herramientas.first;
      if (codLimpio.contains('codHerramienta:')) {
        final match = RegExp(r'codHerramienta:\s*([^,\s}]+)').firstMatch(codLimpio);
        if (match != null) codLimpio = match.group(1)!;
      }
      _herramientaCtrl.text = codLimpio;
    } else {
      _herramientaCtrl.text = 'HER-TOR-004';
    }
  }

  Future<void> _confirmarRetorno() async {
    if (_formKey.currentState!.validate()) {
      if (_prestamoSeleccionado == null || _herramientaCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un prestamo y especifique el codigo del activo'), backgroundColor: AppColors.errorRed),
        );
        return;
      }

      setState(() => _enviando = true);
      try {
        final codHerramienta = _herramientaCtrl.text.trim();
        await _dataSource.registrarDevolucion(
          _prestamoSeleccionado!,
          codHerramienta,
          _estadoFisico,
          _obsCtrl.text.trim(),
        );

        setState(() => _enviando = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Retorno Concluido [RF40]', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            content: Text('Herramienta $codHerramienta recibida e inspeccionada en panol.\n\nCalificacion: $_estadoFisico\nPrestamo: $_prestamoSeleccionado cerrado.'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                onPressed: () {
                  Navigator.pop(ctx);
                  _cargarPrestamos();
                },
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } catch (e) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar retorno: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Retorno e Inspeccion [RF38]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarPrestamos),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Card(
                    color: AppColors.pureWhite,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Inspeccion Fisica de Entrada a Panol',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            const Divider(height: 24),
                            if (_prestamosActivos.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                child: const Text('No hay prestamos activos pendientes de devolucion en la base de datos.'),
                              )
                            else ...[
                              DropdownButtonFormField<String>(
                                value: _prestamoSeleccionado,
                                decoration: const InputDecoration(labelText: 'Prestamo Activo a Recibir [RF38]', border: OutlineInputBorder()),
                                items: _prestamosActivos.map((p) {
                                  return DropdownMenuItem<String>(
                                    value: p.prestamoNum,
                                    child: Text('${p.prestamoNum} - ${p.nombreMecanico}', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      final p = _prestamosActivos.firstWhere((element) => element.prestamoNum == val);
                                      _seleccionarPrestamo(p);
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _herramientaCtrl,
                                decoration: const InputDecoration(labelText: 'Codigo de Herramienta a Ingresar (ej. HER-TOR-004)', border: OutlineInputBorder()),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 14),
                              DropdownButtonFormField<String>(
                                value: _estadoFisico,
                                decoration: const InputDecoration(labelText: 'Calificacion Tecnica de Retorno [RF39]', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'BUEN_ESTADO', child: Text('BUEN ESTADO (Pasa a Disponible - RF40)')),
                                  DropdownMenuItem(value: 'CON_AVERIA', child: Text('CON AVERIA (Pasa a Mantenimiento - RF40)')),
                                  DropdownMenuItem(value: 'INCOMPLETA', child: Text('INCOMPLETA (Requiere informe tecnico)')),
                                ],
                                onChanged: (val) => setState(() => _estadoFisico = val ?? 'BUEN_ESTADO'),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _obsCtrl,
                                maxLines: 2,
                                decoration: const InputDecoration(labelText: 'Detalle de Inspeccion / Averia', border: OutlineInputBorder()),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _enviando ? null : _confirmarRetorno,
                                icon: _enviando ? const SizedBox.shrink() : const Icon(Icons.assignment_return_rounded, color: Colors.white),
                                label: _enviando
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('Confirmar Retorno Tecnico [RF40]', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
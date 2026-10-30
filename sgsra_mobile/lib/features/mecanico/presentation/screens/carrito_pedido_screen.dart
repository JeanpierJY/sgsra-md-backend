import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/repuesto_entity.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../data/datasources/repuesto_local_datasource.dart';
import '../../data/models/solicitud_request.dart';

class CarritoPedidoScreen extends StatefulWidget {
  final Map<RepuestoEntity, int> carrito;
  final VoidCallback onCarritoActualizado;

  const CarritoPedidoScreen({
    Key? key,
    required this.carrito,
    required this.onCarritoActualizado,
  }) : super(key: key);

  @override
  State<CarritoPedidoScreen> createState() => _CarritoPedidoScreenState();
}

class _CarritoPedidoScreenState extends State<CarritoPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maquinariaCtrl = TextEditingController(text: 'MD-RB-01');
  final _justificacionCtrl = TextEditingController();
  final RepuestoRemoteDataSource _remoteDataSource = RepuestoRemoteDataSource(DioClient());
  final RepuestoLocalDataSource _localDataSource = RepuestoLocalDataSource();

  String _prioridad = 'ALTA';
  bool _enviando = false;

  Future<void> _formalizarPedido() async {
    if (widget.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito se encuentra vacio'), backgroundColor: AppColors.errorRed),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _enviando = true);

      final itemsDto = widget.carrito.entries
          .map((e) => ItemRepuestoDto(codParte: e.key.codParte, cantidad: e.value))
          .toList();

      final dto = SolicitudCreacionDto(
        codMaquinaria: _maquinariaCtrl.text.trim(),
        prioridad: _prioridad,
        justificacionTecnica: _justificacionCtrl.text.trim(),
        items: itemsDto,
      );

      try {
        final codSolicitud = await _remoteDataSource.registrarSolicitud(dto);
        setState(() {
          _enviando = false;
          widget.carrito.clear();
        });
        widget.onCarritoActualizado();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Requerimiento Transmitido [RF17]', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            content: Text('Su solicitud ha sido enviada formalmente con el correlativo:\n\n$codSolicitud\n\nEstado asignado: PENDIENTE'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                onPressed: () {
                  // Cierra UNICAMENTE el cuadro de diálogo modal sin desmontar la pantalla
                  Navigator.pop(ctx);
                },
                child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      } catch (e) {
        for (final entry in widget.carrito.entries) {
          await _localDataSource.guardarBorrador(SolicitudEntity(
            correlativo: 'BORRADOR-${DateTime.now().millisecondsSinceEpoch}',
            codParte: entry.key.codParte,
            nombreRepuesto: entry.key.nombre,
            cantidad: entry.value,
            prioridad: _prioridad,
            codigoMaquinaria: _maquinariaCtrl.text.trim(),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sin conexion. Requerimiento guardado localmente en SQLite [RF18]'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Requerimiento / Carrito [RF13]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: widget.carrito.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No tiene repuestos en el carrito de requerimientos.', style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Piezas Agrupadas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                            const Divider(),
                            ...widget.carrito.entries.map((e) => ListTile(
                                  dense: true,
                                  title: Text('${e.key.nombre} (${e.key.codParte})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('Cantidad requerida: ${e.value}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                                    onPressed: () {
                                      setState(() {
                                        widget.carrito.remove(e.key);
                                      });
                                      widget.onCarritoActualizado();
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Parametros de la Orden:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _maquinariaCtrl,
                              decoration: const InputDecoration(labelText: 'Codigo de Maquinaria Afectada [RF15]', border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Indique el equipo minero' : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _prioridad,
                              decoration: const InputDecoration(labelText: 'Nivel de Urgencia [RF14]', border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 'BAJA', child: Text('BAJA - Mantenimiento Rutinario')),
                                DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA - Desgaste Programado')),
                                DropdownMenuItem(value: 'ALTA', child: Text('ALTA - Parada de Operacion Mina')),
                              ],
                              onChanged: (val) => setState(() => _prioridad = val ?? 'ALTA'),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _justificacionCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Justificacion Tecnica (> 10 caracteres) [RF16]',
                                hintText: 'Describa el motivo tecnico del cambio de piezas...',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().length < 10)
                                  ? 'La justificacion debe superar los 10 caracteres'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                        onPressed: _enviando ? null : _formalizarPedido,
                        icon: _enviando ? const SizedBox.shrink() : const Icon(Icons.send_rounded, color: Colors.white),
                        label: _enviando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Transmitir Solicitud Formal [RF17]', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
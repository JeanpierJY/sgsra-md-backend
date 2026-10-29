import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class CarritoSolicitudSheet extends StatefulWidget {
  final Map<String, dynamic> carrito;
  final VoidCallback onActualizar;

  const CarritoSolicitudSheet({super.key, required this.carrito, required this.onActualizar});

  @override
  State<CarritoSolicitudSheet> createState() => _CarritoSolicitudSheetState();
}

class _CarritoSolicitudSheetState extends State<CarritoSolicitudSheet> {
  final ApiService _apiService = ApiService();
  final TextEditingController _justificacionCtrl = TextEditingController();
  String _maquinaSeleccionada = "MD-RB-01";
  String _prioridad = "ALTA";
  bool _enviando = false;

  Future<void> _enviarSolicitud() async {
    if (widget.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El carrito esta vacio")));
      return;
    }
    if (_justificacionCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La justificacion tecnica debe contener minimo 10 caracteres")),
      );
      return;
    }

    setState(() => _enviando = true);
    final user = await _apiService.obtenerDatosUsuario();
    final rol = user['rol'] ?? 'MECANICO';
    final correo = user['email'] ?? 'carlos.mendoza@masterdrilling.com';

    if (rol != 'MECANICO') {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Solo un usuario con rol MECANICO puede emitir requerimientos.")),
      );
      return;
    }

    final items = widget.carrito.values.map((v) => {
      'codParte': v['codParte'],
      'cantidad': v['cantidad'],
    }).toList();

    final payload = {
      'codMaquinaria': _maquinaSeleccionada,
      'prioridad': _prioridad,
      'justificacionTecnica': _justificacionCtrl.text.trim(),
      'items': items,
    };

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      await _apiService.registrarSolicitud(correo, payload);
      widget.carrito.clear();
      widget.onActualizar();
      nav.pop();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Solicitud Transmitida"),
            ],
          ),
          content: const Text(
            "Su requerimiento ha sido registrado formalmente en la base de datos con estado PENDIENTE. "
            "El Administrador ya la visualiza en su bandeja.",
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Aceptar")),
          ],
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _enviando = false);
      messenger.showSnackBar(
        const SnackBar(content: Text("Error al transmitir solicitud al backend")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.carrito.values.toList();

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Lista de Pedido (Carrito)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text("No has agregado componentes a la solicitud.")),
            )
          else ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final it = list[i];
                  final int stockMax = it['stockMaximo'] ?? 999;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(it['nombreRepuesto'], style: const TextStyle(fontSize: 14)),
                    subtitle: Text("Codigo: ${it['codParte']} · Stock: $stockMax"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (it['cantidad'] > 1) {
                                it['cantidad']--;
                              } else {
                                widget.carrito.remove(it['codParte']);
                              }
                              widget.onActualizar();
                            });
                          },
                        ),
                        Text("${it['cantidad']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            if (it['cantidad'] >= stockMax) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Alcanzado el stock maximo disponible ($stockMax)")),
                              );
                              return;
                            }
                            setState(() {
                              it['cantidad']++;
                              widget.onActualizar();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _maquinaSeleccionada,
              decoration: const InputDecoration(labelText: "Maquinaria Afectada", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "MD-RB-01", child: Text("MD-RB-01 (Raise Borer Rhino 1008)")),
                DropdownMenuItem(value: "MD-RB-02", child: Text("MD-RB-02 (Jumbo Perforacion Frontal)")),
              ],
              onChanged: (v) => setState(() => _maquinaSeleccionada = v!),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              decoration: const InputDecoration(labelText: "Nivel de Prioridad", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "ALTA", child: Text("ALTA (Parada de Equipo)")),
                DropdownMenuItem(value: "MEDIA", child: Text("MEDIA (Preventivo)")),
                DropdownMenuItem(value: "BAJA", child: Text("BAJA (Stock Programado)")),
              ],
              onChanged: (v) => setState(() => _prioridad = v!),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _justificacionCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Justificacion Tecnica (>10 caracteres)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _enviando ? null : _enviarSolicitud,
              child: _enviando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("TRANSMITIR SOLICITUD FORMAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ]
        ],
      ),
    );
  }
}
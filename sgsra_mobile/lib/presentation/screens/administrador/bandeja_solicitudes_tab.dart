import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class BandejaSolicitudesTab extends StatefulWidget {
  const BandejaSolicitudesTab({super.key});

  @override
  State<BandejaSolicitudesTab> createState() => _BandejaSolicitudesTabState();
}

class _BandejaSolicitudesTabState extends State<BandejaSolicitudesTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _solicitudes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarBandeja();
  }

  Future<void> _cargarBandeja() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.listarBandejaAdministrador();
      setState(() {
        _solicitudes = res.data is List ? res.data : [];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _aprobar(String solicitudNum) async {
    try {
      await _apiService.aprobarSolicitudTotal(solicitudNum, "leao.chura@masterdrilling.com");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Solicitud $solicitudNum aprobada"), backgroundColor: Colors.green),
        );
        _cargarBandeja();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al aprobar solicitud"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _dialogoRechazo(String solicitudNum) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Rechazar $solicitudNum", style: const TextStyle(color: Color(0xFFFFB300))),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Motivo técnico (mínimo 15 caracteres)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().length >= 15) {
                Navigator.pop(ctx);
                await _apiService.rechazarSolicitudTotal(solicitudNum, "leao.chura@masterdrilling.com", controller.text.trim());
                _cargarBandeja();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("El motivo debe tener al menos 15 caracteres")),
                );
              }
            },
            child: const Text("RECHAZAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bandeja de Aprobaciones")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)))
          : _solicitudes.isEmpty
              ? const Center(child: Text("Bandeja al día. No hay solicitudes pendientes."))
              : RefreshIndicator(
                  onRefresh: _cargarBandeja,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _solicitudes.length,
                    itemBuilder: (context, index) {
                      final item = _solicitudes[index];
                      final estado = item['estado'] ?? 'PENDIENTE';
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['solicitudNum'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Chip(
                                    label: Text(estado, style: const TextStyle(fontSize: 11, color: Colors.black)),
                                    backgroundColor: estado == 'APROBADA'
                                        ? Colors.green
                                        : estado == 'RECHAZADA'
                                            ? Colors.red
                                            : const Color(0xFFFFB300),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text("Máquina: ${item['codMaquinaria']} | Mecánico: ${item['nombreMecanico']}"),
                              Text("Fecha: ${item['fechaEmision']} - Prioridad: ${item['prioridad']}"),
                              const SizedBox(height: 10),
                              if (estado == 'PENDIENTE')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _dialogoRechazo(item['solicitudNum']),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text("Rechazar"),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _aprobar(item['solicitudNum']),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      child: const Text("Aprobar"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
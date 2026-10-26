import 'package:flutter/material.dart';

class AdminSolicitudesScreen extends StatefulWidget {
  const AdminSolicitudesScreen({super.key});

  @override
  State<AdminSolicitudesScreen> createState() => _AdminSolicitudesScreenState();
}

class _AdminSolicitudesScreenState extends State<AdminSolicitudesScreen> {
  final _motivoRechazoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Lista simulada de requerimientos entrantes desde el taller (RF21)
  final List<Map<String, dynamic>> _solicitudesPendientes = [
    {
      'id': 'SOL-2026-001',
      'mecanico': 'Kevin Retes',
      'maquina': 'MD-RB-01 (Raise Boring)',
      'prioridad': 'CRÍTICA',
      'repuesto': 'Tricono de Perforación 12 1/4',
      'cantidad': 2,
      'justificacion': 'Desgaste severo en los cortadores cónicos tras 150 horas operativas en roca dura.'
    },
    {
      'id': 'SOL-2026-002',
      'mecanico': 'Jeanpierre Sánchez',
      'maquina': 'MD-TH-01 (Truck)',
      'prioridad': 'MEDIA',
      'repuesto': 'Filtro de Retorno de Sistema Hidráulico',
      'cantidad': 5,
      'justificacion': 'Mantenimiento preventivo programado según horómetro de la unidad.'
    }
  ];

  void _aprobarOrdenTotal(String id) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("✓ Requerimiento $id aprobado en su totalidad de forma rápida (RF23)."),
      backgroundColor: Colors.green,
    ));
    setState(() {
      _solicitudesPendientes.removeWhere((item) => item['id'] == id);
    });
  }

  void _abrirModalRechazo(String id) {
    _motivoRechazoController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text("Rechazar Solicitud $id", style: const TextStyle(color: Color(0xFFEF5350))),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _motivoRechazoController,
              decoration: const InputDecoration(
                labelText: "Motivo Técnico del Rechazo (RF25)",
                border: OutlineInputBorder(),
                hintText: "Escriba la causa de la denegación...",
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'El motivo es obligatorio';
                if (value.trim().length < 15) return 'Exige un mínimo de 15 caracteres descriptivos';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context); // Cierra diálogo
                  _procesarRechazo(id);
                }
              },
              child: const Text("CONFIRMAR RECHAZO"),
            ),
          ],
        );
      },
    );
  }

  void _procesarRechazo(String id) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("✕ Orden $id desestimada. Motivo guardado en bitácora de auditoría (RF24)."),
      backgroundColor: Colors.orange,
    ));
    setState(() {
      _solicitudesPendientes.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  void dispose() {
    _motivoRechazoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bandeja de Oficina Técnica"),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _solicitudesPendientes.isEmpty
          ? const Center(child: Text("No existen requerimientos pendientes de evaluación por fecha (RF21)."))
          : ListView.builder(
              itemCount: _solicitudesPendientes.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = _solicitudesPendientes[index];
                final bool esCritico = item['prioridad'] == 'CRÍTICA';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado de la Tarjeta (RF22)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF29B6F6))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: esCritico ? const Color(0xFFEF5350).withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['prioridad'],
                                style: TextStyle(color: esCritico ? const Color(0xFFEF5350) : Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 20),
                        
                        // Detalles Técnicos (RF22)
                        Text("Solicitante: ${item['mecanico']}", style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text("Equipo Afectado: ${item['maquina']}"),
                        const SizedBox(height: 8),
                        Text("Componente Pedido: ${item['repuesto']} (x${item['cantidad']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("Justificación: \"${item['justificacion']}\"", style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 16),

                        // Bloque de Acciones Administrativas Rápidas (RF23, RF24, RF26)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFEF5350)),
                                  foregroundColor: const Color(0xFFEF5350),
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text("RECHAZAR"),
                                onPressed: () => _abrirModalRechazo(item['id']),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB300),
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text("APROBAR"),
                                onPressed: () => _aprobarOrdenTotal(item['id']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

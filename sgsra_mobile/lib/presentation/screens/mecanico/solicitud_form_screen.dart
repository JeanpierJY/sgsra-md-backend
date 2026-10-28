import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/datasources/database_helper.dart';
import '../../../data/models/repuesto_model.dart';
import '../../../data/services/api_service.dart';

class SolicitudFormScreen extends StatefulWidget {
  final RepuestoModel repuestoInicial;

  const SolicitudFormScreen({super.key, required this.repuestoInicial});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _apiService = ApiService();
  final _dbHelper = DatabaseHelper();

  String _codMaquinaria = "MD-RB-01";
  String _prioridad = "ALTA";
  int _cantidad = 1;
  final _justificacionController = TextEditingController();
  bool _enviando = false;

  Future<void> _enviarRequerimiento() async {
    if (_justificacionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La justificación técnica debe tener al menos 10 caracteres")),
      );
      return;
    }

    setState(() => _enviando = true);

    final payload = {
      'codMaquinaria': _codMaquinaria,
      'prioridad': _prioridad,
      'justificacionTecnica': _justificacionController.text.trim(),
      'items': [
        {'codParte': widget.repuestoInicial.codParte, 'cantidad': _cantidad}
      ]
    };

    try {
      final res = await _apiService.registrarSolicitud("carlos.mendoza@masterdrilling.com", payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.data['mensaje'] ?? "Solicitud enviada"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      await _dbHelper.guardarBorradorOffline({
        'codMaquinaria': _codMaquinaria,
        'prioridad': _prioridad,
        'justificacionTecnica': _justificacionController.text.trim(),
        'payloadJson': jsonEncode(payload),
        'sincronizado': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sin conexión: Guardado en borrador local (se sincronizará automáticamente)"),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emitir Solicitud")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.repuestoInicial.nombreRepuesto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Código: ${widget.repuestoInicial.codParte}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _codMaquinaria,
            decoration: const InputDecoration(labelText: "Maquinaria Afectada"),
            items: const [
              DropdownMenuItem(value: "MD-RB-01", child: Text("Raise Borer Rhino 1008 (MD-RB-01)")),
              DropdownMenuItem(value: "MD-RB-02", child: Text("Master Drilling RD IV (MD-RB-02)")),
              DropdownMenuItem(value: "MD-RB-03", child: Text("Perforadora Rhino 2002 (MD-RB-03)")),
            ],
            onChanged: (v) => setState(() => _codMaquinaria = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _prioridad,
                  decoration: const InputDecoration(labelText: "Prioridad"),
                  items: const [
                    DropdownMenuItem(value: "BAJA", child: Text("BAJA")),
                    DropdownMenuItem(value: "MEDIA", child: Text("MEDIA")),
                    DropdownMenuItem(value: "ALTA", child: Text("ALTA")),
                  ],
                  onChanged: (v) => setState(() => _prioridad = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: "1",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Cantidad"),
                  onChanged: (v) => _cantidad = int.tryParse(v) ?? 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _justificacionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Justificación técnica del cambio (mínimo 10 caracteres)",
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _enviando ? null : _enviarRequerimiento,
            child: _enviando
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text("ENVIAR SOLICITUD FORMAL"),
          ),
        ],
      ),
    );
  }
}
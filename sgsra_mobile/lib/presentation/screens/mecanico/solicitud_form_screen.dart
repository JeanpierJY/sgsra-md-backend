import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../data/models/repuesto_model.dart';
import '../../../data/datasources/database_helper.dart';
import '../../../data/services/api_service.dart';

class SolicitudFormScreen extends StatefulWidget {
  final RepuestoModel repuesto;
  const SolicitudFormScreen({super.key, required this.repuesto});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maquinaController = TextEditingController();
  final _justificacionController = TextEditingController();
  String _prioridad = 'MEDIA';
  int _cantidad = 1;
  final ApiService _apiService = ApiService();

  Future<void> _enviarRequerimiento() async {
    if (!_formKey.currentState!.validate()) return;

    final List<Map<String, dynamic>> itemsJson = [
      {'codParte': widget.repuesto.codParte, 'cantidad': _cantidad}
    ];

    final payload = {
      'codMaquinaria': _maquinaController.text.trim().toUpperCase(),
      'prioridad': _prioridad,
      'justificacionTecnica': _justificacionController.text.trim(),
      'items': itemsJson
    };

    try {
      // Intenta enviar directamente vía API REST (RF17)
      await _apiService.registrarSolicitud("carlos.mendoza@masterdrilling.com", payload);
      _mostrarSnack("✓ Solicitud enviada formalmente en tiempo real a la central.", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      // Fallback automático hacia la base local cifrada ante pérdidas de red en mina (RF18)
      await DatabaseHelper.instance.guardarBorradorOffline({
        'cod_maquinaria': _maquinaController.text.trim().toUpperCase(),
        'prioridad': _prioridad,
        'justificacion': _justificacionController.text.trim(),
        'repuestos_json': jsonEncode(itemsJson),
        'fecha_creacion': DateTime.now().toIso8601String()
      });
      _mostrarSnack("📡 Socavón sin red. Requerimiento guardado de forma segura en la cola local.", Colors.amber);
      Navigator.pop(context);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Solicitud (RF13-RF17)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Componente: ${widget.repuesto.nombreRepuesto}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Código Parte: ${widget.repuesto.codParte}", style: const TextStyle(color: Color(0xFF29B6F6))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text("Cantidad Requerida (RF14):", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => setState(() { if(_cantidad > 1) _cantidad--; })),
                      Text("$_cantidad", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => _cantidad++)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maquinaController,
                decoration: const InputDecoration(labelText: "Código de Perforadora Afectada (RF15)"),
                validator: (v) => (v == null || v.isEmpty) ? 'La vinculación de flota es obligatoria' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(labelText: "Urgencia del Pedido"),
                items: ['BAJA', 'MEDIA', 'ALTA'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _prioridad = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _justificacionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Explicación Técnica de la Avería (RF16)"),
                validator: (v) => (v == null || v.trim().length < 10) ? 'Debe ingresar al menos 10 caracteres explícitos' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _enviarRequerimiento, child: const Text("TRANSMITIR ORDEN")),
            ],
          ),
        ),
      ),
    );
  }
}

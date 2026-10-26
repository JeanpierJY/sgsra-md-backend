import 'package:flutter/material.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/repuesto_model.dart';
import 'dart:convert';

class SolicitudFormScreen extends StatefulWidget {
  final RepuestoModel repuestoSeleccionado;

  const SolicitudFormScreen({super.key, required this.repuestoSeleccionado});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoMaquinaController = TextEditingController();
  final _justificacionController = TextEditingController();
  
  String _prioridad = 'MEDIA'; // Valor por defecto (RF14)
  int _cantidad = 1;

  // Lista simulada de maquinaria pesada Raise Boring de Master Drilling
  final List<String> _maquinariasHomologadas = ['MD-RB-01', 'MD-RB-02', 'MD-RB-03', 'MD-TH-01'];

  Future<void> _procesarEnvio() async {
    if (_formKey.currentState!.validate()) {
      // Estructuración del payload de repuestos agrupados en formato JSON (RF13)
      final List<Map<String, dynamic>> carritoItems = [
        {
          'codParte': widget.repuestoSeleccionado.codParte,
          'nombreRepuesto': widget.repuestoSeleccionado.nombreRepuesto,
          'cantidad': _cantidad,
        }
      ];

      final borradorData = {
        'cod_maquina': _codigoMaquinaController.text,
        'prioridad': _prioridad,
        'justificacion': _justificacionController.text,
        'repuestos_json': jsonEncode(carritoItems),
        'fecha_creacion': DateTime.now().toIso8601String(),
      };

      try {
        // RF18: Almacenamiento seguro automático en la cola SQLite encriptada en AES-256
        await DatabaseHelper.instance.insertarBorrador(borradorData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("✓ Solicitud encolada localmente con éxito (Modo Híbrido/Offline)."),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context); // Regresa de forma limpia al catálogo
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Error crítico al procesar la persistencia criptográfica local."),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    _codigoMaquinaController.dispose();
    _justificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario de Requerimiento"),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bloque Informativo del Repuesto Seleccionado
              Card(
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.repuestoSeleccionado.nombreRepuesto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Código de Parte: ${widget.repuestoSeleccionado.codParte}", style: const TextStyle(color: Color(0xFF29B6F6))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Selector de Cantidad (RF14)
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text("Cantidad Requerida:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 32, color: Color(0xFFFFB300)),
                        onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                      ),
                      Text("$_cantidad", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFFFFB300)),
                        onPressed: () => setState(() => _cantidad++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo Obligatorio: Vinculación de Maquinaria (RF15)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Vincular a Maquinaria Afectada (RF15)", border: OutlineInputBorder()),
                items: _maquinariasHomologadas.map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                validator: (value) => value == null ? 'Debe seleccionar una máquina de la flota' : null,
                onChanged: (value) => _codigoMaquinaController.text = value ?? '',
              ),
              const SizedBox(height: 16),

              // Selector de Nivel de Urgencia/Prioridad (RF14)
              DropdownButtonFormField<String>(
                value: _prioridad,
                decoration: const InputDecoration(labelText: "Prioridad del Requerimiento", border: OutlineInputBorder()),
                items: ['BAJA', 'MEDIA', 'CRÍTICA'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _prioridad = value ?? 'MEDIA'),
              ),
              const SizedBox(height: 16),

              // Campo Obligatorio: Justificación Técnica con validación estricta de longitud (RF16)
              TextFormField(
                controller: _justificacionController,
                decoration: const InputDecoration(
                  labelText: "Justificación Técnica de la Falla (RF16)",
                  border: OutlineInputBorder(),
                  hintText: "Detalle el motivo del cambio del componente...",
                ),
                maxLines: 3,
                maxLength: 150,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'La justificación es obligatoria';
                  if (value.trim().length < 10) return 'Debe detallar al menos 10 caracteres técnicos';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón de Envío de Alto Contraste adaptado para Guantes (RNF02)
              ElevatedButton(
                onPressed: _procesarEnvio, // Dispara RF17 o RF18 según disponibilidad de señal
                child: const Text("TRANSMITIR REQUERIMIENTO"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

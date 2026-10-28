import 'package:flutter/material.dart';
import '../../../data/models/repuesto_model.dart';
import '../../../data/services/api_service.dart';

class SolicitudFormScreen extends StatefulWidget {
  final RepuestoModel? repuestoInicial;
  const SolicitudFormScreen({super.key, this.repuestoInicial});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _justificacionController = TextEditingController();
  final _cantidadController = TextEditingController(text: "1");
  String _maquinariaSeleccionada = "MD-RB-01";
  String _prioridadSeleccionada = "ALTA";
  final ApiService _apiService = ApiService();
  bool _enviando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solicitud de Repuesto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Repuesto: ${widget.repuestoInicial?.nombreRepuesto ?? 'Componente de Perforadora'}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _maquinariaSeleccionada,
                decoration: const InputDecoration(labelText: "Maquinaria Destino"),
                items: const [
                  DropdownMenuItem(value: "MD-RB-01", child: Text("Raise Borer Rhino 1008")),
                  DropdownMenuItem(value: "MD-RB-02", child: Text("Componentes RD IV")),
                  DropdownMenuItem(value: "MD-RB-03", child: Text("Perforadora Rhino 2002")),
                ],
                onChanged: (val) => setState(() => _maquinariaSeleccionada = val!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nivel de Prioridad:", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _prioridadSeleccionada,
                    items: const [
                      DropdownMenuItem(value: "BAJA", child: Text("Baja")),
                      DropdownMenuItem(value: "MEDIA", child: Text("Media")),
                      DropdownMenuItem(value: "ALTA", child: Text("Alta")),
                    ],
                    onChanged: (val) => setState(() => _prioridadSeleccionada = val!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cantidad Solicitada"),
                validator: (val) => (val == null || val.isEmpty || int.tryParse(val) == null || int.parse(val) <= 0)
                    ? "Ingrese una cantidad valida"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _justificacionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Justificacion Tecnica (Minimo 10 caracteres)"),
                validator: (val) => (val == null || val.trim().length < 10)
                    ? "La justificacion debe tener al menos 10 caracteres"
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enviando ? null : _enviarSolicitud,
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Enviar Solicitud"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    final payload = {
      'codMaquinaria': _maquinariaSeleccionada,
      'prioridad': _prioridadSeleccionada,
      'justificacionTecnica': _justificacionController.text.trim(),
      'items': [
        {
          'codParte': widget.repuestoInicial?.codParte ?? "P-REX-024",
          'cantidad': int.parse(_cantidadController.text),
        }
      ]
    };

    try {
      final res = await _apiService.registrarSolicitud("carlos.mendoza@masterdrilling.com", payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Solicitud enviada con exito: ${res.data['dato']}")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al conectar con servidor")),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}
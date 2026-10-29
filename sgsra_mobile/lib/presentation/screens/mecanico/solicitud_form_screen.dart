import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class SolicitudFormScreen extends StatefulWidget {
  final Map<String, dynamic>? repuestoPreseleccionado;

  const SolicitudFormScreen({super.key, this.repuestoPreseleccionado});

  @override
  State<SolicitudFormScreen> createState() => _SolicitudFormScreenState();
}

class _SolicitudFormScreenState extends State<SolicitudFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _justificacionCtrl = TextEditingController();
  final TextEditingController _cantidadCtrl = TextEditingController(text: "1");

  String _maquinaSeleccionada = "MD-RB-01";
  String _prioridad = "ALTA";
  String? _repuestoSeleccionado;
  bool _enviando = false;

  final List<Map<String, String>> _maquinarias = [
    {"codigo": "MD-RB-01", "nombre": "Raise Borer Rhino 1008 (MD-RB-01)"},
    {"codigo": "MD-RB-02", "nombre": "Jumbo Perforacion Frontal (MD-RB-02)"},
  ];

  final List<Map<String, String>> _repuestosDisponibles = [
    {"codigo": "P-REX-024", "nombre": "Bomba de pistones axiales Rexroth A4VSO 125 DR"},
    {"codigo": "H-ESP-118", "nombre": "Manguera espiral 4SP 1 pulgada"},
    {"codigo": "F-HYD-882", "nombre": "Filtro hidraulico 10 micras"},
    {"codigo": "K-SEL-340", "nombre": "Kit sellos Viton alta temperatura"},
    {"codigo": "V-ALL-111", "nombre": "Valvula de control direccional proporcional"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.repuestoPreseleccionado != null) {
      _repuestoSeleccionado = widget.repuestoPreseleccionado!['codParte'];
    } else {
      _repuestoSeleccionado = _repuestosDisponibles.first["codigo"];
    }
  }

  Future<void> _transmitirSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (_justificacionCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La justificacion debe tener minimo 10 caracteres")),
      );
      return;
    }

    setState(() => _enviando = true);
    final user = await _apiService.obtenerDatosUsuario();
    final correoMecanico = user['email'] ?? 'carlos.mendoza@masterdrilling.com';

    final payload = {
      'codMaquinaria': _maquinaSeleccionada,
      'prioridad': _prioridad,
      'justificacionTecnica': _justificacionCtrl.text.trim(),
      'items': [
        {
          'codParte': _repuestoSeleccionado,
          'cantidad': int.parse(_cantidadCtrl.text.trim()),
        }
      ]
    };

    try {
      await _apiService.registrarSolicitud(correoMecanico, payload);
      if (!mounted) return;
      setState(() => _enviando = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Solicitud Registrada"),
            ],
          ),
          content: const Text(
            "El requerimiento fue registrado en PostgreSQL con estado PENDIENTE.\n"
            "El Administrador ya puede revisarlo en su bandeja de aprobaciones.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Aceptar"),
            )
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al registrar solicitud en el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Emitir Solicitud Formal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _repuestoSeleccionado,
                decoration: const InputDecoration(
                  labelText: "Componente / Repuesto",
                  prefixIcon: Icon(Icons.settings),
                  border: OutlineInputBorder(),
                ),
                items: _repuestosDisponibles.map((r) {
                  return DropdownMenuItem<String>(
                    value: r["codigo"],
                    child: Text("${r["codigo"]} · ${r["nombre"]}", overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _repuestoSeleccionado = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _maquinaSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Maquinaria Afectada",
                  prefixIcon: Icon(Icons.precision_manufacturing),
                  border: OutlineInputBorder(),
                ),
                items: _maquinarias.map((m) {
                  return DropdownMenuItem<String>(
                    value: m["codigo"],
                    child: Text(m["nombre"]!),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _maquinaSeleccionada = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _prioridad,
                      decoration: const InputDecoration(
                        labelText: "Prioridad",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "ALTA", child: Text("ALTA")),
                        DropdownMenuItem(value: "MEDIA", child: Text("MEDIA")),
                        DropdownMenuItem(value: "BAJA", child: Text("BAJA")),
                      ],
                      onChanged: (v) => setState(() => _prioridad = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Cantidad",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return "Minimo 1";
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _justificacionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Justificacion tecnica del cambio (minimo 10 caracteres)",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 10) {
                    return "Escriba una justificacion de al menos 10 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _enviando ? null : _transmitirSolicitud,
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "ENVIAR SOLICITUD FORMAL",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
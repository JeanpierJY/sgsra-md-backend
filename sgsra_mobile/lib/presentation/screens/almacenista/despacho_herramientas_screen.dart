import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/api_service.dart';
import 'escaner_qr_screen.dart';

class DespachoHerramientasScreen extends StatefulWidget {
  final String? codigoInicial;
  const DespachoHerramientasScreen({super.key, this.codigoInicial});

  @override
  State<DespachoHerramientasScreen> createState() => _DespachoHerramientasScreenState();
}

class _DespachoHerramientasScreenState extends State<DespachoHerramientasScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniCtrl = TextEditingController(text: "75859812");
  
  String? _herramientaSeleccionada;
  bool _enviando = false;

  final List<Map<String, String>> _herramientasDisponibles = [
    {"codigo": "HER-TOR-004", "nombre": "Torquimetro Industrial 3/4 Proto"},
    {"codigo": "HER-PIST-003", "nombre": "Pistola de Impacto Neumatica"},
    {"codigo": "HER-BOM-008", "nombre": "Bomba Hidraulica Manual Enerpac"},
    {"codigo": "HER-MAN-022", "nombre": "Manometro de Alta Presion"},
    {"codigo": "HER-LLAV-015", "nombre": "Juego de Llaves Corona Pulgadas"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.codigoInicial != null) {
      _herramientaSeleccionada = widget.codigoInicial;
    } else {
      _herramientaSeleccionada = _herramientasDisponibles.first["codigo"];
    }
  }

  Future<void> _escanearQR() async {
    final codigoLeido = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const EscanerQrScreen()),
    );
    if (codigoLeido != null && mounted) {
      setState(() {
        _herramientaSeleccionada = codigoLeido;
      });
    }
  }

  Future<void> _registrarPrestamo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_herramientaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione una herramienta del catalogo")),
      );
      return;
    }

    setState(() => _enviando = true);
    final user = await _apiService.obtenerDatosUsuario();
    final correoAlmacen = user['email'] ?? 'marcos.ramos@masterdrilling.com';

    final payload = {
      'dniMecanico': _dniCtrl.text.trim(),
      'codHerramienta': _herramientaSeleccionada,
    };

    try {
      final res = await _apiService.registrarPrestamo(correoAlmacen, payload);
      if (!mounted) return;
      setState(() => _enviando = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Prestamo Concedido"),
            ],
          ),
          content: Text(
            "Se ha generado el comprobante de salida para el mecanico DNI ${_dniCtrl.text.trim()}.\n"
            "Herramienta: $_herramientaSeleccionada\n"
            "Estado en base de datos: PRESTADA.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Finalizar"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: El mecanico no existe, registra moras previas o la herramienta no esta disponible."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Despacho de Herramientas"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DATOS DE CONTROL DE PANOL",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dniCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: const InputDecoration(
                  labelText: "DNI del Mecanico Receptor (8 digitos exactos)",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().length != 8) {
                    return "El DNI debe tener exactamente 8 digitos numericos";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _herramientaSeleccionada,
                      decoration: const InputDecoration(
                        labelText: "Codigo de Herramienta",
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                      items: _herramientasDisponibles.map((h) {
                        return DropdownMenuItem<String>(
                          value: h["codigo"],
                          child: Text(
                            "${h["codigo"]} - ${h["nombre"]}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _herramientaSeleccionada = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
                      onPressed: _escanearQR,
                      tooltip: "Escanear QR con camara",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _enviando ? null : _registrarPrestamo,
                child: _enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "REGISTRAR PRESTAMO FORMAL",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/api_service.dart';
import 'escaner_qr_screen.dart';

class DashboardPanolScreen extends StatefulWidget {
  const DashboardPanolScreen({super.key});

  @override
  State<DashboardPanolScreen> createState() => _DashboardPanolScreenState();
}

class _DashboardPanolScreenState extends State<DashboardPanolScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _metricas = {
    'totalDisponibles': 5,
    'totalPrestadas': 0,
    'totalEnMora': 0,
    'totalMantenimiento': 0,
    'totalExtraviadas': 0,
  };
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMetricas();
  }

  Future<void> _cargarMetricas() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.obtenerMetricasDashboard();
      if (mounted) {
        setState(() {
          _metricas = res.data;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _modalRegistrarPrestamo() {
    final formKey = GlobalKey<FormState>();
    final dniCtrl = TextEditingController(text: "75859812");
    String codHerramienta = "HER-TOR-004";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setModalState) => AlertDialog(
          title: const Text("Registrar Prestamo de Herramienta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dniCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: const InputDecoration(
                    labelText: "DNI del Mecanico (8 digitos)",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.length != 8 ? "DNI invalido (8 digitos)" : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: codHerramienta,
                  decoration: const InputDecoration(
                    labelText: "Herramienta a Despachar",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "HER-TOR-004", child: Text("HER-TOR-004 (Torquimetro 3/4)")),
                    DropdownMenuItem(value: "HER-PIST-003", child: Text("HER-PIST-003 (Pistola Impacto)")),
                    DropdownMenuItem(value: "HER-BOM-008", child: Text("HER-BOM-008 (Bomba Hidraulica)")),
                    DropdownMenuItem(value: "HER-MAN-022", child: Text("HER-MAN-022 (Manometro Presion)")),
                  ],
                  onChanged: (v) => setModalState(() => codHerramienta = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  setState(() => _cargando = true);
                  try {
                    await _apiService.registrarPrestamo(
                      "marcos.ramos@masterdrilling.com",
                      {
                        'dniMecanico': dniCtrl.text.trim(),
                        'codHerramienta': codHerramienta,
                      },
                    );
                    _cargarMetricas();
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Prestamo registrado exitosamente en la bitacora")),
                    );
                  } catch (_) {
                    if (mounted) setState(() => _cargando = false);
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Error: Mecanico no apto o herramienta no disponible")),
                    );
                  }
                }
              },
              child: const Text("Confirmar Despacho"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control de Herramientas de Panol"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarMetricas),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _cardMetrica("Disponibles", "${_metricas['totalDisponibles'] ?? 0}", Colors.green),
                    const SizedBox(width: 8),
                    _cardMetrica("Prestadas", "${_metricas['totalPrestadas'] ?? 0}", Colors.orange),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _cardMetrica("En Mora", "${_metricas['totalEnMora'] ?? 0}", Colors.red),
                    const SizedBox(width: 8),
                    _cardMetrica("Mantenimiento", "${_metricas['totalMantenimiento'] ?? 0}", Colors.blue),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), minimumSize: const Size(double.infinity, 48)),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text("ESCANEAR HERRAMIENTA / FOTOCHECK (QR)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EscanerQrScreen()));
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text("REGISTRAR PRESTAMO MANUAL", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _modalRegistrarPrestamo,
                ),
              ],
            ),
    );
  }

  Widget _cardMetrica(String titulo, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
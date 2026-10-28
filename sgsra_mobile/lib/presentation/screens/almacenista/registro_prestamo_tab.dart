import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import 'escaner_qr_screen.dart';

class RegistroPrestamoTab extends StatefulWidget {
  const RegistroPrestamoTab({super.key});

  @override
  State<RegistroPrestamoTab> createState() => _RegistroPrestamoTabState();
}

class _RegistroPrestamoTabState extends State<RegistroPrestamoTab> {
  final ApiService _apiService = ApiService();
  final _dniMecanicoController = TextEditingController(text: "75859812");
  final _codigoHerramientaController = TextEditingController();
  bool _guardando = false;

  Future<void> _escanearQR() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const EscanerQRScreen()),
    );
    if (codigo != null && codigo.isNotEmpty) {
      setState(() => _codigoHerramientaController.text = codigo);
    }
  }

  Future<void> _despacharPrestamo() async {
    if (_codigoHerramientaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escanee o ingrese una herramienta")),
      );
      return;
    }

    setState(() => _guardando = true);
    final payload = {
      'dniMecanico': _dniMecanicoController.text.trim(),
      'codigosHerramienta': [_codigoHerramientaController.text.trim()],
      'firmaMecanico': 'FIRMA_DIGITAL_TALLER_SUR',
    };

    try {
      final res = await _apiService.registrarPrestamo("marcos.ramos@masterdrilling.com", payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.data['mensaje'] ?? "Préstamo registrado"), backgroundColor: Colors.green),
        );
        _codigoHerramientaController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Cupo excedido o herramienta no disponible"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Despacho de Herramientas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("DATOS DE CONTROL DE PAÑOL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _dniMecanicoController,
              decoration: const InputDecoration(labelText: "DNI del Mecánico Receptor (8 dígitos)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codigoHerramientaController,
                    decoration: const InputDecoration(labelText: "Código de Herramienta"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFB300)),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  onPressed: _escanearQR,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando ? null : _despacharPrestamo,
              child: _guardando
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("REGISTRAR PRÉSTAMO FORMAL"),
            ),
          ],
        ),
      ),
    );
  }
}
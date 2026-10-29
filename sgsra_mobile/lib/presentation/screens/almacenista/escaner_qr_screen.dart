import 'package:flutter/material.dart';

class EscanerQrScreen extends StatefulWidget {
  const EscanerQrScreen({super.key});

  @override
  State<EscanerQrScreen> createState() => _EscanerQrScreenState();
}

class _EscanerQrScreenState extends State<EscanerQrScreen> {
  void _simularLectura(String codigo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.blue),
            const SizedBox(width: 8),
            Text("QR: $codigo"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Activo: $codigo", style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text("Estado en Base de Datos: DISPONIBLE"),
            const Text("Ubicacion: Estante E-03 · Panol Lurin"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, codigo);
            },
            child: const Text("Proceder con el Despacho"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lector Optico de Codigos QR")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Enfoque el codigo QR de la herramienta o seleccione un activo para pruebas en emulador.",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Sensor Activo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Simulador de Lectura de Activos Reales:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text("HER-TOR-004"),
                      onPressed: () => _simularLectura("HER-TOR-004"),
                    ),
                    ActionChip(
                      label: const Text("HER-BOM-008"),
                      onPressed: () => _simularLectura("HER-BOM-008"),
                    ),
                    ActionChip(
                      label: const Text("HER-MAN-022"),
                      onPressed: () => _simularLectura("HER-MAN-022"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
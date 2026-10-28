import 'package:flutter/material.dart';

class HerramientasMecanicoTab extends StatelessWidget {
  const HerramientasMecanicoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Panel descriptivo del Pañol de Herramientas Especiales 
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Control de Almacén de\nHerramientas Especiales\n(RF33)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Registro, custodia, trazabilidad por código QR e historial de préstamos a mecánicos",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                  icon: const Icon(Icons.qr_code_scanner, size: 16),
                  label: const Text("Escanear Rótulo QR (RF34)"),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Estado por defecto desde cero para la nómina de custodia del operario
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Icon(Icons.handyman_outlined, size: 44, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  "Sin herramientas en custodia.\nNo registras préstamos activos a tu nombre.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

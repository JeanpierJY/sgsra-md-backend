import 'package:flutter/material.dart';

class MetricasAdminTab extends StatelessWidget {
  const MetricasAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Estadísticas de Demanda")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Consumo por componente homologado", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _barraMetrica("Bomba Rexroth P-REX-024", 18, 0.45),
          _barraMetrica("Manguera H-ESP-118", 34, 0.85),
          _barraMetrica("Filtro F-HYD-882", 42, 1.0),
          _barraMetrica("Kit sellos Viton K-SEL-340", 22, 0.55),
          _barraMetrica("Válvula V-ALL-111", 12, 0.30),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                "Total piezas solicitadas en el periodo: 128 unidades",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraMetrica(String nombre, int cantidad, double factor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$cantidad uds.", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: factor,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
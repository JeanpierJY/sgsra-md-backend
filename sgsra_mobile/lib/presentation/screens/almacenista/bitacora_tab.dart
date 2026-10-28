import 'package:flutter/material.dart';

class BitacoraTab extends StatelessWidget {
  const BitacoraTab({super.key});

  @override
  Widget build(BuildContext context) {
    int totalTrazasAuditadas = 0; 

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bitácora Inalterable\nde Auditoría (RF49)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Registro secuencial criptográficamente firmado para trazabilidad operativa y cumplimiento", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text("Exportar CSV (RF30)"),
                      onPressed: totalTrazasAuditadas == 0 ? null : () {}, // Bloqueado si no hay registros cargados
                    )
                  ],
                ),
                Positioned(
                  right: 0, top: 0,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade100,
                    child: const Text("SHA-\n256\nReady", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$totalTrazasAuditadas eventos auditados", style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Text("Algoritmo: HMAC-SHA256", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            "Cargando bitácora criptográfica...\nNo se registran trazas en el periodo seleccionado.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        )
      ],
    );
  }
}


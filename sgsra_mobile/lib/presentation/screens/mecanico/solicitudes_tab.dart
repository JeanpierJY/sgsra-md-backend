import 'package:flutter/material.dart';

class SolicitudesTab extends StatelessWidget {
  const SolicitudesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Encabezado Informativo de Bitácora
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF0D47A1), size: 24),
                    SizedBox(width: 12),
                    Text(
                      "Bitácora de Mis Solicitudes",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Historial de requerimientos de piezas y resoluciones administrativas",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300)),
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.black87),
                  label: const Text("Actualizar Estado", style: TextStyle(color: Colors.black87, fontSize: 13)),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Chips selectores de estado
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(selected: true, label: const Text("Todas"), onSelected: (v) {}),
              const SizedBox(width: 8),
              FilterChip(selected: false, label: const Text("Pendiente"), onSelected: (v) {}),
              const SizedBox(width: 8),
              FilterChip(selected: false, label: const Text("Aprobada"), onSelected: (v) {}),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Estado vacío controlado inicial de solicitudes de repuesto
        const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 44, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                "No has registrado solicitudes en este turno minero.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        )
      ],
    );
  }
}

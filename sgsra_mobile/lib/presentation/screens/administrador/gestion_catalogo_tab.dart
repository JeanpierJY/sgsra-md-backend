import 'package:flutter/material.dart';

class GestionCatalogoTab extends StatelessWidget {
  const GestionCatalogoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Gestión del Catálogo\nMaestro de Repuestos (RF32)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Alta, modificación de stock técnico y homologación de componentes para maquinaria", style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Nuevo Repuesto Homologado"),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Buscar por código de parte, nombre de repuesto...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        // Estado Vacío: Se inicializa en cero antes de cargar los datos dinámicos de PostgreSQL
        const Expanded(
          child: Center(
            child: Text("Sincronizando componentes con el servidor de Master Drilling...", style: TextStyle(color: Colors.grey)),
          ),
        )
      ],
    );
  }
}

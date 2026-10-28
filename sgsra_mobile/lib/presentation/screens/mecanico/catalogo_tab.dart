import 'package:flutter/material.dart';

class CatalogoTab extends StatelessWidget {
  const CatalogoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Buscador y filtrado técnico (Imagen 1)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar repuesto por nombre, código...",
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(side: BorderSide(color: Colors.grey.shade200)),
                icon: const Icon(Icons.tune, color: Color(0xFF475569)),
                onPressed: () {},
              )
            ],
          ),
        ),
        // Chips Horizontales de Filtrado de Maquinaria
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(label: const Text("Todas"), selected: true, onSelected: (v) {}),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text("Brocas y Cortadores"), selected: false, onSelected: (v) {}),
              const SizedBox(width: 8),
              ChoiceChip(label: const Text("Sistemas Hidráulicos"), selected: false, onSelected: (v) {}),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Mostrando 0 componente(s) homologado(s)", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text("Ver Carrito (0 ítems)", style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        // Estado vacío controlado listo para el despliegue dinámico desde la BD
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  "Catálogo vacío.\nEsperando asignación de stock técnico del servidor.",
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

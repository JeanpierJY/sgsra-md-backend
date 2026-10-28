import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_state.dart';

class PrestamosTab extends StatelessWidget {
  const PrestamosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Buscar por mecánico o código de herramienta...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<InventarioBloc, InventarioState>(
            builder: (context, state) {
              if (state is InventarioLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
              }

              // Estado Inicial Vacío: Garantiza el arranque limpio de la aplicación
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        "No se registran préstamos activos ni herramientas en mora retenidas en labor.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

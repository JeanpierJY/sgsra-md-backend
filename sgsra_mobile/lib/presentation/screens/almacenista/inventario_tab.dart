import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_state.dart';

class InventarioTab extends StatelessWidget {
  const InventarioTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventarioBloc, InventarioState>(
      builder: (context, state) {
        if (state is InventarioLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
        }

        if (state is InventarioInitial) {
          return const Center(
            child: Text("Sincronizando inventario inicial con el taller...", style: TextStyle(color: Colors.grey)),
          );
        }

        // Estado Vacío por Defecto si no hay activos registrados aún en la base de datos
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "No se registran herramientas en el catálogo móvil.\nUse la consola central para dar de alta activos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


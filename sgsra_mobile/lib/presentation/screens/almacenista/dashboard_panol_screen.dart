import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_event.dart';
import '../../bloc/inventario/inventario_state.dart';

class DashboardPanolScreen extends StatefulWidget {
  const DashboardPanolScreen({super.key});

  @override
  State<DashboardPanolScreen> createState() => _DashboardPanolScreenState();
}

class _DashboardPanolScreenState extends State<DashboardPanolScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventarioBloc>().add(FetchDashboardRequested());
  }

  Widget _tarjetaMetrica(String titulo, int cantidad, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              "$cantidad",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tablero de Pañol")),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<InventarioBloc>().add(FetchDashboardRequested());
        },
        child: BlocBuilder<InventarioBloc, InventarioState>(
          builder: (context, state) {
            if (state is InventarioLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
            } else if (state is DashboardLoaded) {
              final m = state.metricas;
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Row(
                    children: [
                      Expanded(child: _tarjetaMetrica("Disponibles", m.totalDisponibles, Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _tarjetaMetrica("Prestadas", m.totalPrestadas, const Color(0xFFFFB300))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _tarjetaMetrica("En Mora", m.totalEnMora, Colors.redAccent)),
                      const SizedBox(width: 8),
                      Expanded(child: _tarjetaMetrica("Mantenimiento", m.totalEnMantenimiento, Colors.orangeAccent)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _tarjetaMetrica("Extraviadas", m.totalExtraviadas, Colors.grey),
                ],
              );
            } else if (state is InventarioFailure) {
              return Center(child: Text(state.error));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
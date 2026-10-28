import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/inventario/inventario_bloc.dart';
import '../../bloc/inventario/inventario_event.dart';
import '../../bloc/inventario/inventario_state.dart';
import 'escaner_qr_screen.dart';

class DashboardPanolScreen extends StatefulWidget {
  const DashboardPanolScreen({super.key});

  @override
  State<DashboardPanolScreen> createState() => _DashboardPanolScreenState();
}

class _DashboardPanolScreenState extends State<DashboardPanolScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InventarioBloc>().add(CargarDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Pañol - Herramientas")),
      body: BlocBuilder<InventarioBloc, InventarioState>(
        builder: (context, state) {
          if (state is InventarioLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            final metricas = state.metricas;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<InventarioBloc>().add(CargarDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _tarjetaMetrica("Disponibles", metricas['totalDisponibles']?.toString() ?? "0", Colors.green),
                  _tarjetaMetrica("Prestadas", metricas['totalPrestadas']?.toString() ?? "0", Colors.orange),
                  _tarjetaMetrica("En Mora", metricas['totalEnMora']?.toString() ?? "0", Colors.red),
                  _tarjetaMetrica("En Mantenimiento", metricas['totalEnMantenimiento']?.toString() ?? "0", Colors.blueGrey),
                  _tarjetaMetrica("Extraviadas", metricas['totalExtraviadas']?.toString() ?? "0", Colors.purple),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Escanear Código QR"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EscanerQRScreen()),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<InventarioBloc>().add(CargarDashboardRequested()),
              child: const Text("Reintentar Carga"),
            ),
          );
        },
      ),
    );
  }

  Widget _tarjetaMetrica(String titulo, String valor, Color color) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 10),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
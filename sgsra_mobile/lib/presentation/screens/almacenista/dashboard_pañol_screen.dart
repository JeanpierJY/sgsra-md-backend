import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
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
    context.read<InventarioBloc>().add(FetchMetricasDashboardRequested());
  }

  Widget _construirTarjetaMetrica(String titulo, int valor, Color color) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 14, color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("$valor", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Pañol de Herramientas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFEF5350)),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          )
        ],
      ),
      body: BlocBuilder<InventarioBloc, InventarioState>(
        builder: (context, state) {
          if (state is InventarioLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
          }
          if (state is DashboardMetricasLoaded) {
            final metricas = state.metricas;
            return Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _construirTarjetaMetrica("Disponibles (RF33)", metricas.totalDisponibles, Colors.green),
                      _construirTarjetaMetrica("Prestadas", metricas.totalPrestadas, const Color(0xFF29B6F6)),
                      _construirTarjetaMetrica("En Mora (Alerta)", metricas.totalEnMora, const Color(0xFFEF5350)),
                      _construirTarjetaMetrica("En Mantenimiento", metricas.totalEnMantenimiento, Colors.amber),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                    label: const Text("ACTIVAR CÁMARA ESCÁNER (RF34)"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EscanerQrScreen()));
                    },
                  ),
                )
              ],
            );
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<InventarioBloc>().add(FetchMetricasDashboardRequested()),
              child: const Text("REINTENTAR CARGA"),
            ),
          );
        },
      ),
    );
  }
}

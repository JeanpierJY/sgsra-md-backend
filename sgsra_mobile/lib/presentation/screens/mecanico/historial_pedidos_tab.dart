import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class HistorialPedidosTab extends StatefulWidget {
  const HistorialPedidosTab({super.key});

  @override
  State<HistorialPedidosTab> createState() => _HistorialPedidosTabState();
}

class _HistorialPedidosTabState extends State<HistorialPedidosTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _historial = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.listarHistorialMecanico("carlos.mendoza@masterdrilling.com");
      setState(() {
        _historial = res.data['content'] ?? [];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Solicitudes Enviadas")),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)))
          : _historial.isEmpty
              ? const Center(child: Text("No has generado solicitudes todavía."))
              : RefreshIndicator(
                  onRefresh: _cargarHistorial,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _historial.length,
                    itemBuilder: (context, index) {
                      final item = _historial[index];
                      final estado = item['estado'] ?? 'PENDIENTE';
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(item['solicitudNum'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Máquina: ${item['codMaquinaria']}\nFecha: ${item['fechaEmision']}"),
                          trailing: Chip(
                            label: Text(estado, style: const TextStyle(fontSize: 11, color: Colors.black)),
                            backgroundColor: estado == 'APROBADA'
                                ? Colors.green
                                : estado == 'RECHAZADA'
                                    ? Colors.red
                                    : const Color(0xFFFFB300),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
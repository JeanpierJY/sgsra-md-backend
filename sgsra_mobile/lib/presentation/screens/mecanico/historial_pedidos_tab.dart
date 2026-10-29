import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class HistorialPedidosTab extends StatefulWidget {
  const HistorialPedidosTab({super.key});

  @override
  State<HistorialPedidosTab> createState() => _HistorialPedidosTabState();
}

class _HistorialPedidosTabState extends State<HistorialPedidosTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pedidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _cargando = true);
    final user = await _apiService.obtenerDatosUsuario();
    final correo = user['email'] ?? 'carlos.mendoza@masterdrilling.com';

    try {
      final res = await _apiService.listarHistorialMecanico(correo);
      if (mounted) {
        setState(() {
          _pedidos = res.data is List ? res.data : [];
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bitacora de Mis Solicitudes"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarHistorial),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text("No has generado solicitudes todavia", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarHistorial,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _pedidos.length,
                    itemBuilder: (context, idx) {
                      final p = _pedidos[idx];
                      final estado = (p['estado'] ?? 'PENDIENTE').toString();
                      Color bgBadge = const Color(0xFFFFF9C4);
                      Color textBadge = const Color(0xFFF57F17);

                      if (estado == 'APROBADA') {
                        bgBadge = const Color(0xFFE8F5E9);
                        textBadge = const Color(0xFF2E7D32);
                      } else if (estado == 'RECHAZADA') {
                        bgBadge = const Color(0xFFFFEBEE);
                        textBadge = const Color(0xFFC62828);
                      }

                      return Card(
                        child: ListTile(
                          title: Text(p['solicitudNum'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Equipo: ${p['codMaquinaria']}\nFecha: ${p['fechaEmision']} - Prioridad: ${p['prioridad']}"),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgBadge,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              estado,
                              style: TextStyle(color: textBadge, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import 'detalle_solicitud_screen.dart';

class BandejaSolicitudesTab extends StatefulWidget {
  const BandejaSolicitudesTab({super.key});

  @override
  State<BandejaSolicitudesTab> createState() => _BandejaSolicitudesTabState();
}

class _BandejaSolicitudesTabState extends State<BandejaSolicitudesTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _solicitudes = [];
  bool _cargando = true;
  String _filtroActivo = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarBandeja();
  }

  Future<void> _cargarBandeja() async {
    setState(() => _cargando = true);
    try {
      final res = await _apiService.listarBandejaAdministrador();
      if (mounted) {
        setState(() {
          _solicitudes = res.data is List ? res.data : [];
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<dynamic> get _solicitudesFiltradas {
    if (_filtroActivo == 'Todas') return _solicitudes;
    return _solicitudes.where((s) => (s['estado'] ?? '').toString().toUpperCase() == _filtroActivo.toUpperCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final int pendientes = _solicitudes.where((s) => s['estado'] == 'PENDIENTE').length;
    final int aprobadas = _solicitudes.where((s) => s['estado'] == 'APROBADA').length;
    final int rechazadas = _solicitudes.where((s) => s['estado'] == 'RECHAZADA').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Bandeja de Solicitudes"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarBandeja),
        ],
      ),
      body: Column(
        children: [
          // Banner Online Verde de Figma
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            color: const Color(0xFFE8F5E9),
            child: const Row(
              children: [
                Icon(Icons.wifi, color: Color(0xFF2E7D32), size: 16),
                SizedBox(width: 8),
                Text(
                  "Modo Online Activado · Leao Chura (Jefe de Taller)",
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Tarjetas de Métricas de Inicio (Figma P14)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _miniMetrica("Órdenes Pendientes", "$pendientes", Colors.orange),
                const SizedBox(width: 8),
                _miniMetrica("Aprobadas", "$aprobadas", Colors.green),
                const SizedBox(width: 8),
                _miniMetrica("Rechazadas", "$rechazadas", Colors.red),
              ],
            ),
          ),

          // Píldoras de Filtro (Figma P15)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['Todas', 'Pendiente', 'Aprobada', 'Rechazada'].map((f) {
                final bool sel = _filtroActivo == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: sel,
                    selectedColor: const Color(0xFF0D47A1),
                    labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _filtroActivo = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de Solicitudes
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
                : _solicitudesFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                            const SizedBox(height: 12),
                            const Text(
                              "Bandeja al día",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "No hay solicitudes en estado $_filtroActivo",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarBandeja,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _solicitudesFiltradas.length,
                          itemBuilder: (context, index) {
                            final s = _solicitudesFiltradas[index];
                            final estado = (s['estado'] ?? 'PENDIENTE').toString();
                            final prioridad = (s['prioridad'] ?? 'MEDIA').toString();

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
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          s['solicitudNum'] ?? '',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: bgBadge,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: textBadge.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            estado,
                                            style: TextStyle(color: textBadge, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${s['codMaquinaria']} · ${s['modeloMaquinaria'] ?? 'Flota Principal'}",
                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: prioridad == 'ALTA' ? Colors.red.shade50 : Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: prioridad == 'ALTA' ? Colors.red : Colors.blue),
                                          ),
                                          child: Text(
                                            "Prioridad $prioridad",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: prioridad == 'ALTA' ? Colors.red.shade900 : Colors.blue.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${s['fechaEmision']} ${s['horaEmision'] ?? ''}",
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DetalleSolicitudScreen(solicitudNum: s['solicitudNum']),
                                            ),
                                          );
                                          _cargarBandeja();
                                        },
                                        icon: const Icon(Icons.arrow_forward, size: 16),
                                        label: Text(
                                          estado == 'PENDIENTE' ? "Evaluar >" : "Ver Detalle >",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetrica(String titulo, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(titulo, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
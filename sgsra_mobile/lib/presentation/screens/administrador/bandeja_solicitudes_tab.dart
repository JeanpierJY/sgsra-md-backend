import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class BandejaSolicitudesTab extends StatefulWidget {
  const BandejaSolicitudesTab({super.key});

  @override
  State<BandejaSolicitudesTab> createState() => _BandejaSolicitudesTabState();
}

class _BandejaSolicitudesTabState extends State<BandejaSolicitudesTab> {
  final ApiService _apiService = ApiService();
  List<dynamic> _solicitudes = [];
  List<dynamic> _solicitudesFiltradas = [];
  bool _cargando = true;
  String _filtroEstado = "Todas";

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
        List<dynamic> lista = [];
        if (res.data is List) {
          lista = res.data;
        } else if (res.data is Map && res.data['content'] != null) {
          lista = res.data['content'] as List;
        }
        setState(() {
          _solicitudes = lista;
          _filtrar(lista, _filtroEstado);
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _filtrar(List<dynamic> base, String estado) {
    if (estado == "Todas") {
      _solicitudesFiltradas = List.from(base);
    } else {
      _solicitudesFiltradas = base.where((s) => (s['estado'] ?? '').toString().toUpperCase() == estado.toUpperCase()).toList();
    }
  }

  void _evaluarSolicitud(dynamic sol) {
    final solNum = sol['solicitudNum'] ?? '';
    final justifCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Evaluacion: $solNum", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text("Equipo: ${sol['codMaquinaria'] ?? ''}"),
            Text("Mecanico: ${sol['nombreMecanico'] ?? sol['dniMecanico'] ?? ''}"),
            Text("Prioridad: ${sol['prioridad'] ?? ''}"),
            const SizedBox(height: 8),
            Text("Justificacion: ${sol['justificacionTecnica'] ?? ''}", style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      setState(() => _cargando = true);
                      await _apiService.aprobarSolicitudTotal(solNum, "leao.chura@masterdrilling.com");
                      _cargarBandeja();
                    },
                    child: const Text("APROBAR TOTAL", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _modalRechazo(solNum);
                    },
                    child: const Text("RECHAZAR", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _modalRechazo(String solNum) {
    final justifCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rechazar Solicitud"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ingrese la causa tecnica del rechazo (>15 caracteres):"),
            const SizedBox(height: 10),
            TextField(
              controller: justifCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Motivo detallado..."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (justifCtrl.text.trim().length < 15) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("El motivo debe tener al menos 15 caracteres")),
                );
                return;
              }
              Navigator.pop(ctx);
              setState(() => _cargando = true);
              await _apiService.rechazarSolicitudTotal(solNum, "leao.chura@masterdrilling.com", justifCtrl.text.trim());
              _cargarBandeja();
            },
            child: const Text("Confirmar Rechazo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pendientes = _solicitudes.where((s) => (s['estado'] ?? '') == 'PENDIENTE').length;
    final int aprobadas = _solicitudes.where((s) => (s['estado'] ?? '') == 'APROBADA').length;
    final int rechazadas = _solicitudes.where((s) => (s['estado'] ?? '') == 'RECHAZADA').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bandeja de Solicitudes"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarBandeja),
        ],
      ),
      body: Column(
        children: [
          // Metricas superiores
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _cardContador("Pendientes", "$pendientes", Colors.orange),
                const SizedBox(width: 8),
                _cardContador("Aprobadas", "$aprobadas", Colors.green),
                const SizedBox(width: 8),
                _cardContador("Rechazadas", "$rechazadas", Colors.red),
              ],
            ),
          ),

          // Selector de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ["Todas", "PENDIENTE", "APROBADA", "RECHAZADA"].map((estado) {
                final bool sel = _filtroEstado == estado;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(estado),
                    selected: sel,
                    onSelected: (val) {
                      setState(() {
                        _filtroEstado = estado;
                        _filtrar(_solicitudes, estado);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _solicitudesFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                            const SizedBox(height: 12),
                            Text("No hay solicitudes en estado $_filtroEstado"),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _solicitudesFiltradas.length,
                        itemBuilder: (ctx, i) {
                          final s = _solicitudesFiltradas[i];
                          final estado = (s['estado'] ?? 'PENDIENTE').toString();
                          return Card(
                            child: ListTile(
                              title: Text("${s['solicitudNum']} · ${s['codMaquinaria']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Fecha: ${s['fechaEmision']} · Prioridad: ${s['prioridad']}"),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: estado == 'PENDIENTE' ? const Color(0xFF0D47A1) : Colors.grey,
                                ),
                                onPressed: () => _evaluarSolicitud(s),
                                child: Text(estado == 'PENDIENTE' ? "Evaluar" : "Ver"),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _cardContador(String label, String valor, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class DetalleSolicitudScreen extends StatefulWidget {
  final String solicitudNum;

  const DetalleSolicitudScreen({super.key, required this.solicitudNum});

  @override
  State<DetalleSolicitudScreen> createState() => _DetalleSolicitudScreenState();
}

class _DetalleSolicitudScreenState extends State<DetalleSolicitudScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _detalle;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final res = await _apiService.obtenerDetalleSolicitud(widget.solicitudNum);
      if (mounted) {
        setState(() {
          _detalle = res.data;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _aprobarTotal() async {
    try {
      await _apiService.aprobarSolicitudTotal(widget.solicitudNum, "leao.chura@masterdrilling.com");
      if (!mounted) return;
      _modalExito("Solicitud Aprobada", "La orden ${widget.solicitudNum} ha sido autorizada. Se despachó alerta push inmediata.");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al aprobar")));
    }
  }

  void _modalRechazo() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rechazar Solicitud de Repuestos"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ingrese obligatoriamente la causa técnica de la denegación (>15 caracteres):",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ej. Stock existente en pañol cubre el requerimiento inmediato...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              if (controller.text.trim().length >= 15) {
                Navigator.pop(ctx);
                await _apiService.rechazarSolicitudTotal(
                  widget.solicitudNum,
                  "leao.chura@masterdrilling.com",
                  controller.text.trim(),
                );
                _modalExito("Solicitud Rechazada", "Se registró el dictamen de denegación.");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("El motivo debe tener al menos 15 caracteres")),
                );
              }
            },
            child: const Text("Confirmar Rechazo"),
          ),
        ],
      ),
    );
  }

  void _modalExito(String titulo, String subtitulo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitulo, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Volver a la Bandeja"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_detalle == null) {
      return const Scaffold(body: Center(child: Text("Error al cargar la solicitud.")));
    }

    final d = _detalle!;
    final estado = (d['estado'] ?? 'PENDIENTE').toString();
    final prioridad = (d['prioridad'] ?? 'MEDIA').toString();
    final List repuestos = d['repuestos'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: Text(widget.solicitudNum)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Encabezado con estado y prioridad (Figma P16)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(label: Text(estado), backgroundColor: Colors.amber.shade100),
              Chip(label: Text("Prioridad $prioridad"), backgroundColor: Colors.red.shade100),
            ],
          ),
          const SizedBox(height: 12),

          // Tarjeta Maquinaria
          Card(
            child: ListTile(
              leading: const Icon(Icons.precision_manufacturing, color: Color(0xFF0D47A1)),
              title: const Text("Maquinaria Afectada", style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text("${d['codMaquinaria']} / ${d['modeloMaquinaria'] ?? 'MD RD IV'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),

          // Tarjeta Mecánico
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF0D47A1)),
              title: const Text("Mecánico Solicitante", style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text("${d['nombreMecanico']} / Teléfono: ${d['telefonoMecanico'] ?? '995 348 431'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),

          // Repuestos Pedidos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Repuestos Pedidos", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...repuestos.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(child: Text("${r['cantidad']}x ${r['nombreRepuesto'] ?? r['codParte']}")),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Justificación Técnica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("JUSTIFICACIÓN TÉCNICA INGRESADA POR EL OPERARIO",
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(d['justificacionTecnica'] ?? 'Sin detalle técnico reportado.', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botones de Acción (Figma P16: Aprobar, Rechazar, Modo Parcial)
          if (estado == 'PENDIENTE') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              onPressed: _aprobarTotal,
              child: const Text("Aprobar Solicitud"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: _modalRechazo,
              child: const Text("Rechazar Solicitud"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aprobación Parcial iniciada")),
                );
              },
              child: const Text("Modo Parcial"),
            ),
          ],
        ],
      ),
    );
  }
}
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
  String? _errorMensaje;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _cargando = true;
      _errorMensaje = null;
    });

    try {
      final res = await _apiService.obtenerDetalleSolicitud(widget.solicitudNum);
      if (mounted) {
        dynamic dataExtraida = res.data;
        // Si el backend envuelve la respuesta en una llave 'data', la extraemos
        if (dataExtraida is Map<String, dynamic> && dataExtraida.containsKey('data')) {
          dataExtraida = dataExtraida['data'];
        }

        setState(() {
          _detalle = dataExtraida as Map<String, dynamic>;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMensaje = "No se pudo cargar el detalle de la solicitud ${widget.solicitudNum}. Verifique que el servicio este activo.";
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle: ${widget.solicitudNum}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDetalle,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _errorMensaje != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMensaje!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarDetalle,
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
                  ),
                )
              : _detalle == null
                  ? const Center(child: Text("Sin informacion disponible."))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Encabezado principal
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _detalle!['solicitudNum'] ?? widget.solicitudNum,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    _badgeEstado(_detalle!['estado'] ?? 'PENDIENTE'),
                                  ],
                                ),
                                const Divider(height: 24),
                                _filaInfo("Maquinaria:", _detalle!['codMaquinaria'] ?? 'N/A'),
                                _filaInfo("Prioridad:", _detalle!['prioridad'] ?? 'N/A'),
                                _filaInfo("Fecha Emision:", _detalle!['fechaEmision'] ?? 'N/A'),
                                _filaInfo("Mecanico Solicitante:", _detalle!['correoMecanico'] ?? 'N/A'),
                                const SizedBox(height: 8),
                                const Text("Justificacion Tecnica:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  _detalle!['justificacionTecnica'] ?? 'Sin justificacion especificada.',
                                  style: TextStyle(color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Listado de Repuestos Requeridos
                        const Text(
                          "COMPONENTES Y REPUESTOS SOLICITADOS",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...(_detalle!['items'] as List<dynamic>? ?? []).map((item) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE3F2FD),
                                child: Icon(Icons.settings, color: Color(0xFF0D47A1)),
                              ),
                              title: Text(item['nombreRepuesto'] ?? item['codParte'] ?? 'Repuesto', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Codigo: ${item['codParte'] ?? ''}\nEstado Item: ${item['estadoItem'] ?? 'PENDIENTE'}"),
                              trailing: Text(
                                "${item['cantidad']} uds.",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                              ),
                            ),
                          );
                        }),

                        // Mostrar rechazo si existe
                        if (_detalle!['dictamenRechazo'] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text("DICTAMEN DE RECHAZO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("Motivo: ${_detalle!['dictamenRechazo']['justificacion'] ?? 'Sin detalle'}"),
                                Text("Evaluado por: ${_detalle!['dictamenRechazo']['correoAdmin'] ?? 'Administrador'}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
    );
  }

  Widget _filaInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colors.black54)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    Color bg = Colors.orange.shade100;
    Color fg = Colors.orange.shade900;
    if (estado == 'APROBADA') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
    } else if (estado == 'RECHAZADA') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(estado, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
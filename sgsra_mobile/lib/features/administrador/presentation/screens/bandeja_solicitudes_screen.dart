import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';

class BandejaSolicitudesScreen extends StatefulWidget {
  const BandejaSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<BandejaSolicitudesScreen> createState() => _BandejaSolicitudesScreenState();
}

class _BandejaSolicitudesScreenState extends State<BandejaSolicitudesScreen> {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  List<dynamic> _solicitudes = [];
  String _filtroEstado = 'TODAS';

  @override
  void initState() {
    super.initState();
    _cargarBandeja();
  }

  Future<String> _obtenerCorreoAdmin() async {
    return await _storage.read(key: 'correo_admin') ?? 'leao.chura@masterdrilling.com';
  }

  Future<void> _cargarBandeja() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, dynamic>{};
      if (_filtroEstado != 'TODAS') {
        queryParams['estado'] = _filtroEstado;
      }
      final res = await _dioClient.dio.get('/solicitudes/bandeja', queryParameters: queryParams);
      setState(() {
        _solicitudes = res.data is List ? res.data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al sincronizar bandeja: $e', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? AppColors.errorRed : AppColors.primaryBlue,
      ),
    );
  }

  Future<void> _aprobarTotal(String solicitudNum) async {
    try {
      final correo = await _obtenerCorreoAdmin();
      await _dioClient.dio.put(
        '/solicitudes/$solicitudNum/aprobar',
        queryParameters: {'correoAdmin': correo},
      );
      _mostrarMensaje('Solicitud $solicitudNum aprobada íntegramente');
      _cargarBandeja();
    } catch (e) {
      _mostrarMensaje('Error al aprobar: $e', esError: true);
    }
  }

  void _mostrarDialogoRechazo(String solicitudNum) {
    final formKey = GlobalKey<FormState>();
    final motivoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rechazar Requerimiento $solicitudNum'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: motivoCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Justificación técnica de rechazo (Mín. 15 caracteres)',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 15)
                ? 'Debe fundamentar con al menos 15 caracteres'
                : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                try {
                  final correo = await _obtenerCorreoAdmin();
                  await _dioClient.dio.put(
                    '/solicitudes/$solicitudNum/rechazar',
                    queryParameters: {'correoAdmin': correo},
                    data: {'justificacionRechazo': motivoCtrl.text.trim()},
                  );
                  _mostrarMensaje('Solicitud rechazada formalmente');
                  _cargarBandeja();
                } catch (e) {
                  _mostrarMensaje('Error al rechazar: $e', esError: true);
                }
              }
            },
            child: const Text('Confirmar Rechazo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarModalContactarProveedor(String solicitudNum) {
    final formKey = GlobalKey<FormState>();
    final cotizacionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Marcar Orden Contactada: $solicitudNum'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: cotizacionCtrl,
            decoration: const InputDecoration(
              labelText: 'Código de Cotización Formal (Ej. COT-2026-99)',
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese el número de cotización' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                try {
                  final correo = await _obtenerCorreoAdmin();
                  await _dioClient.dio.put(
                    '/solicitudes/$solicitudNum/contactar',
                    queryParameters: {'correoAdmin': correo},
                    data: {'codigoCotizacion': cotizacionCtrl.text.trim()},
                  );
                  _mostrarMensaje('Orden marcada como contactada con proveedor');
                  _cargarBandeja();
                } catch (e) {
                  _mostrarMensaje('Error al marcar contactada: $e', esError: true);
                }
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _verExpedienteDetallado(String solicitudNum) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await _dioClient.dio.get('/solicitudes/$solicitudNum');
      Navigator.pop(context);
      final data = res.data;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.pureWhite,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Expediente: ${data['solicitudNum']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  Chip(label: Text(data['estado'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)), backgroundColor: AppColors.primaryBlue),
                ],
              ),
              const Divider(height: 24),
              const Text('Datos del Mecánico Solicitante:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Nombre: ${data['nombreMecanico']} | DNI: ${data['dniMecanico']}'),
              Text('Teléfono: ${data['telefonoMecanico'] ?? 'No registrado'}'),
              const SizedBox(height: 12),
              const Text('Datos de la Maquinaria Pesada:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Código: ${data['codMaquinaria']} | Modelo: ${data['modeloMaquinaria']}'),
              Text('Serie: ${data['serieMaquinaria'] ?? 'N/A'}'),
              const SizedBox(height: 12),
              const Text('Causa Técnica:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${data['justificacionTecnica']}', style: const TextStyle(fontStyle: FontStyle.italic)),
              const Divider(height: 24),
              const Text('Repuestos Requeridos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...((data['repuestos'] as List? ?? []).map((r) => Card(
                    color: AppColors.backgroundGray,
                    child: ListTile(
                      dense: true,
                      leading: Text('#${r['item']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      title: Text('${r['nombreRepuesto']} (${r['codParte']})'),
                      subtitle: Text('Cantidad Solicitada: ${r['cantidadSolicitada']}'),
                      trailing: Chip(
                        label: Text(r['estadoItem'] ?? 'PENDIENTE', style: const TextStyle(fontSize: 10, color: Colors.white)),
                        backgroundColor: r['estadoItem'] == 'APROBADO' ? Colors.green : Colors.grey,
                      ),
                    ),
                  ))),
              if (data['rechazo'] != null) ...[
                const Divider(height: 24),
                const Text('Resolución de Rechazo:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                Text('Evaluador: ${data['rechazo']['evaluador']} | Fecha: ${data['rechazo']['fechaEvaluacion']}'),
                Text('Motivo: "${data['rechazo']['justificacionRechazo']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      _mostrarMensaje('No se pudo cargar el expediente: $e', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Bandeja de Requerimientos [RF21]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarBandeja),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['TODAS', 'PENDIENTE', 'APROBADA', 'RECHAZADA', 'ORDEN_CONTACTADA'].map((st) {
                  final seleccionado = _filtroEstado == st;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: seleccionado,
                      label: Text(st),
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: seleccionado ? AppColors.primaryBlue : Colors.black87,
                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _filtroEstado = st);
                        _cargarBandeja();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : _solicitudes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text('No hay órdenes registradas con filtro "$_filtroEstado"', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _solicitudes.length,
                        itemBuilder: (context, index) {
                          final sol = _solicitudes[index];
                          final estado = sol['estado'] ?? 'PENDIENTE';
                          final esPendiente = estado == 'PENDIENTE';
                          final esAprobada = estado == 'APROBADA';

                          return Card(
                            color: AppColors.pureWhite,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _verExpedienteDetallado(sol['solicitudNum']),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(sol['solicitudNum'] ?? '',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: esPendiente
                                                ? Colors.amber[800]
                                                : (estado == 'RECHAZADA' ? AppColors.errorRed : Colors.green[700]),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(estado, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18),
                                    Text('Mecánico: ${sol['nombreMecanico'] ?? 'No asignado'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Text('Máquina: ${sol['codMaquinaria']} (${sol['modeloMaquinaria'] ?? 'MD'}) | Prioridad: ${sol['prioridad']}'),
                                    Text('Total Componentes: ${sol['totalComponentes'] ?? 1} | Fecha: ${sol['fechaEmision']}'),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _verExpedienteDetallado(sol['solicitudNum']),
                                          icon: const Icon(Icons.visibility_outlined, size: 16),
                                          label: const Text('Expediente [RF22]'),
                                        ),
                                        if (esPendiente) ...[
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorRed, side: const BorderSide(color: AppColors.errorRed)),
                                            onPressed: () => _mostrarDialogoRechazo(sol['solicitudNum']),
                                            child: const Text('Rechazar [RF25]'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                                            onPressed: () => _aprobarTotal(sol['solicitudNum']),
                                            child: const Text('Aprobar [RF23]', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                        if (esAprobada) ...[
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                            onPressed: () => _mostrarModalContactarProveedor(sol['solicitudNum']),
                                            icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
                                            label: const Text('Contactar [RF28]', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
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
}
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/repuesto_remote_datasource.dart';
import '../../../../core/network/dio_client.dart';

class HistorialSolicitudesScreen extends StatefulWidget {
  const HistorialSolicitudesScreen({Key? key}) : super(key: key);

  @override
  State<HistorialSolicitudesScreen> createState() => _HistorialSolicitudesScreenState();
}

class _HistorialSolicitudesScreenState extends State<HistorialSolicitudesScreen> {
  final RepuestoRemoteDataSource _dataSource = RepuestoRemoteDataSource(DioClient());
  bool _isLoading = true;
  List<dynamic> _historial = [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dataSource.listarHistorial();
      setState(() {
        _historial = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar historial: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'APROBADA':
        return Colors.green[700]!;
      case 'RECHAZADA':
        return AppColors.errorRed;
      case 'ORDEN_CONTACTADA':
        return Colors.teal;
      case 'PENDIENTE':
      default:
        return Colors.amber[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Mis Solicitudes [RF19]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarHistorial),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _historial.isEmpty
              ? const Center(child: Text('Usted no registra ordenes en el historico.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _historial.length,
                  itemBuilder: (context, index) {
                    final item = _historial[index];
                    final estado = item['estado']?.toString() ?? 'PENDIENTE';

                    return Card(
                      color: AppColors.pureWhite,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item['solicitudNum']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _obtenerColorEstado(estado), borderRadius: BorderRadius.circular(20)),
                                  child: Text(estado, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Text('Maquinaria: ${item['codMaquinaria']} | Prioridad: ${item['prioridad']}'),
                            Text('Fecha de Emision: ${item['fechaEmision']}'),
                            if (item['justificacionTecnica'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text('Causa: "${item['justificacionTecnica']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
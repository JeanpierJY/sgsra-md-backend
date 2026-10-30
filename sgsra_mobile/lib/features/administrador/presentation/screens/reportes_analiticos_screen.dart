import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';

class ReportesAnaliticosScreen extends StatefulWidget {
  const ReportesAnaliticosScreen({Key? key}) : super(key: key);

  @override
  State<ReportesAnaliticosScreen> createState() => _ReportesAnaliticosScreenState();
}

class _ReportesAnaliticosScreenState extends State<ReportesAnaliticosScreen> {
  final DioClient _dioClient = DioClient();
  bool _isLoading = true;
  List<dynamic> _demanda = [];

  @override
  void initState() {
    super.initState();
    _cargarDemanda();
  }

  Future<void> _cargarDemanda() async {
    setState(() => _isLoading = true);
    try {
      final res = await _dioClient.dio.get('/reportes/demanda');
      setState(() {
        _demanda = res.data is List ? res.data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje('Error al obtener demanda analítica: $e', esError: true);
    }
  }

  Future<void> _exportarArchivo(String formato) async {
    _mostrarMensaje('Generando y descargando consolidado en $formato... [RF30]');
    try {
      final res = await _dioClient.dio.get(
        '/reportes/exportar',
        queryParameters: {'formato': formato},
        options: Options(responseType: ResponseType.bytes, headers: {'Accept': '*/*'}),
      );

      final nombreArchivo = formato == 'EXCEL'
          ? 'Reporte_Consolidado_SGSRA_MD.xlsx'
          : 'Reporte_Metricas_SGSRA_MD.csv';

      if (kIsWeb) {
        final blob = html.Blob([res.data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', nombreArchivo)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      _mostrarMensaje('Error al exportar archivo: $e', esError: true);
    }
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: esError ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    longitudMaxima() {
      if (_demanda.isEmpty) return 1;
      return _demanda.map((e) => (e['cantidadTotalSolicitada'] as num?)?.toInt() ?? 0).reduce((a, b) => a > b ? a : b);
    }

    final maxVal = longitudMaxima() == 0 ? 1 : longitudMaxima();

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Métricas y Reportes Oficiales [RF29]', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargarDemanda),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.pureWhite,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top Repuestos Más Demandados [RF29]',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        Icon(Icons.insights_rounded, color: AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Consumo acumulado según historial de órdenes de mantenimiento mina.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(height: 24),
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                    else if (_demanda.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No hay historial de consumo acumulado.')))
                    else
                      ..._demanda.map((item) {
                        final cant = (item['cantidadTotalSolicitada'] as num?)?.toInt() ?? 0;
                        final factor = (cant / maxVal).clamp(0.05, 1.0);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item['nombreRepuesto']} (${item['codParte']})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('$cant unids.', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Stack(
                                children: [
                                  Container(height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                                  FractionallySizedBox(
                                    widthFactor: factor,
                                    child: Container(
                                      height: 12,
                                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.pureWhite,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exportación de Informes Consolidados [RF30]',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                    const SizedBox(height: 4),
                    const Text('Genera el expediente formal con todas las transacciones auditadas.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _exportarArchivo('EXCEL'),
                            icon: const Icon(Icons.table_view_rounded, color: Colors.white),
                            label: const Text('Exportar Excel (.xlsx)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _exportarArchivo('CSV'),
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Exportar CSV Plano'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
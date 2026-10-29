import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class MetricasAdminTab extends StatefulWidget {
  const MetricasAdminTab({super.key});

  @override
  State<MetricasAdminTab> createState() => _MetricasAdminTabState();
}

class _MetricasAdminTabState extends State<MetricasAdminTab> {
  final ApiService _apiService = ApiService();
  bool _descargando = false;

  Future<void> _descargarReporteExcel() async {
    setState(() => _descargando = true);
    try {
      await _apiService.descargarArchivoNativo('/reportes/exportar/excel', 'Reporte_Demanda_30_Dias.xlsx');
      if (!mounted) return;
      setState(() => _descargando = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Reporte Consolidado"),
            ],
          ),
          content: const Text("El archivo 'Reporte_Demanda_30_Dias.xlsx' se descargo exitosamente en su equipo."),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Entendido")),
          ],
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _descargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al generar el reporte en el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadisticas y Demanda")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF0D47A1), size: 20),
                SizedBox(width: 8),
                Text("Periodo de Analisis: Ultimos 30 dias", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _barra("Bomba Rexroth P-REX-024", 18, 0.45),
          _barra("Manguera H-ESP-118", 34, 0.85),
          _barra("Filtro F-HYD-882", 42, 1.0),
          _barra("Kit sellos Viton K-SEL-340", 22, 0.55),
          _barra("Valvula V-ALL-111", 12, 0.30),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(8)),
            child: const Center(
              child: Text(
                "Total piezas solicitadas en el periodo: 128 unidades",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), minimumSize: const Size(double.infinity, 48)),
            icon: _descargando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.table_view, color: Colors.white),
            label: const Text("EXPORTAR REPORTE EN EXCEL (.XLSX)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _descargando ? null : _descargarReporteExcel,
          ),
        ],
      ),
    );
  }

  Widget _barra(String nombre, int cantidad, double factor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$cantidad uds.", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: factor,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF0D47A1),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
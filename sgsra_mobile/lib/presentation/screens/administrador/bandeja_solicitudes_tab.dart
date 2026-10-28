import 'package:flutter/material.dart';

class BandejaSolicitudesTab extends StatelessWidget {
  const BandejaSolicitudesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización limpia desde cero de todas las variables analíticas
    int pendientesAprobacion = 0;
    int herramientasPrestadas = 0;
    int alertasStockBajo = 0;
    int eficienciaMantenimiento = 0;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Cuadrícula de KPIs numéricos de alto impacto
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildKpiCard("PENDIENTES APROBACIÓN", "$pendientesAprobacion", "0 críticas", Colors.grey),
              _buildKpiCard("HERRAMIENTAS PRESTADAS", "$herramientasPrestadas", "En orden", Colors.green),
              _buildKpiCard("ALERTAS DE STOCK BAJO", "$alertasStockBajo", "Atención", Colors.red),
              _buildKpiCard("EFICIENCIA MANTENIMIENTO", "$eficienciaMantenimiento%", "Óptimo", Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          // Cabecera Descriptiva de la Bandeja
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text("Bandeja de Solicitudes\nde Repuestos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Text("Sincronizado", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Gestión y autorización remota de solicitudes de repuestos para maquinaria pesada", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  ActionChip(
                    avatar: const Icon(Icons.access_time, size: 14),
                    label: Text("$pendientesAprobacion Por Revisar"),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buscador principal integrado
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar por código SOL, mecánico o máquina...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          // Estado Inicial Vacío: Muestra un aviso limpio si no hay registros cargados aún
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "Bandeja limpia.\nNo se registran requerimientos pendientes de evaluación.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String sub, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

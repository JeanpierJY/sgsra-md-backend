import 'package:flutter/material.dart';

class AnaliticaAuditoriaTab extends StatelessWidget {
  const AnaliticaAuditoriaTab({super.key});

  @override
  Widget build(BuildContext context) {
    int totalTrazasAuditadas = 0; // Estado inicial limpio desde cero

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ====== SECCIÓN 1: PANEL EJECUTIVO DE MÉTRICAS (RF29 - Imagen 3 y 4) ======
        const Text("MÉTRICAS & ESTADÍSTICAS OPERATIVAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Panel Ejecutivo de Métricas\n& Estadísticas (RF29)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Analítica de consumo de repuestos para perforación y disponibilidad operativa", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Grid de Analítica inicializada en cero de forma limpia
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildAnaliticaCard("TASA DE APROBACIÓN", "0%", "0 procesadas", Colors.grey),
            _buildAnaliticaCard("TIEMPO PROMEDIO APROBACIÓN", "0 min", "Optimizado", Colors.green),
            _buildAnaliticaCard("VALOR GESTIONADO EST.", r"$0 USD", "Circuitos", Colors.grey),
            _buildAnaliticaCard("DISPONIBILIDAD HERRAMIENTAS", "0%", "0 en casillero", Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        // Marcador de Gráfico Vacío (Simula la Imagen 4)
        Card(
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text("Frecuencia de Solicitudes por Maquinaria\n[Esperando agregación de datos del servidor]", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ====== SECCIÓN 2: BITÁCORA INALTERABLE DE AUDITÓRIA (RF49 - Imagen 5) ======
        const Text("TRAZABILIDAD Y AUDITORÍA CRIPTOGRÁFICA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bitácora Inalterable\nde Auditoría (RF30, RF49)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Registro secuencial criptográficamente firmado para trazabilidad operativa y cumplimiento", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text("Exportar CSV (RF30)"),
                      onPressed: totalTrazasAuditadas == 0 ? null : () {}, // Bloqueado si no hay datos
                    )
                  ],
                ),
                Positioned(
                  right: 0, top: 0,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade100,
                    child: const Text("SHA-\n256\nReady", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: "Filtrar por operador, ID de solicitud, detalle...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text("No se registran trazas ni firmas criptográficas en este periodo.", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
        )
      ],
    );
  }

  Widget _buildAnaliticaCard(String title, String value, String sub, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AuditoriaAdminTab extends StatelessWidget {
  const AuditoriaAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text("Bitácora de Auditoría")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Registro inmutable de operaciones (Append-Only)", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          _filaAuditoria("SOL-0142", "Creada", "Carlos Mendoza", "17/09/2026 08:30", "192.168.1.45"),
          _filaAuditoria("SOL-0142", "Aprobada", "Leao Chura", "17/09/2026 09:15", "192.168.1.10"),
          _filaAuditoria("PRES-0081", "Despacho", "Marcos Ramos", "17/09/2026 10:00", "192.168.1.55"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Exportar Reporte en PDF"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generando consolidado PDF de auditoría...")),
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            icon: const Icon(Icons.table_view),
            label: const Text("Exportar en CSV Cifrado"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Exportación CSV completada en Descargas")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filaAuditoria(String cod, String accion, String usuario, String fecha, String ip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.verified_user, color: Colors.blue),
        title: Text("$cod · $accion", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$usuario · IP: $ip\n$fecha"),
      ),
    );
  }
}
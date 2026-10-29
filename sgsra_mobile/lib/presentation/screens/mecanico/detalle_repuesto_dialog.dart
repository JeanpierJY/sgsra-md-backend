import 'package:flutter/material.dart';

class DetalleRepuestoDialog extends StatelessWidget {
  final Map<String, dynamic> repuesto;
  final String userRol;

  const DetalleRepuestoDialog({super.key, required this.repuesto, required this.userRol});

  @override
  Widget build(BuildContext context) {
    final cod = repuesto['codParte'] ?? '';
    final nom = repuesto['nombreRepuesto'] ?? '';
    final stock = repuesto['stockActual'] ?? 0;
    final bool isAdmin = userRol == 'ADMINISTRADOR';

    return AlertDialog(
      title: Text(nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.precision_manufacturing, size: 64, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 12),
            Text("Codigo de Parte: $cod", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Stock en Pañol Central: $stock unidades"),
            const SizedBox(height: 8),
            const Divider(),
            if (isAdmin) ...[
              const Text("DATOS DE CONTACTO DE PROVEEDOR HOMOLOGADO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 4),
              const Text("Proveedor: Bosch Rexroth del Peru S.A."),
              const Text("Contacto Comercial: Ing. Valeria Quispe"),
              const Text("Telefono / WhatsApp: +51 987 654 321"),
              const Text("Tiempo de Entrega Estimado: 48 horas en mina"),
            ] else ...[
              const Text("ESPECIFICACIONES TECNICAS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              const Text("Compatibilidad: Raise Borer Rhino 1008 (MD-RB-01)"),
              const Text("Presion Maxima: 350 bar"),
              const Text("Caudal Nominal: 180 L/min"),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
      ],
    );
  }
}
/// [RF13, RF14, RF15, RF16, RF20] Entidad de solicitud de repuestos
class SolicitudEntity {
  final String? id;
  final String correlativo; // SOL-2026-XXXX [RF17]
  final String codParte;
  final String nombreRepuesto;
  final int cantidad;
  final String prioridad; // BAJA, MEDIA, ALTA [RF14]
  final String codigoMaquinaria; // MD-RB-01, etc. [RF15]
  final String justificacion; // Mínimo 10 caracteres [RF16]
  final String estado; // PENDIENTE, APROBADA, RECHAZADA, etc. [RF20]
  final DateTime fechaCreacion;

  const SolicitudEntity({
    this.id,
    required this.correlativo,
    required this.codParte,
    required this.nombreRepuesto,
    required this.cantidad,
    required this.prioridad,
    required this.codigoMaquinaria,
    required this.justificacion,
    required this.estado,
    required this.fechaCreacion,
  });
}
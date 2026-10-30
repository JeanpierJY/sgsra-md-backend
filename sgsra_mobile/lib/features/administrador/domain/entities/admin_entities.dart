/// [RF21, RF22, RF31] Entidades para la gestión administrativa y auditoría
class SolicitudBandejaEntity {
  final String id;
  final String correlativo;
  final String solicitante;
  final String nombreRepuesto;
  final int cantidad;
  final String prioridad;
  final String codigoMaquinaria;
  final String justificacion;
  final String estado;
  final DateTime fechaCreacion;

  const SolicitudBandejaEntity({
    required this.id,
    required this.correlativo,
    required this.solicitante,
    required this.nombreRepuesto,
    required this.cantidad,
    required this.prioridad,
    required this.codigoMaquinaria,
    required this.justificacion,
    required this.estado,
    required this.fechaCreacion,
  });
}

class AuditoriaEntity {
  final String id;
  final String usuario;
  final String accion;
  final String ip;
  final String hashSha256; // [RF49] Trazabilidad inalterable
  final DateTime fecha;

  const AuditoriaEntity({
    required this.id,
    required this.usuario,
    required this.accion,
    required this.ip,
    required this.hashSha256,
    required this.fecha,
  });
}
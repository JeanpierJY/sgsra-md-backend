class SolicitudEntity {
  final String? id;
  final String correlativo;
  final String codParte;
  final String nombreRepuesto;
  final int cantidad;
  final String prioridad;
  final String codigoMaquinaria;
  final String justificacion;
  final String estado;
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
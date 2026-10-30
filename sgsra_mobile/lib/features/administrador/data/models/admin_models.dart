import '../../domain/entities/admin_entities.dart';

class SolicitudBandejaModel extends SolicitudBandejaEntity {
  const SolicitudBandejaModel({
    required String id,
    required String correlativo,
    required String solicitante,
    required String nombreRepuesto,
    required int cantidad,
    required String prioridad,
    required String codigoMaquinaria,
    required String justificacion,
    required String estado,
    required DateTime fechaCreacion,
  }) : super(
          id: id,
          correlativo: correlativo,
          solicitante: solicitante,
          nombreRepuesto: nombreRepuesto,
          cantidad: cantidad,
          prioridad: prioridad,
          codigoMaquinaria: codigoMaquinaria,
          justificacion: justificacion,
          estado: estado,
          fechaCreacion: fechaCreacion,
        );

  factory SolicitudBandejaModel.fromJson(Map<String, dynamic> json) {
    // Sincronizado exactamente con SolicitudResumenResponse del Backend Java
    return SolicitudBandejaModel(
      id: json['solicitudNum']?.toString() ?? '',
      correlativo: json['solicitudNum'] ?? '',
      solicitante: json['nombreMecanico'] ?? 'Mecánico',
      nombreRepuesto: json['nombreRepuesto'] ?? 'Repuesto General',
      cantidad: json['totalComponentes'] ?? 1,
      prioridad: json['prioridad'] ?? 'ALTA',
      codigoMaquinaria: json['codMaquinaria'] ?? '',
      justificacion: json['justificacionTecnica'] ?? json['justificacion'] ?? 'Sin justificación técnica',
      estado: json['estado'] ?? 'PENDIENTE',
      fechaCreacion: DateTime.tryParse(json['fechaEmision'] ?? '') ?? DateTime.now(),
    );
  }
}
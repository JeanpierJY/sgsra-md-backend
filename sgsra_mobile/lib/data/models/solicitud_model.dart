class SolicitudModel {
  final String solicitudNum;
  final String fechaEmision;
  final String horaEmision;
  final String prioridad;
  final String estado;
  final String codMaquinaria;
  final String? modeloMaquinaria;
  final String nombreMecanico;
  final int totalComponentes;

  SolicitudModel({
    required this.solicitudNum,
    required this.fechaEmision,
    required this.horaEmision,
    required this.prioridad,
    required this.estado,
    required this.codMaquinaria,
    this.modeloMaquinaria,
    required this.nombreMecanico,
    required this.totalComponentes,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    return SolicitudModel(
      solicitudNum: json['solicitudNum'] ?? '',
      fechaEmision: json['fechaEmision'] ?? '',
      horaEmision: json['horaEmision'] ?? '',
      prioridad: json['prioridad'] ?? '',
      estado: json['estado'] ?? '',
      codMaquinaria: json['codMaquinaria'] ?? '',
      modeloMaquinaria: json['modeloMaquinaria'],
      nombreMecanico: json['nombreMecanico'] ?? '',
      totalComponentes: json['totalComponentes'] ?? 0,
    );
  }
}

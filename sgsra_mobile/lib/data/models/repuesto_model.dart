class RepuestoModel {
  final String codParte;
  final String nombreRepuesto;
  final int stockActual;
  final int stockMinimo;
  final String? descripcion;
  final bool activo;

  RepuestoModel({
    required this.codParte,
    required this.nombreRepuesto,
    required this.stockActual,
    required this.stockMinimo,
    this.descripcion,
    required this.activo,
  });

  factory RepuestoModel.fromJson(Map<String, dynamic> json) {
    return RepuestoModel(
      codParte: json['codParte'] as String? ?? '',
      nombreRepuesto: json['nombreRepuesto'] as String? ?? '',
      stockActual: json['stockActual'] as int? ?? 0,
      stockMinimo: json['stockMinimo'] as int? ?? 0,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codParte': codParte,
      'nombreRepuesto': nombreRepuesto,
      'stockActual': stockActual,
      'stockMinimo': stockMinimo,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
class RepuestoModel {
  final String codParte;
  final String nombreRepuesto;
  final int stockActual;
  final int stockMinimo;

  RepuestoModel({
    required this.codParte,
    required this.nombreRepuesto,
    required this.stockActual,
    required this.stockMinimo,
  });

  factory RepuestoModel.fromJson(Map<String, dynamic> json) {
    return RepuestoModel(
      codParte: json['codParte'] ?? '',
      nombreRepuesto: json['nombreRepuesto'] ?? '',
      stockActual: json['stockActual'] ?? 0,
      stockMinimo: json['stockMinimo'] ?? 0,
    );
  }
}

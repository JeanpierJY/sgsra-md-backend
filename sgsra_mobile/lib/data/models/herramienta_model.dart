class HerramientaModel {
  final String codHerramienta;
  final String nombreHerramienta;
  final String marcaHerramienta;
  final String categoria;
  final String estadoActual;

  HerramientaModel({
    required this.codHerramienta,
    required this.nombreHerramienta,
    required this.marcaHerramienta,
    required this.categoria,
    required this.estadoActual,
  });

  factory HerramientaModel.fromJson(Map<String, dynamic> json) {
    return HerramientaModel(
      codHerramienta: json['codHerramienta'] ?? '',
      nombreHerramienta: json['nombreHerramienta'] ?? '',
      marcaHerramienta: json['marcaHerramienta'] ?? '',
      categoria: json['categoria'] ?? '',
      estadoActual: json['estadoActual'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codHerramienta': codHerramienta,
      'nombreHerramienta': nombreHerramienta,
      'marcaHerramienta': marcaHerramienta,
      'categoria': categoria,
      'estadoActual': estadoActual,
    };
  }
}

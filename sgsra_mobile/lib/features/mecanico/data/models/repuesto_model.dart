import '../../domain/entities/repuesto_entity.dart';

class RepuestoModel extends RepuestoEntity {
  final bool activo;

  const RepuestoModel({
    required String codParte,
    required String nombre,
    required String descripcion,
    required String familiaMaquinaria,
    required String marca,
    required int stockDisponible,
    required int stockMinimo,
    required this.activo,
    String? urlFoto,
  }) : super(
          codParte: codParte,
          nombre: nombre,
          descripcion: descripcion,
          familiaMaquinaria: familiaMaquinaria,
          marca: marca,
          stockDisponible: stockDisponible,
          stockMinimo: stockMinimo,
          urlFoto: urlFoto,
        );

  factory RepuestoModel.fromJson(Map<String, dynamic> json) {
    return RepuestoModel(
      codParte: json['codParte']?.toString() ?? '',
      nombre: json['nombreRepuesto']?.toString() ?? json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? 'Sin especificaciones tecnicas',
      familiaMaquinaria: json['familiaMaquinaria']?.toString() ?? 'Perforacion Raise Borer',
      marca: json['marca']?.toString() ?? 'Bosch Rexroth / Parker',
      stockDisponible: json['stockActual'] is num ? (json['stockActual'] as num).toInt() : 0,
      stockMinimo: json['stockMinimo'] is num ? (json['stockMinimo'] as num).toInt() : 0,
      activo: json['activo'] ?? true,
      urlFoto: json['urlFoto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codParte': codParte,
      'nombreRepuesto': nombre,
      'descripcion': descripcion,
      'stockActual': stockDisponible,
      'stockMinimo': stockMinimo,
      'activo': activo,
    };
  }
}
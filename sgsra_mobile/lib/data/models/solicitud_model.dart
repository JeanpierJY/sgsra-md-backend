class SolicitudModel {
  final String? solicitudNum;
  final String? fechaEmision;
  final String prioridad;
  final String justificacionTecnica;
  final String? estado;
  final String codMaquinaria;
  final List<ItemRepuestoModel> items;

  SolicitudModel({
    this.solicitudNum,
    this.fechaEmision,
    required this.prioridad,
    required this.justificacionTecnica,
    this.estado,
    required this.codMaquinaria,
    required this.items,
  });

  factory SolicitudModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['repuestos'] as List? ?? [];
    List<ItemRepuestoModel> itemsList =
        rawItems.map((i) => ItemRepuestoModel.fromJson(i as Map<String, dynamic>)).toList();

    return SolicitudModel(
      solicitudNum: json['solicitudNum'] as String?,
      fechaEmision: json['fechaEmision'] as String?,
      prioridad: json['prioridad'] as String? ?? 'MEDIA',
      justificacionTecnica: json['justificacionTecnica'] as String? ?? '',
      estado: json['estado'] as String? ?? 'PENDIENTE',
      codMaquinaria: json['codMaquinaria'] as String? ?? '',
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codMaquinaria': codMaquinaria,
      'prioridad': prioridad,
      'justificacionTecnica': justificacionTecnica,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class ItemRepuestoModel {
  final String codParte;
  final int cantidad;
  final String? nombre;

  ItemRepuestoModel({
    required this.codParte,
    required this.cantidad,
    this.nombre,
  });

  factory ItemRepuestoModel.fromJson(Map<String, dynamic> json) {
    return ItemRepuestoModel(
      codParte: json['codParte'] as String? ?? '',
      cantidad: json['cantidad'] as int? ?? 1,
      nombre: json['nombreRepuesto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codParte': codParte,
      'cantidad': cantidad,
    };
  }
}
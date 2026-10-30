class SolicitudCreacionDto {
  final String codMaquinaria;
  final String prioridad;
  final String justificacionTecnica;
  final List<ItemRepuestoDto> items;

  SolicitudCreacionDto({
    required this.codMaquinaria,
    required this.prioridad,
    required this.justificacionTecnica,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'codMaquinaria': codMaquinaria,
      'prioridad': prioridad,
      'justificacionTecnica': justificacionTecnica,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class ItemRepuestoDto {
  final String codParte;
  final int cantidad;

  ItemRepuestoDto({required this.codParte, required this.cantidad});

  Map<String, dynamic> toJson() {
    return {
      'codParte': codParte,
      'cantidad': cantidad,
    };
  }
}
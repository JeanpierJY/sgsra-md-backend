class RepuestoEntity {
  final String codParte;
  final String nombre;
  final String descripcion;
  final String familiaMaquinaria;
  final String marca;
  final int stockDisponible;
  final int stockMinimo;
  /// [MEC-01] Unidades comprometidas en solicitudes pendientes/aprobadas aún no despachadas
  final int stockReservado;
  final String? urlFoto;

  const RepuestoEntity({
    required this.codParte,
    required this.nombre,
    required this.descripcion,
    required this.familiaMaquinaria,
    required this.marca,
    required this.stockDisponible,
    this.stockMinimo = 0,
    this.stockReservado = 0,
    this.urlFoto,
  });

  /// Unidades que realmente se pueden pedir
  int get stockLibre => (stockDisponible - stockReservado).clamp(0, stockDisponible);

  // El carrito usa el repuesto como clave: se compara por código para no duplicar ítems
  @override
  bool operator ==(Object other) => other is RepuestoEntity && other.codParte == codParte;

  @override
  int get hashCode => codParte.hashCode;
}
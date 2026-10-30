class RepuestoEntity {
  final String codParte;
  final String nombre;
  final String descripcion;
  final String familiaMaquinaria;
  final String marca;
  final int stockDisponible;
  final int stockMinimo;
  final String? urlFoto;

  const RepuestoEntity({
    required this.codParte,
    required this.nombre,
    required this.descripcion,
    required this.familiaMaquinaria,
    required this.marca,
    required this.stockDisponible,
    this.stockMinimo = 0,
    this.urlFoto,
  });
}
/// [RF09, RF12] Entidad de dominio para repuestos del catálogo
class RepuestoEntity {
  final String codParte;
  final String nombre;
  final String descripcion;
  final String familiaMaquinaria;
  final String marca;
  final int stockDisponible;
  final String? urlFoto;

  const RepuestoEntity({
    required this.codParte,
    required this.nombre,
    required this.descripcion,
    required this.familiaMaquinaria,
    required this.marca,
    required this.stockDisponible,
    this.urlFoto,
  });
}
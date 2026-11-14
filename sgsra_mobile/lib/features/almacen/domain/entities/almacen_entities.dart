class DashboardStockEntity {
  final int totalDisponibles;
  final int totalPrestadas;
  final int totalEnMora;
  final int totalEnMantenimiento;
  final int totalExtraviadas;

  const DashboardStockEntity({
    required this.totalDisponibles,
    required this.totalPrestadas,
    required this.totalEnMora,
    required this.totalEnMantenimiento,
    required this.totalExtraviadas,
  });
}

class HerramientaEntity {
  final String codHerramienta;
  final String nombre;
  final String marca;
  final String categoria;
  final String estadoActual; // DISPONIBLE, PRESTADA, EN_MANTENIMIENTO, EXTRAVIADA
  /// GEN-01: ruta de la foto en el backend (/uploads/...)
  final String? imagenUrl;

  const HerramientaEntity({
    required this.codHerramienta,
    required this.nombre,
    required this.marca,
    required this.categoria,
    required this.estadoActual,
    this.imagenUrl,
  });

  bool get disponible => estadoActual.toUpperCase() == 'DISPONIBLE';
}

class PrestamoEntity {
  final String prestamoNum;
  final String dniMecanico;
  final String nombreMecanico;
  final String estadoPrestamo; // ACTIVO, DEVUELTO, EN_MORA
  final String fechaPrestamo;
  final String horaSalida;
  final List<String> herramientas;
  /// [PRE-01] JSON completo del préstamo (incluye datos de entrega y devolución)
  final Map<String, dynamic> raw;

  const PrestamoEntity({
    required this.prestamoNum,
    required this.dniMecanico,
    required this.nombreMecanico,
    required this.estadoPrestamo,
    required this.fechaPrestamo,
    required this.horaSalida,
    required this.herramientas,
    this.raw = const {},
  });
}
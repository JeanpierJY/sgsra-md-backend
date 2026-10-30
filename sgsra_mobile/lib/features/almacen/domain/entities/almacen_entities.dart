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

  const HerramientaEntity({
    required this.codHerramienta,
    required this.nombre,
    required this.marca,
    required this.categoria,
    required this.estadoActual,
  });
}

class PrestamoEntity {
  final String prestamoNum;
  final String dniMecanico;
  final String nombreMecanico;
  final String estadoPrestamo; // ACTIVO, DEVUELTO, EN_MORA
  final String fechaPrestamo;
  final String horaSalida;
  final List<String> herramientas;

  const PrestamoEntity({
    required this.prestamoNum,
    required this.dniMecanico,
    required this.nombreMecanico,
    required this.estadoPrestamo,
    required this.fechaPrestamo,
    required this.horaSalida,
    required this.herramientas,
  });
}
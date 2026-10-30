import '../../domain/entities/almacen_entities.dart';

class DashboardStockModel extends DashboardStockEntity {
  const DashboardStockModel({
    required int totalDisponibles,
    required int totalPrestadas,
    required int totalEnMora,
    required int totalEnMantenimiento,
    required int totalExtraviadas,
  }) : super(
          totalDisponibles: totalDisponibles,
          totalPrestadas: totalPrestadas,
          totalEnMora: totalEnMora,
          totalEnMantenimiento: totalEnMantenimiento,
          totalExtraviadas: totalExtraviadas,
        );

  factory DashboardStockModel.fromJson(Map<String, dynamic> json) {
    return DashboardStockModel(
      totalDisponibles: (json['totalDisponibles'] as num?)?.toInt() ?? 0,
      totalPrestadas: (json['totalPrestadas'] as num?)?.toInt() ?? 0,
      totalEnMora: (json['totalEnMora'] as num?)?.toInt() ?? 0,
      totalEnMantenimiento: (json['totalEnMantenimiento'] as num?)?.toInt() ?? 0,
      totalExtraviadas: (json['totalExtraviadas'] as num?)?.toInt() ?? 0,
    );
  }
}

class HerramientaModel extends HerramientaEntity {
  const HerramientaModel({
    required String codHerramienta,
    required String nombre,
    required String marca,
    required String categoria,
    required String estadoActual,
  }) : super(
          codHerramienta: codHerramienta,
          nombre: nombre,
          marca: marca,
          categoria: categoria,
          estadoActual: estadoActual,
        );

  factory HerramientaModel.fromJson(Map<String, dynamic> json) {
    return HerramientaModel(
      codHerramienta: json['codHerramienta']?.toString() ?? '',
      nombre: json['nombreHerramienta']?.toString() ?? json['nombre']?.toString() ?? '',
      marca: json['marcaHerramienta']?.toString() ?? json['marca']?.toString() ?? 'Generica',
      categoria: json['categoria']?.toString() ?? 'MANUALES',
      estadoActual: json['estadoActual']?.toString() ?? 'DISPONIBLE',
    );
  }
}

class PrestamoModel extends PrestamoEntity {
  const PrestamoModel({
    required String prestamoNum,
    required String dniMecanico,
    required String nombreMecanico,
    required String estadoPrestamo,
    required String fechaPrestamo,
    required String horaSalida,
    required List<String> herramientas,
  }) : super(
          prestamoNum: prestamoNum,
          dniMecanico: dniMecanico,
          nombreMecanico: nombreMecanico,
          estadoPrestamo: estadoPrestamo,
          fechaPrestamo: fechaPrestamo,
          horaSalida: horaSalida,
          herramientas: herramientas,
        );

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    List<String> items = [];
    if (json['herramientas'] is List) {
      for (final h in json['herramientas']) {
        if (h is Map) {
          final cod = h['codHerramienta']?.toString();
          if (cod != null && cod.isNotEmpty) items.add(cod);
        } else if (h != null) {
          items.add(h.toString());
        }
      }
    }

    return PrestamoModel(
      prestamoNum: json['prestamoNum']?.toString() ?? '',
      dniMecanico: json['dniMecanico']?.toString() ?? '',
      nombreMecanico: json['nombreMecanico']?.toString() ?? 'Mecanico Operativo',
      estadoPrestamo: json['estadoPrestamo']?.toString() ?? 'ACTIVO',
      fechaPrestamo: json['fechaPrestamo']?.toString() ?? '',
      horaSalida: json['horaSalida']?.toString() ?? '',
      herramientas: items,
    );
  }
}
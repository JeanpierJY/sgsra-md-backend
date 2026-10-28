class DashboardMetricasModel {
  final int totalDisponibles;
  final int totalPrestadas;
  final int totalEnMora;
  final int totalEnMantenimiento;
  final int totalExtraviadas;

  DashboardMetricasModel({
    required this.totalDisponibles,
    required this.totalPrestadas,
    required this.totalEnMora,
    required this.totalEnMantenimiento,
    required this.totalExtraviadas,
  });

  factory DashboardMetricasModel.fromJson(Map<String, dynamic> json) {
    return DashboardMetricasModel(
      totalDisponibles: json['totalDisponibles'] as int? ?? 0,
      totalPrestadas: json['totalPrestadas'] as int? ?? 0,
      totalEnMora: json['totalEnMora'] as int? ?? 0,
      totalEnMantenimiento: json['totalEnMantenimiento'] as int? ?? 0,
      totalExtraviadas: json['totalExtraviadas'] as int? ?? 0,
    );
  }
}
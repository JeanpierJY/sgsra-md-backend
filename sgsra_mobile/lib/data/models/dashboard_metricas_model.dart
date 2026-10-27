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
      totalDisponibles: json['totalDisponibles'] ?? 0,
      totalPrestadas: json['totalPrestadas'] ?? 0,
      totalEnMora: json['totalEnMora'] ?? 0,
      totalEnMantenimiento: json['totalEnMantenimiento'] ?? 0,
      totalExtraviadas: json['totalExtraviadas'] ?? 0,
    );
  }
}

abstract class InventarioState {}

class InventarioInitial extends InventarioState {}

class InventarioLoading extends InventarioState {}

class DashboardLoaded extends InventarioState {
  final Map<String, dynamic> metricas;
  DashboardLoaded({required this.metricas});
}

class HerramientaEscaneadaSuccess extends InventarioState {
  final Map<String, dynamic> herramienta;
  HerramientaEscaneadaSuccess({required this.herramienta});
}

class PrestamoRegistradoSuccess extends InventarioState {
  final String mensaje;
  PrestamoRegistradoSuccess({required this.mensaje});
}

class InventarioFailure extends InventarioState {
  final String error;
  InventarioFailure(this.error);
}
import '../../../data/models/dashboard_metricas_model.dart';

abstract class InventarioState {}

class InventarioInitial extends InventarioState {}
class InventarioLoading extends InventarioState {}

class DashboardLoaded extends InventarioState {
  final DashboardMetricasModel metricas;
  DashboardLoaded(this.metricas);
}

class InventarioFailure extends InventarioState {
  final String error;
  InventarioFailure(this.error);
}
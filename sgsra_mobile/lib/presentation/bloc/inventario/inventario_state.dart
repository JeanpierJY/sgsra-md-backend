import '../../../data/models/dashboard_metricas_model.dart';
import '../../../data/models/herramienta_model.dart';

abstract class InventarioState {}
class InventarioInitial extends InventarioState {}
class InventarioLoading extends InventarioState {}
class DashboardMetricasLoaded extends InventarioState { final DashboardMetricasModel metricas; DashboardMetricasLoaded(this.metricas); }
class HerramientaEscaneadaLoaded extends InventarioState { final HerramientaModel herramienta; HerramientaEscaneadaLoaded(this.herramienta); }
class TransaccionSuccess extends InventarioState { final String msg; TransaccionSuccess(this.msg); }
class InventarioFailure extends InventarioState { final String error; InventarioFailure(this.error); }

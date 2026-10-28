import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/dashboard_metricas_model.dart';
import '../../../data/services/api_service.dart';
import 'inventario_event.dart';
import 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final ApiService _apiService = ApiService();

  InventarioBloc() : super(InventarioInitial()) {
    on<FetchDashboardRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final res = await _apiService.obtenerMetricasDashboard();
        final metricas = DashboardMetricasModel.fromJson(res.data as Map<String, dynamic>);
        emit(DashboardLoaded(metricas));
      } catch (e) {
        emit(InventarioFailure("Error al consultar stock del panol"));
      }
    });
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/almacen_entities.dart';
import '../../domain/usecases/almacen_usecases.dart';

abstract class AlmacenEvent {}
class CargarDashboardEvent extends AlmacenEvent {}
class CargarHerramientasEvent extends AlmacenEvent {
  final String? categoria;
  CargarHerramientasEvent({this.categoria});
}

abstract class AlmacenState {}
class AlmacenInitial extends AlmacenState {}
class AlmacenLoading extends AlmacenState {}
class DashboardLoaded extends AlmacenState {
  final DashboardStockEntity dashboard;
  DashboardLoaded(this.dashboard);
}
class HerramientasLoaded extends AlmacenState {
  final List<HerramientaEntity> herramientas;
  HerramientasLoaded(this.herramientas);
}
class AlmacenError extends AlmacenState {
  final String message;
  AlmacenError(this.message);
}

class AlmacenBloc extends Bloc<AlmacenEvent, AlmacenState> {
  final ObtenerDashboardUseCase obtenerDashboardUseCase;
  final ListarHerramientasUseCase listarHerramientasUseCase;

  AlmacenBloc({
    required this.obtenerDashboardUseCase,
    required this.listarHerramientasUseCase,
  }) : super(AlmacenInitial()) {
    on<CargarDashboardEvent>((event, emit) async {
      emit(AlmacenLoading());
      try {
        final d = await obtenerDashboardUseCase();
        emit(DashboardLoaded(d));
      } catch (e) {
        emit(AlmacenError('Error al cargar métricas de pañol: $e'));
      }
    });

    on<CargarHerramientasEvent>((event, emit) async {
      emit(AlmacenLoading());
      try {
        final list = await listarHerramientasUseCase(categoria: event.categoria);
        emit(HerramientasLoaded(list));
      } catch (e) {
        emit(AlmacenError('Error al listar herramientas: $e'));
      }
    });
  }
}
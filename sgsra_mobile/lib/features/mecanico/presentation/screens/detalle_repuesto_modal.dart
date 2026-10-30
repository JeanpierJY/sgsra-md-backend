import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/repuesto_entity.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../domain/usecases/repuesto_usecases.dart';

abstract class MecanicoEvent {}
class CargarCatalogoEvent extends MecanicoEvent {
  final String? buscar;
  CargarCatalogoEvent({this.buscar});
}
class CargarHistorialEvent extends MecanicoEvent {}
class EnviarPedidoEvent extends MecanicoEvent {
  final SolicitudEntity solicitud;
  EnviarPedidoEvent(this.solicitud);
}

abstract class MecanicoState {}
class MecanicoInitial extends MecanicoState {}
class MecanicoLoading extends MecanicoState {}
class CatalogoLoaded extends MecanicoState {
  final List<RepuestoEntity> repuestos;
  CatalogoLoaded(this.repuestos);
}
class HistorialLoaded extends MecanicoState {
  final List<SolicitudEntity> historial;
  HistorialLoaded(this.historial);
}
class PedidoExitoso extends MecanicoState {
  final String correlativo;
  PedidoExitoso(this.correlativo);
}
class MecanicoError extends MecanicoState {
  final String message;
  MecanicoError(this.message);
}

class MecanicoBloc extends Bloc<MecanicoEvent, MecanicoState> {
  final ObtenerCatalogoUseCase obtenerCatalogoUseCase;
  final EnviarSolicitudUseCase enviarSolicitudUseCase;
  final ObtenerHistorialMecanicoUseCase obtenerHistorialUseCase;

  MecanicoBloc({
    required this.obtenerCatalogoUseCase,
    required this.enviarSolicitudUseCase,
    required this.obtenerHistorialUseCase,
  }) : super(MecanicoInitial()) {
    on<CargarCatalogoEvent>((event, emit) async {
      emit(MecanicoLoading());
      try {
        final res = await obtenerCatalogoUseCase(buscar: event.buscar);
        emit(CatalogoLoaded(res));
      } catch (e) {
        emit(MecanicoError('Error al cargar catalogo: $e'));
      }
    });

    on<CargarHistorialEvent>((event, emit) async {
      emit(MecanicoLoading());
      try {
        final hist = await obtenerHistorialUseCase();
        emit(HistorialLoaded(hist));
      } catch (e) {
        emit(MecanicoError('Error al cargar historial: $e'));
      }
    });

    on<EnviarPedidoEvent>((event, emit) async {
      emit(MecanicoLoading());
      try {
        final cod = await enviarSolicitudUseCase(event.solicitud);
        emit(PedidoExitoso(cod));
      } catch (e) {
        emit(MecanicoError('Error al transmitir requerimiento: $e'));
      }
    });
  }
}
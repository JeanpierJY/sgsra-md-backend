import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/usecases/admin_usecases.dart';

abstract class AdminEvent {}
class LoadBandejaEvent extends AdminEvent {}
class AprobarSolicitudEvent extends AdminEvent {
  final String id;
  AprobarSolicitudEvent(this.id);
}
class RechazarSolicitudEvent extends AdminEvent {
  final String id;
  final String motivo;
  RechazarSolicitudEvent(this.id, this.motivo);
}

abstract class AdminState {}
class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminLoaded extends AdminState {
  final List<SolicitudBandejaEntity> solicitudes;
  AdminLoaded(this.solicitudes);
}
class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final ObtenerBandejaUseCase obtenerBandejaUseCase;
  final EvaluarSolicitudUseCase evaluarSolicitudUseCase;

  AdminBloc({required this.obtenerBandejaUseCase, required this.evaluarSolicitudUseCase}) : super(AdminInitial()) {
    on<LoadBandejaEvent>((event, emit) async {
      emit(AdminLoading());
      try {
        final lista = await obtenerBandejaUseCase();
        emit(AdminLoaded(lista));
      } catch (e) {
        emit(AdminError('Error al cargar la bandeja: $e'));
      }
    });

    on<AprobarSolicitudEvent>((event, emit) async {
      try {
        await evaluarSolicitudUseCase.aprobar(event.id);
        add(LoadBandejaEvent());
      } catch (e) {
        emit(AdminError('Error al aprobar solicitud: $e'));
      }
    });

    on<RechazarSolicitudEvent>((event, emit) async {
      try {
        await evaluarSolicitudUseCase.rechazar(event.id, event.motivo);
        add(LoadBandejaEvent());
      } catch (e) {
        emit(AdminError('Error al rechazar solicitud: $e'));
      }
    });
  }
}
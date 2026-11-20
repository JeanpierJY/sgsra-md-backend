import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/notificacion_remote_datasource.dart';
import '../../domain/entities/notificacion_entity.dart';

abstract class NotificacionEvent {}
class CargarNotificaciones extends NotificacionEvent {}
class MarcarNotificacionLeida extends NotificacionEvent {
  final int id;
  MarcarNotificacionLeida(this.id);
}
class MarcarTodasLeidas extends NotificacionEvent {}

class NotificacionState {
  final bool cargando;
  final List<NotificacionEntity> items;
  final String? error;

  const NotificacionState({this.cargando = false, this.items = const [], this.error});

  List<NotificacionEntity> get noLeidas => items.where((n) => !n.leida).toList();
  List<NotificacionEntity> get leidas => items.where((n) => n.leida).toList();

  NotificacionState copyWith({bool? cargando, List<NotificacionEntity>? items, String? error}) =>
      NotificacionState(cargando: cargando ?? this.cargando, items: items ?? this.items, error: error);
}

/// [RF50] Estado del Centro de Notificaciones del usuario autenticado
class NotificacionBloc extends Bloc<NotificacionEvent, NotificacionState> {
  final NotificacionRemoteDataSource datasource;
  final String dni;

  NotificacionBloc({required this.datasource, required this.dni}) : super(const NotificacionState(cargando: true)) {
    on<CargarNotificaciones>((event, emit) async {
      emit(state.copyWith(cargando: true));
      try {
        final items = await datasource.listar(dni);
        emit(NotificacionState(items: items));
      } catch (e) {
        emit(state.copyWith(cargando: false, error: mensajeDeError(e)));
      }
    });

    on<MarcarNotificacionLeida>((event, emit) async {
      // Actualización optimista: la UI responde al instante
      emit(state.copyWith(items: state.items.map((n) => n.id == event.id ? n.marcarLeida() : n).toList()));
      try {
        await datasource.marcarLeida(event.id);
      } catch (e) {
        add(CargarNotificaciones());
      }
    });

    on<MarcarTodasLeidas>((event, emit) async {
      emit(state.copyWith(items: state.items.map((n) => n.marcarLeida()).toList()));
      try {
        await datasource.marcarTodasLeidas(dni);
      } catch (e) {
        add(CargarNotificaciones());
      }
    });
  }
}

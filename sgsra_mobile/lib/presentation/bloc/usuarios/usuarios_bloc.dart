import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/api_service.dart';
import 'usuarios_event.dart';
import 'usuarios_state.dart';

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final ApiService _apiService = ApiService();

  UsuariosBloc() : super(UsuariosInitial()) {
    on<FetchUsuariosRequested>((event, emit) async {
      emit(UsuariosLoading());
      try {
        final res = await _apiService.listarUsuariosBackend();
        final rawList = res.data is List ? res.data as List : [];
        final list = rawList.map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>)).toList();
        emit(UsuariosLoaded(list));
      } catch (e) {
        emit(UsuariosFailure("Error al recuperar lista de usuarios"));
      }
    });

    on<CreateUsuarioRequested>((event, emit) async {
      emit(UsuariosLoading());
      try {
        final Map<String, dynamic> payload = event.usuario.toJson();
        payload['contrasena'] = 'Admin123*';
        await _apiService.crearUsuarioBackend(payload);
        emit(UsuariosActionSuccess("Usuario registrado exitosamente"));
        add(FetchUsuariosRequested());
      } catch (e) {
        emit(UsuariosFailure("Error: DNI o correo ya registrados"));
        add(FetchUsuariosRequested());
      }
    });

    on<ToggleEstadoUsuarioRequested>((event, emit) async {
      try {
        await _apiService.cambiarEstadoCuentaBackend(event.idUsuario, event.nuevoEstado);
        add(FetchUsuariosRequested());
      } catch (e) {
        emit(UsuariosFailure("No se pudo cambiar el estado de la cuenta"));
      }
    });
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/usuario_model.dart';
import 'usuarios_event.dart';
import 'usuarios_state.dart';

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final ApiService apiService = ApiService();

  UsuariosBloc() : super(UsuariosInitial()) {
    on<FetchUsuariosRequested>((event, emit) async {
      emit(UsuariosLoading());
      try {
        final response = await apiService.listarUsuariosBackend();
        final List<dynamic> content = response.data['content'] ?? [];
        final List<UsuarioModel> usuarios = content.map((json) => UsuarioModel.fromJson(json)).toList();
        emit(UsuariosLoaded(usuarios));
      } catch (e) {
        emit(UsuariosFailure("Fallo al sincronizar nómina de trabajadores del backend."));
      }
    });

    on<CreateUsuarioRequested>((event, emit) async {
      emit(UsuariosLoading());
      try {
        await apiService.crearUsuarioBackend(event.usuario.toJson());
        emit(UsuariosActionSuccess("Operario dado de alta formalmente en los servidores de Master Drilling."));
        add(FetchUsuariosRequested());
      } catch (e) {
        emit(UsuariosFailure("Error en los parámetros de validación del DNI o correo duplicado."));
      }
    });

    on<ToggleEstadoUsuarioRequested>((event, emit) async {
      emit(UsuariosLoading());
      try {
        await apiService.cambiarEstadoCuentaBackend(event.idUsuario, event.nuevoEstado);
        emit(UsuariosActionSuccess("Estado de cuenta modificado de forma segura."));
        add(FetchUsuariosRequested());
      } catch (e) {
        emit(UsuariosFailure("No se pudo mutar el ciclo de vida de la cuenta."));
      }
    });
  }
}

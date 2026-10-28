import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final res = await _apiService.login(event.correo, event.contrasena);
        final data = res.data;
        final token = data['tokenJwt'] as String? ?? '';
        final rol = data['rol'] as String? ?? '';
        final nombre = data['nombre'] as String? ?? '';

        await _storage.write(key: "token_jwt", value: token);
        await _storage.write(key: "user_rol", value: rol);
        await _storage.write(key: "user_nombre", value: nombre);

        emit(AuthSuccess(token: token, rol: rol, nombre: nombre));
      } catch (e) {
        emit(AuthFailure("Credenciales invalidas o error de conexion"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _storage.deleteAll();
      emit(AuthInitial());
    });
  }
}
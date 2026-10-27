import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  AuthBloc() : super(AuthInitial()) {
    on<AuthenticationSubmitRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await apiService.login(event.email, event.password);
        final data = response.data;
        
        await _secureStorage.write(key: "token_jwt", value: data['tokenJwt']);
        await _secureStorage.write(key: "correo_corporativo", value: data['correoCorporativo']);
        await _secureStorage.write(key: "rol_usuario", value: data['rol']);

        emit(Authenticated(role: data['role'] ?? data['rol'], email: data['correoCorporativo']));
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 423) {
          emit(AuthAccountLocked("Cuenta bloqueada temporalmente tras 3 intentos fallidos (RF06)."));
        } else {
          emit(AuthFailure("Credenciales corporativas inválidas o error de red."));
        }
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _secureStorage.deleteAll();
      emit(AuthInitial());
    });
  }
}


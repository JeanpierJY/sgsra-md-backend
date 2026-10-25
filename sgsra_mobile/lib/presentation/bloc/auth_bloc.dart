import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String role;
  final String token;
  Authenticated(this.role, this.token);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthAccountLocked extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final _storage = const FlutterSecureStorage();
  int _failedAttempts = 0;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      if (_failedAttempts >= 3) {
        emit(AuthAccountLocked()); // RF06: Bloqueo tras 3 intentos fallidos
        return;
      }

      emit(AuthLoading());

      if (event.email.isEmpty || !event.email.contains('@') || event.password.isEmpty) {
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          emit(AuthAccountLocked());
        } else {
          emit(AuthError("Formato de credenciales inválido. Intente nuevamente."));
        }
        return;
      }

      try {
        // Simulación para pruebas de flujo de roles (RF02)
        String mockRole = "MECANICO"; // Valores posibles: MECANICO, ADMINISTRADOR, ALMACENISTA
        String mockToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_token";

        await _storage.write(key: "auth_token", value: mockToken); // RNF41: KeyStore seguro
        await _storage.write(key: "user_role", value: mockRole);
        
        _failedAttempts = 0;
        emit(Authenticated(mockRole, mockToken));
      } catch (e) {
        _failedAttempts++;
        if (_failedAttempts >= 3) {
          emit(AuthAccountLocked());
        } else {
          emit(AuthError("Error crítico de comunicación con el servidor."));
        }
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await _storage.delete(key: "auth_token"); // RF03: Cierre de sesión seguro
      await _storage.delete(key: "user_role");
      emit(AuthInitial());
    });
  }
}

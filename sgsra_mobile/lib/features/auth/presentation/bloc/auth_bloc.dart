import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// Eventos
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String correo;
  final String password;
  AuthLoginRequested(this.correo, this.password);
}
class AuthLogoutRequested extends AuthEvent {}

// Estados
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
class AuthLockedOut extends AuthState {
  final String message;
  AuthLockedOut(this.message);
}

/// [RF01, RF06] BLoC para gestionar los estados de autenticación y bloqueos
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;
  int _intentosFallidos = 0;

  AuthBloc({required this.loginUseCase, required this.cerrarSesionUseCase}) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.correo, event.password);
        _intentosFallidos = 0;
        emit(AuthAuthenticated(user));
      } catch (e) {
        _intentosFallidos++;
        if (_intentosFallidos >= 3) {
          emit(AuthLockedOut('Cuenta bloqueada temporalmente por 3 intentos fallidos. [RF06]'));
        } else {
          emit(AuthError('Credenciales incorrectas. Intento $_intentosFallidos de 3.'));
        }
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await cerrarSesionUseCase();
      emit(AuthInitial());
    });
  }
}
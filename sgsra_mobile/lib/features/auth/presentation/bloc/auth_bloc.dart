import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String correo;
  final String password;
  AuthLoginRequested(this.correo, this.password);
}
class AuthLogoutRequested extends AuthEvent {}
/// Se dispara cuando termina la cuenta regresiva del bloqueo temporal
class AuthBloqueoExpirado extends AuthEvent {}

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
/// [RF04] Bloqueo escalonado: 3 fallos = 5 min, 6 fallos = 10 min, 9 fallos = bloqueo total
class AuthLockedOut extends AuthState {
  final String message;
  final DateTime? desbloqueoEn; // null cuando el bloqueo es total
  final bool permanente;
  AuthLockedOut(this.message, {this.desbloqueoEn, this.permanente = false});
}

/// [RF01, RF04, RF06] BLoC de autenticación. Los intentos y bloqueos los controla el
/// backend (por usuario), así el bloqueo se respeta aunque se reinstale la app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CerrarSesionUseCase cerrarSesionUseCase;

  AuthBloc({required this.loginUseCase, required this.cerrarSesionUseCase}) : super(AuthInitial()) {
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.correo, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        final bloqueo = _extraerBloqueo(e);
        if (bloqueo != null) {
          emit(AuthLockedOut(
            bloqueo.message,
            permanente: bloqueo.bloqueoPermanente,
            desbloqueoEn: bloqueo.bloqueoPermanente
                ? null
                : DateTime.now().add(Duration(seconds: bloqueo.segundosRestantes)),
          ));
        } else {
          emit(AuthError(mensajeDeError(e)));
        }
      }
    });

    on<AuthBloqueoExpirado>((event, emit) => emit(AuthInitial()));

    on<AuthLogoutRequested>((event, emit) async {
      await cerrarSesionUseCase();
      emit(AuthInitial());
    });
  }

  CuentaBloqueadaException? _extraerBloqueo(Object e) {
    if (e is CuentaBloqueadaException) return e;
    if (e is DioException && e.error is CuentaBloqueadaException) {
      return e.error as CuentaBloqueadaException;
    }
    return null;
  }
}

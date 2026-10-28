abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final String rol;
  final String nombre;
  AuthSuccess({required this.token, required this.rol, required this.nombre});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}
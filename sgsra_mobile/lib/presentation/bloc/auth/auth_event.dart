abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String correo;
  final String contrasena;
  LoginRequested(this.correo, this.contrasena);
}

class LogoutRequested extends AuthEvent {}
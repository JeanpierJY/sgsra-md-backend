abstract class AuthEvent {}
class AuthenticationSubmitRequested extends AuthEvent {
  final String email;
  final String password;
  AuthenticationSubmitRequested({required this.email, required this.password});
}
class LogoutRequested extends AuthEvent {}

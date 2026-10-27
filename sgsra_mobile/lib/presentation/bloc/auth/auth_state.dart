abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String role;
  final String email;
  Authenticated({required this.role, required this.email});
}
class AuthFailure extends AuthState { final String error; AuthFailure(this.error); }
class AuthAccountLocked extends AuthState { final String msg; AuthAccountLocked(this.msg); }

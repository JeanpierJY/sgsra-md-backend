import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<UserEntity> call(String correo, String password) => repository.login(correo, password);
}

class CerrarSesionUseCase {
  final AuthRepository repository;
  CerrarSesionUseCase(this.repository);
  Future<void> call() => repository.cerrarSesion();
}
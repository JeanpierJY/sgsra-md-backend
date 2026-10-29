import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<UserEntity> call(String correo, String password) => repository.login(correo, password);
}

class RecuperarClaveUseCase {
  final AuthRepository repository;
  RecuperarClaveUseCase(this.repository);
  Future<void> call(String correo) => repository.recuperarClave(correo);
}

class ActualizarPerfilUseCase {
  final AuthRepository repository;
  ActualizarPerfilUseCase(this.repository);
  Future<void> call(String dni, String telefono) => repository.actualizarPerfil(dni, telefono);
}

class CerrarSesionUseCase {
  final AuthRepository repository;
  CerrarSesionUseCase(this.repository);
  Future<void> call() => repository.cerrarSesion();
}
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String correo, String password);
  Future<void> recuperarClave(String correo);
  Future<void> actualizarPerfil(String dni, String telefono);
  Future<void> cerrarSesion();
}
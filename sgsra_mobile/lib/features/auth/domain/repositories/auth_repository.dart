import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación para la capa de dominio
abstract class AuthRepository {
  Future<UserEntity> login(String correo, String password);
  Future<void> recuperarClave(String correo);
  Future<void> actualizarPerfil(String dni, String telefono);
  Future<void> cerrarSesion();
}
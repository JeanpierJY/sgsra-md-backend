import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación concreta del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String correo, String password) async {
    final response = await remoteDataSource.login(correo, password);
    await localDataSource.guardarToken(response.token);
    return response;
  }

  @override
  Future<void> recuperarClave(String correo) async {
    await remoteDataSource.recuperarClave(correo);
  }

  @override
  Future<void> actualizarPerfil(String dni, String telefono) async {
    await remoteDataSource.actualizarPerfil(dni, telefono);
  }

  @override
  Future<void> cerrarSesion() async {
    await localDataSource.eliminarSesion();
  }
}
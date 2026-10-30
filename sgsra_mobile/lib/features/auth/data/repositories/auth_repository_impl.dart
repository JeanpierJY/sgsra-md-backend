import 'package:sgsra_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:sgsra_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sgsra_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sgsra_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String correo, String password) async {
    // Sincronizado con los parámetros corregidos en AuthRemoteDataSource
    final response = await remoteDataSource.login(correo, password);
    await localDataSource.guardarToken(response.token);
    return response;
  }

  @override
  Future<void> recuperarClave(String correo) async {
    await remoteDataSource.recuperarClave(correo);
  }

  @override
  Future<void> actualizarPerfil(String correo, String nombre, [String telefono = '']) async {
    await remoteDataSource.actualizarPerfil(correo, nombre, telefono);
  }

  @override
  Future<void> cerrarSesion() async {
    await localDataSource.eliminarSesion();
  }
}
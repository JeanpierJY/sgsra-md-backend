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
    final response = await remoteDataSource.login(correo, password);
    // Persistimos token + datos del usuario (antes solo se guardaba el token y los
    // perfiles mostraban datos fijos de ejemplo)
    await localDataSource.guardarSesion(response);
    return response;
  }

  @override
  Future<void> cerrarSesion() async {
    await localDataSource.eliminarSesion();
  }
}

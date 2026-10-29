import '../../../../core/network/dio_client.dart';
import '../models/login_response_model.dart';

/// [RF01, RF04, RF07] Datasource remoto para llamadas HTTP al Backend de Autenticación
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<LoginResponseModel> login(String correo, String password) async {
    final response = await _dioClient.dio.post('/auth/login', data: {
      'correo': correo,
      'password': password,
    });
    return LoginResponseModel.fromJson(response.data);
  }

  Future<void> recuperarClave(String correo) async {
    await _dioClient.dio.post('/auth/recuperar-clave', data: {'correo': correo});
  }

  Future<void> actualizarPerfil(String dni, String telefono) async {
    await _dioClient.dio.put('/auth/perfil', data: {
      'dni': dni,
      'telefono': telefono,
    });
  }
}
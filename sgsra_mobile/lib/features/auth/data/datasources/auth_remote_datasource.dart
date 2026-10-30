import '../../../../core/network/dio_client.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<LoginResponseModel> login(String correo, String password) async {
    final response = await _dioClient.dio.post('/auth/login', data: {
      'correoCorporativo': correo.trim(), // Sincronizado con LoginRequest.java
      'contrasena': password.trim(),      // Sincronizado con LoginRequest.java
    });
    return LoginResponseModel.fromJson(response.data);
  }

  Future<void> recuperarClave(String correo) async {
    await _dioClient.dio.post('/auth/recuperar-clave', queryParameters: {'correo': correo});
  }

  Future<void> actualizarPerfil(String correo, String nombre, String telefono) async {
    await _dioClient.dio.put('/auth/perfil', queryParameters: {'correo': correo}, data: {
      'nombre': nombre,
      'telefono': telefono,
    });
  }
}
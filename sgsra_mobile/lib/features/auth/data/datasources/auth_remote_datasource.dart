import 'package:dio/dio.dart';
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

  /// [RF06, REQ-02] Solicitud de recuperación validada con DNI + teléfono y selfie de evidencia.
  /// Devuelve el mensaje del backend (incluye el número de solicitud).
  Future<String> solicitarRecuperacion({
    required String dni,
    required String telefono,
    String? motivo,
    List<int>? selfieBytes,
    String selfieNombre = 'selfie.jpg',
  }) async {
    final form = FormData.fromMap({
      'dni': dni.trim(),
      'telefono': telefono.trim(),
      if (motivo != null && motivo.trim().isNotEmpty) 'motivo': motivo.trim(),
      if (selfieBytes != null) 'fotoSelfie': MultipartFile.fromBytes(selfieBytes, filename: selfieNombre, contentType: DioMediaType('image', 'jpeg')),
    });
    final res = await _dioClient.dio.post(
      '/auth/recuperar-clave',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data;
    return data is Map && data['mensaje'] is String
        ? data['mensaje'] as String
        : 'Solicitud enviada a Administración.';
  }
}

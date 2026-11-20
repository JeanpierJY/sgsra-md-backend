import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// [RF01, RF02] Cliente HTTP configurado con Dio para interceptar cabeceras y JWT
class DioClient {
  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // [RF02] Adjuntar token JWT si existe en almacenamiento seguro
          String? token = await _secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 423) {
            // [RF04, RF06] Bloqueo escalonado: el backend informa los segundos restantes
            final data = e.response?.data;
            final mensaje = data is Map && data['mensaje'] is String
                ? data['mensaje'] as String
                : 'Cuenta bloqueada temporalmente por seguridad.';
            final segundos = data is Map ? (data['segundosRestantes'] as num?)?.toInt() ?? 0 : 0;
            final permanente = data is Map ? data['bloqueoPermanente'] == true : false;
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e.response,
                error: CuentaBloqueadaException(mensaje, segundos, permanente),
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api/v1',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  
  final _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: "token_jwt");
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> login(String correo, String contrasena) async {
    return await _dio.post('/auth/login', data: {
      'correoCorporativo': correo,
      'contrasena': contrasena,
    });
  }

  Future<Response> obtenerCatalogo() async {
    return await _dio.get('/catalogo');
  }

  Future<Response> buscarRepuestosPredictivo(String termino) async {
    return await _dio.get('/catalogo/buscar', queryParameters: {'termino': termino});
  }

  Future<Response> registrarSolicitud(String correoMecanico, Map<String, dynamic> payload) async {
    return await _dio.post('/solicitudes', data: payload, queryParameters: {'correoMecanico': correoMecanico});
  }

  Future<Response> obtenerMetricasDashboard() async {
    return await _dio.get('/inventario/dashboard');
  }

  Future<Response> consultarHerramientaPorCodigo(String codHerramienta) async {
    return await _dio.get('/inventario/herramientas/$codHerramienta');
  }

  Future<Response> registrarPrestamo(String correoAlmacenista, Map<String, dynamic> payload) async {
    return await _dio.post('/prestamos', data: payload, queryParameters: {'correoAlmacenista': correoAlmacenista});
  }

  Future<Response> listarUsuariosBackend() async {
    return await _dio.get('/auth/usuarios');
  }

  Future<Response> crearUsuarioBackend(Map<String, dynamic> usuarioJson) async {
    return await _dio.post('/auth/usuarios', data: usuarioJson);
  }

  Future<Response> cambiarEstadoCuentaBackend(int idUsuario, String nuevoEstado) async {
    return await _dio.put('/auth/usuarios/$idUsuario/estado', queryParameters: {'nuevoEstado': nuevoEstado});
  }
}
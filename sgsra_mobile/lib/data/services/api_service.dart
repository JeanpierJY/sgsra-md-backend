import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: "token_jwt");
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  // Auth (RF01, RF06)
  Future<Response> login(String correo, String contrasena) async {
    return await _dio.post('/auth/login', data: {
      'correoCorporativo': correo,
      'contrasena': contrasena,
    });
  }

  // Catálogo (RF09, RF10, RF32)
  Future<Response> obtenerCatalogo() async {
    return await _dio.get('/catalogo');
  }

  Future<Response> buscarRepuestosPredictivo(String termino) async {
    return await _dio.get('/catalogo/buscar', queryParameters: {'termino': termino});
  }

  // Solicitudes (RF17, RF19, RF21, RF23, RF24, RF28)
  Future<Response> registrarSolicitud(String correoMecanico, Map<String, dynamic> payload) async {
    return await _dio.post('/solicitudes', data: payload, queryParameters: {'correoMecanico': correoMecanico});
  }

  Future<Response> listarBandejaAdministrador() async {
    return await _dio.get('/solicitudes/bandeja');
  }

  Future<Response> listarHistorialMecanico(String correoMecanico) async {
    return await _dio.get('/solicitudes/mecanico', queryParameters: {'correoMecanico': correoMecanico});
  }

  Future<Response> aprobarSolicitudTotal(String solicitudNum, String correoAdmin) async {
    return await _dio.put('/solicitudes/$solicitudNum/aprobar', queryParameters: {'correoAdmin': correoAdmin});
  }

  Future<Response> rechazarSolicitudTotal(String solicitudNum, String correoAdmin, String justificacion) async {
    return await _dio.put('/solicitudes/$solicitudNum/rechazar',
        queryParameters: {'correoAdmin': correoAdmin},
        data: {'justificacionRechazo': justificacion});
  }

  // Inventario y Pañol (RF33, RF35, RF36, RF38)
  Future<Response> obtenerMetricasDashboard() async {
    return await _dio.get('/inventario/dashboard');
  }

  Future<Response> consultarHerramientaPorCodigo(String codHerramienta) async {
    return await _dio.get('/inventario/herramientas/$codHerramienta');
  }

  Future<Response> registrarPrestamo(String correoAlmacenista, Map<String, dynamic> payload) async {
    return await _dio.post('/prestamos', data: payload, queryParameters: {'correoAlmacenista': correoAlmacenista});
  }

  Future<Response> registrarDevolucion(String correoAlmacenista, Map<String, dynamic> payload) async {
    return await _dio.post('/prestamos/devolucion', data: payload, queryParameters: {'correoAlmacenista': correoAlmacenista});
  }

  // Gestión de Usuarios (RF07)
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
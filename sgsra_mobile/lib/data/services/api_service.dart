import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2', // URL adaptada para emulador local Android hacia localhost
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

  // Capa Autenticación (RF01)
  Future<Response> login(String correo, String contrasena) async {
    return await _dio.post('/auth/login', data: {
      'correoCorporativo': correo,
      'contrasena': contrasena,
    });
  }

  // Capa Catálogo (RF09, RF10)
  Future<Response> obtenerCatalogo() async {
    return await _dio.get('/catalogo');
  }

  Future<Response> buscarRepuestosPredictivo(String termino) async {
    return await _dio.get('/catalogo/buscar', queryParameters: {'termino': termino});
  }

  // Capa Solicitudes (RF17, RF21, RF23, RF24)
  Future<Response> registrarSolicitud(String correoMecanico, Map<String, dynamic> payload) async {
    return await _dio.post('/solicitudes', data: payload, queryParameters: {'correoMecanico': correoMecanico});
  }

  Future<Response> obtenerBandejaAdministrador(String? estado) async {
    final queryParams = estado != null ? {'estado': estado} : <String, dynamic>{};
    return await _dio.get('/solicitudes/bandeja', queryParameters: queryParams);
  }

  Future<Response> obtenerDetalleSolicitud(String solicitudNum) async {
    return await _dio.get('/solicitudes/$solicitudNum');
  }

  Future<Response> aprobarSolicitudTotal(String solicitudNum, String correoAdmin) async {
    return await _dio.put('/solicitudes/$solicitudNum/aprobar', queryParameters: {'correoAdmin': correoAdmin});
  }

  Future<Response> rechazarSolicitudTotal(String solicitudNum, String correoAdmin, String justificacion) async {
    return await _dio.put('/solicitudes/$solicitudNum/rechazar', 
      queryParameters: {'correoAdmin': correoAdmin},
      data: {'justificacionRechazo': justificacion}
    );
  }

  // Capa Inventario (RF33)
  Future<Response> obtenerMetricasDashboard() async {
    return await _dio.get('/inventario/dashboard');
  }

  Future<Response> consultarHerramientaPorCodigo(String codHerramienta) async {
    return await _dio.get('/inventario/herramientas/$codHerramienta');
  }

  // RF EXTRA: Gestión de Usuarios para el Administrador
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

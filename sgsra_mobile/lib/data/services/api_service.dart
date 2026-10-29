import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    return Platform.isAndroid ? 'http://10.0.2.2:8080/api/v1' : 'http://localhost:8080/api/v1';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: "token_jwt");
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  // --- AUTENTICACION Y SESION ---
  Future<Response> login(String correo, String contrasena) async {
    return await _dio.post('/auth/login', data: {
      'correoCorporativo': correo.trim(),
      'contrasena': contrasena.trim(),
    });
  }

  Future<void> guardarSesion(String token, String rol, String correo, String nombre, String dni) async {
    await _storage.write(key: "token_jwt", value: token);
    await _storage.write(key: "user_rol", value: rol);
    await _storage.write(key: "user_email", value: correo);
    await _storage.write(key: "user_name", value: nombre);
    await _storage.write(key: "user_dni", value: dni);
  }

  Future<Map<String, String?>> obtenerDatosUsuario() async {
    return {
      'token': await _storage.read(key: "token_jwt"),
      'rol': await _storage.read(key: "user_rol"),
      'email': await _storage.read(key: "user_email"),
      'name': await _storage.read(key: "user_name"),
      'dni': await _storage.read(key: "user_dni"),
    };
  }

  Future<void> cerrarSesion() async {
    await _storage.deleteAll();
  }

  // --- GESTION DE PERSONAL / USUARIOS ---
  Future<Response> listarUsuarios() async {
    return await _dio.get('/auth/usuarios');
  }

  Future<Response> crearUsuario(Map<String, dynamic> usuario) async {
    return await _dio.post('/auth/usuarios', data: usuario);
  }

  Future<Response> actualizarUsuario(int idUsuario, Map<String, dynamic> datos) async {
    return await _dio.put('/auth/usuarios/$idUsuario', data: datos);
  }

  Future<Response> cambiarEstadoUsuario(int idUsuario, String nuevoEstado) async {
    return await _dio.put('/auth/usuarios/$idUsuario/estado', queryParameters: {'nuevoEstado': nuevoEstado});
  }

  // Alias compatibles con UsuariosBloc
  Future<Response> listarUsuariosBackend() => listarUsuarios();
  Future<Response> crearUsuarioBackend(Map<String, dynamic> u) => crearUsuario(u);
  Future<Response> cambiarEstadoCuentaBackend(int id, String e) => cambiarEstadoUsuario(id, e);

  // --- CATALOGO DE REPUESTOS ---
  Future<Response> obtenerCatalogo() async {
    return await _dio.get('/catalogo');
  }

  Future<Response> buscarRepuestosPredictivo(String termino) async {
    return await _dio.get('/catalogo/buscar', queryParameters: {'termino': termino});
  }

  Future<Response> crearRepuestoCatalogo(Map<String, dynamic> repuesto) async {
    return await _dio.post('/catalogo', data: repuesto);
  }

  // --- SOLICITUDES DE REPUESTOS ---
  Future<Response> registrarSolicitud(String correoMecanico, Map<String, dynamic> payload) async {
    return await _dio.post(
      '/solicitudes',
      data: payload,
      queryParameters: {'correoMecanico': correoMecanico},
    );
  }

  Future<Response> listarBandejaAdministrador() async {
    return await _dio.get('/solicitudes/bandeja');
  }

  Future<Response> listarHistorialMecanico(String correoMecanico) async {
    return await _dio.get(
      '/solicitudes/mecanico',
      queryParameters: {'correoMecanico': correoMecanico},
    );
  }

  // Metodo requerido por detalle_solicitud_screen
  Future<Response> obtenerDetalleSolicitud(String solicitudNum) async {
    return await _dio.get('/solicitudes/detalle/$solicitudNum');
  }

  Future<Response> aprobarSolicitudTotal(String solicitudNum, String correoAdmin) async {
    return await _dio.put(
      '/solicitudes/$solicitudNum/aprobar',
      queryParameters: {'correoAdmin': correoAdmin},
    );
  }

  Future<Response> rechazarSolicitudTotal(String solicitudNum, String correoAdmin, String justificacion) async {
    return await _dio.put(
      '/solicitudes/$solicitudNum/rechazar',
      queryParameters: {'correoAdmin': correoAdmin},
      data: {'justificacionRechazo': justificacion},
    );
  }

  Future<Response> aprobarParcialSolicitud(String solicitudNum, String correoAdmin, Map<String, dynamic> payload) async {
    return await _dio.put(
      '/solicitudes/$solicitudNum/aprobar-parcial',
      queryParameters: {'correoAdmin': correoAdmin},
      data: payload,
    );
  }

  Future<Response> contactarProveedor(String solicitudNum, String correoAdmin, String codigoCotizacion) async {
    return await _dio.put(
      '/solicitudes/$solicitudNum/contactar',
      queryParameters: {'correoAdmin': correoAdmin, 'codigoCotizacion': codigoCotizacion},
    );
  }

  // --- CONTROL DE HERRAMIENTAS Y PANOL ---
  Future<Response> obtenerMetricasDashboard() async {
    return await _dio.get('/inventario/dashboard');
  }

  Future<Response> consultarHerramienta(String codHerramienta) async {
    return await _dio.get('/inventario/herramientas/$codHerramienta');
  }

  Future<Response> registrarPrestamo(String correoAlmacenista, Map<String, dynamic> payload) async {
    return await _dio.post(
      '/prestamos',
      data: payload,
      queryParameters: {'correoAlmacenista': correoAlmacenista},
    );
  }

  Future<Response> registrarDevolucion(String correoAlmacenista, Map<String, dynamic> payload) async {
    return await _dio.post(
      '/prestamos/devolucion',
      data: payload,
      queryParameters: {'correoAlmacenista': correoAlmacenista},
    );
  }

  // --- REPORTES Y AUDITORIA ---
  Future<Response> obtenerAuditoria() async {
    return await _dio.get('/auditoria');
  }

  Future<Response> obtenerEstadisticasDemanda(String periodo) async {
    return await _dio.get('/reportes/demanda', queryParameters: {'periodo': periodo});
  }

  Future<void> descargarArchivoNativo(String endpoint, String nombreArchivo) async {
    final response = await _dio.get(
      endpoint,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': '*/*'},
      ),
    );

    if (kIsWeb) {
      final blob = html.Blob([response.data]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", nombreArchivo)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<Response> descargarReporteExcel() async {
    return await _dio.get(
      '/reportes/exportar/excel',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': '*/*'},
      ),
    );
  }
}
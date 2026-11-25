import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../models/repuesto_model.dart';
import '../models/solicitud_request.dart';

class RepuestoRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RepuestoRemoteDataSource(this._dioClient);

  Future<String> obtenerCorreoMecanico() async {
    final c = await SessionManager.correo();
    if (c != null && c.isNotEmpty) return c;
    return await _storage.read(key: 'correo_usuario') ?? 'carlos.baro@masterdrilling.com';
  }

  Future<String> obtenerDniMecanico() async {
    final d = await SessionManager.dni();
    if (d != null && d.isNotEmpty) return d;
    return await _storage.read(key: 'dni_usuario') ?? '70000001';
  }

  Future<List<RepuestoModel>> listarCatalogo({int page = 0, int size = 500}) async {
    // [H-MEC-01] Catálogo completo (antes solo 20) incluyendo deshabilitados, que se listan al final
    final res = await _dioClient.dio.get('/catalogo',
        queryParameters: {'page': page, 'size': size, 'incluirInactivos': true});
    if (res.data is Map && res.data['content'] != null) {
      return (res.data['content'] as List).map((x) => RepuestoModel.fromJson(x)).toList();
    } else if (res.data is List) {
      return (res.data as List).map((x) => RepuestoModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<List<RepuestoModel>> buscarPredictivo(String texto) async {
    final res = await _dioClient.dio.get('/catalogo/buscar', queryParameters: {'termino': texto});
    if (res.data is List) {
      return (res.data as List).map((x) => RepuestoModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<RepuestoModel> obtenerDetalle(String codParte) async {
    final res = await _dioClient.dio.get('/catalogo/$codParte');
    return RepuestoModel.fromJson(res.data);
  }

  /// [MEC-05] Búsqueda predictiva de maquinaria por código, modelo o serie
  Future<List<Map<String, dynamic>>> buscarMaquinarias(String termino) async {
    final res = await _dioClient.dio.get('/maquinarias', queryParameters: {'termino': termino});
    if (res.data is! List) return [];
    return (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<String> registrarSolicitud(SolicitudCreacionDto dto) async {
    final correo = await obtenerCorreoMecanico();
    final res = await _dioClient.dio.post(
      '/solicitudes',
      queryParameters: {'correoMecanico': correo},
      data: dto.toJson(),
    );
    return res.data['dato']?.toString() ?? res.data['mensaje']?.toString() ?? 'SOL-OK';
  }

  Future<List<dynamic>> listarHistorial() async {
    final correo = await obtenerCorreoMecanico();
    try {
      // Intento 1: /solicitudes/mecanico?correoMecanico=...
      final res = await _dioClient.dio.get(
        '/solicitudes/mecanico',
        queryParameters: {'correoMecanico': correo, 'page': 0, 'size': 20},
      );
      if (res.data is Map && res.data['content'] != null) {
        return res.data['content'];
      } else if (res.data is List) {
        return res.data;
      }
      return [];
    } catch (e) {
      // Intento 2: fallback a /solicitudes/mecanico/{correo}
      final resFallback = await _dioClient.dio.get('/solicitudes/mecanico/$correo');
      if (resFallback.data is Map && resFallback.data['content'] != null) {
        return resFallback.data['content'];
      } else if (resFallback.data is List) {
        return resFallback.data;
      }
      return [];
    }
  }

  Future<List<dynamic>> listarHerramientasCustodia() async {
    final dni = await obtenerDniMecanico();
    try {
      final res = await _dioClient.dio.get('/prestamos/mecanico/$dni');
      if (res.data is List) {
        return res.data;
      }
    } catch (_) {}
    return [];
  }
}
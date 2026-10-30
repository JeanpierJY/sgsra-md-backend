import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/repuesto_model.dart';
import '../models/solicitud_request.dart';

class RepuestoRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RepuestoRemoteDataSource(this._dioClient);

  Future<String> obtenerCorreoMecanico() async {
    return await _storage.read(key: 'correo_usuario') ?? 'carlos.baro@masterdrilling.com';
  }

  Future<String> obtenerDniMecanico() async {
    return await _storage.read(key: 'dni_usuario') ?? '70000001';
  }

  Future<List<RepuestoModel>> listarCatalogo({int page = 0, int size = 20}) async {
    final res = await _dioClient.dio.get('/catalogo', queryParameters: {'page': page, 'size': size});
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
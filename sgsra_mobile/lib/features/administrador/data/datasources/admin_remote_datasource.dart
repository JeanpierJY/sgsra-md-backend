import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/admin_models.dart';

/// [RF21 - RF32] Datasource HTTP real para la administración y Jefatura de Taller
class AdminRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AdminRemoteDataSource(this._dioClient);

  Future<String?> _obtenerCorreoAdmin() async {
    return await _secureStorage.read(key: 'correo_admin') ?? 'leao.chura@masterdrilling.com';
  }

  Future<List<SolicitudBandejaModel>> obtenerBandeja() async {
    final response = await _dioClient.dio.get('/solicitudes/bandeja');
    final List<dynamic> data = response.data;
    return data.map((x) => SolicitudBandejaModel.fromJson(x)).toList();
  }

  Future<void> aprobarSolicitud(String solicitudNum) async {
    final correo = await _obtenerCorreoAdmin();
    await _dioClient.dio.put(
      '/solicitudes/$solicitudNum/aprobar',
      queryParameters: {'correoAdmin': correo},
    );
  }

  Future<void> rechazarSolicitud(String solicitudNum, String motivo) async {
    final correo = await _obtenerCorreoAdmin();
    // [RF25] El backend exige DictamenRechazoRequest con el campo 'justificacionRechazo' (min 15 caracteres)
    await _dioClient.dio.put(
      '/solicitudes/$solicitudNum/rechazar',
      queryParameters: {'correoAdmin': correo},
      data: {'justificacionRechazo': motivo},
    );
  }

  Future<void> aprobarParcial(String solicitudNum, Map<String, dynamic> payload) async {
    final correo = await _obtenerCorreoAdmin();
    await _dioClient.dio.put(
      '/solicitudes/$solicitudNum/aprobar-parcial',
      queryParameters: {'correoAdmin': correo},
      data: payload,
    );
  }

  Future<void> contactarOrden(String solicitudNum, String codigoCotizacion) async {
    final correo = await _obtenerCorreoAdmin();
    await _dioClient.dio.put(
      '/solicitudes/$solicitudNum/contactar',
      queryParameters: {'correoAdmin': correo},
      data: {'codigoCotizacion': codigoCotizacion},
    );
  }

  Future<void> registrarRepuestoCatalogo(Map<String, dynamic> data) async {
    await _dioClient.dio.post('/catalogo', data: data);
  }
}
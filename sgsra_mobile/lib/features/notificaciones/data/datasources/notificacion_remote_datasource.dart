import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notificacion_entity.dart';

/// [RF50] Consumo de `/api/v1/notificaciones` (el backend resuelve el rol a partir del DNI
/// y devuelve las notificaciones personales + las dirigidas a su rol)
class NotificacionRemoteDataSource {
  final DioClient _dioClient;

  NotificacionRemoteDataSource([DioClient? client]) : _dioClient = client ?? DioClient();

  Future<List<NotificacionEntity>> listar(String dni) async {
    final res = await _dioClient.dio.get('/notificaciones/$dni');
    final data = res.data;
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(NotificacionEntity.fromJson).toList();
  }

  Future<int> contarNoLeidas(String dni) async {
    final res = await _dioClient.dio.get('/notificaciones/$dni/no-leidas/conteo');
    final data = res.data;
    if (data is Map) {
      final valor = data.values.firstWhere((v) => v is num, orElse: () => 0);
      return (valor as num).toInt();
    }
    if (data is num) return data.toInt();
    return 0;
  }

  Future<void> marcarLeida(int id) => _dioClient.dio.put('/notificaciones/$id/leer');

  Future<void> marcarTodasLeidas(String dni) => _dioClient.dio.put('/notificaciones/leer-todas/$dni');
}

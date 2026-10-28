import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/database_helper.dart';
import 'api_service.dart';

class SincronizacionService {
  final Connectivity _connectivity = Connectivity();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  void inicializarEscuchaRed() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        sincronizarBorradoresPendientes();
      }
    });
  }

  Future<void> sincronizarBorradoresPendientes() async {
    final pendientes = await _dbHelper.obtenerBorradoresPendientes();
    for (final row in pendientes) {
      try {
        final Map<String, dynamic> payload = jsonDecode(row['payloadJson'] as String);
        final int id = row['id'] as int;

        await _apiService.registrarSolicitud("carlos.mendoza@masterdrilling.com", payload);
        await _dbHelper.marcarComoSincronizado(id);
      } catch (_) {
        break;
      }
    }
  }
}
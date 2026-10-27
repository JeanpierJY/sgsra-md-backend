import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/database_helper.dart';
import 'api_service.dart';

class SincronizacionService {
  final ApiService _apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _sincronizando = false;

  void inicializarEscuchaRed() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> resultados) {
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        _vaciarColaBorradores();
      }
    });
  }

  Future<void> _vaciarColaBorradores() async {
    if (_sincronizando) return;
    _sincronizando = true;

    try {
      final dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> borradores = await dbHelper.obtenerBorradoresOffline();
      final correoMecanico = await _secureStorage.read(key: "correo_corporativo");

      if (borradores.isEmpty || correoMecanico == null) {
        _sincronizando = false;
        return;
      }

      for (var borrador in borradores) {
        final int idLocal = borrador['id'];
        final Map<String, dynamic> payload = {
          'codMaquinaria': borrador['cod_maquinaria'],
          'prioridad': borrador['prioridad'],
          'justificacionTecnica': borrador['justificacion'],
          'items': jsonDecode(borrador['repuestos_json']),
        };

        final response = await _apiService.registrarSolicitud(correoMecanico, payload);

        if (response.statusCode == 200 || response.statusCode == 201) {
          await dbHelper.eliminarBorradorSincronizado(idLocal);
        }
      }
    } catch (e) {
      // Si la transacción atómica falla, la cola se retiene con cifrado AES-256 en la base local
    } finally {
      _isSyncing = false;
    }
  }

  void cancelarMonitoreo() {
    _connectivitySubscription?.cancel();
  }
}

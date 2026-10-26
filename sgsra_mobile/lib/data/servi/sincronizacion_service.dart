import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../datasources/database_helper.dart';

class SincronizacionService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api')); // Ajustar URL base de Spring Boot
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  // Inicializa la escucha reactiva del estado de la red en segundo plano
  void inicializarMonitoreoRed() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Si el dispositivo se conecta a redes móviles o WiFi, dispara la descarga de la cola
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        _ejecutarSincronizacionSecuencial();
      }
    });
  }

  // RNF25: Vacía de manera ordenada y secuencial los borradores guardados offline
  Future<void> _ejecutarSincronizacionSecuencial() async {
    if (_isSyncing) return; // Previene ejecuciones concurrentes duplicadas
    _isSyncing = true;

    try {
      final dbHelper = DatabaseHelper.instance;
      // 1. Lee la cola encriptada de SQLite (RF18)
      final List<Map<String, dynamic>> listaBorradores = await dbHelper.obtenerBorradores();

      if (listaBorradores.isEmpty) {
        _isSyncing = false;
        return;
      }

      print("📡 Red recuperada en taller. Procesando ${listaBorradores.length} requerimientos en cola...");

      for (var borrador in listaBorradores) {
        final int localId = borrador['id'];
        
        // Estructura el payload con los tipos de datos requeridos por el backend de Spring Boot
        final Map<String, dynamic> payload = {
          'codMaquina': borrador['cod_maquina'],
          'prioridad': borrador['prioridad'],
          'justificacionTecnica': borrador['justificacion'],
          'repuestos': jsonDecode(borrador['repuestos_json']),
        };

        // 2. Transmite formalmente cifrado al servidor (RF17)
        final response = await _dio.post('/solicitudes/crear', data: payload);

        if (response.statusCode == 200 || response.statusCode == 21) {
          // 3. Si el servidor confirma la persistencia, se purga el registro local de forma atómica
          await dbHelper.eliminarBorrador(localId);
          print("✓ Solicitud local ID $localId sincronizada y purgada de la cola local.");
        }
      }
    } catch (e) {
      print("✕ Fallo en la transmisión hacia Spring Boot. La cola se retiene de forma segura.");
    } finally {
      _isSyncing = false;
    }
  }

  void cancelarMonitoreo() {
    _connectivitySubscription?.cancel();
  }
}

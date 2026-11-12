import 'package:flutter/foundation.dart';

/// [RF01] Constantes de conexión y URLs base hacia el Backend
/// Funciona automáticamente tanto en Web (Chrome) como en Celulares físicos Android / Emuladores.
class ApiService {
  /// IP IPv4 de tu computadora en la red Wi-Fi local donde corre Spring Boot
  static const String localIp = '192.168.18.57';
  static const String port = '8080';

  /// URL raíz del servidor (útil para cargar imágenes `/uploads/...`)
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://localhost:$port';
    } else {
      return 'http://$localIp:$port';
    }
  }

  /// URL base de los endpoints REST `/api/v1`
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api/v1';
    } else {
      return 'http://$localIp:$port/api/v1';
    }
  }
}

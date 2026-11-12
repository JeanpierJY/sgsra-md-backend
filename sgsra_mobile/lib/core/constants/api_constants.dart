import 'package:flutter/foundation.dart';
import 'dart:io';

/// [RF01] Constantes de conexión y URLs base hacia el Backend
class ApiService {
  /// IP IPv4 del host donde corre Spring Boot en la red local
  static const String serverIp = '192.168.18.57';
  static const String serverPort = '8080';

  static String get serverUrl => 'http://$serverIp:$serverPort';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$serverPort/api/v1';
    return '$serverUrl/api/v1';
  }
}

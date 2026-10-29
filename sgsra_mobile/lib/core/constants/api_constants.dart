import 'package:flutter/foundation.dart';
import 'dart:io';

/// [RF01] Constantes de conexión y URLs base hacia el Backend
class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    return Platform.isAndroid ? 'http://10.0.2.2:8080/api/v1' : 'http://localhost:8080/api/v1';
  }
}
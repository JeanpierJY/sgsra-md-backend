import 'package:flutter/foundation.dart';
import 'dart:io';

/// [RF01] Constantes de conexión y URLs base hacia el Backend
class ApiService {
  static String get baseUrl {
    // Reemplaza '192.168.X.X' con la IP IPv4 actual de tu computadora
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    return 'http://192.168.X.X:8080/api/v1'; 
  }
}

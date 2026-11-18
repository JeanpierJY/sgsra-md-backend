import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [RF01] Constantes de conexión y URLs base hacia el Backend Spring Boot.
class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyCustomHost = 'custom_api_host';

  /// IP IPv4 de la laptop en la red Wi-Fi local donde corre Spring Boot
  static const String localIp = String.fromEnvironment('API_HOST', defaultValue: '192.168.18.57');
  static const String port = String.fromEnvironment('API_PORT', defaultValue: '8080');

  /// IP de loopback estándar para el emulador de Android Studio
  static const String emulatorIp = '10.0.2.2';

  /// Permite configurar dinámicamente el host si se ejecuta en emulador de Android Studio
  static String? _customHost;
  static set customHost(String? host) => _customHost = host;
  static String? get customHost => _customHost;

  /// Carga el host persistido si el usuario configuró una IP personalizada
  static Future<void> inicializar() async {
    try {
      final h = await _storage.read(key: _keyCustomHost);
      if (h != null && h.trim().isNotEmpty) {
        _customHost = h.trim();
      }
    } catch (_) {}
  }

  /// Guarda una nueva IP de servidor configurada desde la UI
  static Future<void> guardarHost(String host) async {
    _customHost = host.trim();
    await _storage.write(key: _keyCustomHost, value: _customHost);
  }

  /// Restablece la IP predeterminada
  static Future<void> restaurarHostDefault() async {
    _customHost = null;
    await _storage.delete(key: _keyCustomHost);
  }

  /// En Web (Chrome) el backend corre en la misma máquina (localhost);
  /// En móvil físico o emulador utiliza el host asignado o la IP LAN local
  static String get host {
    if (_customHost != null && _customHost!.trim().isNotEmpty) return _customHost!.trim();
    if (kIsWeb) return 'localhost';
    return localIp;
  }

  /// URL raíz del servidor (útil para cargar imágenes `/uploads/...`)
  static String get serverUrl => 'http://$host:$port';

  /// URL base de los endpoints REST `/api/v1`
  static String get baseUrl => '$serverUrl/api/v1';

  /// Convierte una ruta relativa del backend (`/uploads/...`) en URL absoluta
  static String urlRecurso(String? ruta) {
    if (ruta == null || ruta.isEmpty) return '';
    if (ruta.startsWith('http')) return ruta;
    return '$serverUrl${ruta.startsWith('/') ? '' : '/'}$ruta';
  }
}

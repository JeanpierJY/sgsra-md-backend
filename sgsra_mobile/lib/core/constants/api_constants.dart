import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [RF01] Constantes de conexión y URLs base hacia el Backend Spring Boot.
class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _keyCustomHost = 'custom_api_host';

  /// Host predeterminado: URL cloud HTTPS en Render
  static const String localIp = String.fromEnvironment('API_HOST', defaultValue: 'https://sgsra-md-backend.onrender.com');
  static const String port = String.fromEnvironment('API_PORT', defaultValue: '8080');

  /// IP de loopback estándar para el emulador de Android Studio
  static const String emulatorIp = '10.0.2.2';

  /// Permite configurar dinámicamente el host si se ejecuta en emulador de Android Studio
  static String? _customHost;
  static set customHost(String? host) => _customHost = host;
  static String? get customHost => _customHost;

  /// [H-GEN-02] La configuración manual de IP se retiró del login: se descarta
  /// cualquier host personalizado guardado por versiones anteriores para que la
  /// app siempre apunte al servidor por defecto (Render o `--dart-define=API_HOST`).
  static Future<void> inicializar() async {
    _customHost = null;
    try {
      await _storage.delete(key: _keyCustomHost);
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

  /// Host activo: si hay host guardado usa ese, de lo contrario apunta a Render (localIp)
  static String get host {
    if (_customHost != null && _customHost!.trim().isNotEmpty) return _customHost!.trim();
    return localIp;
  }

  /// URL raíz del servidor (soporta IP local con puerto o URL cloud HTTPS de Render/Oracle)
  static String get serverUrl {
    final h = host;
    if (h.startsWith('http://') || h.startsWith('https://')) {
      return h.endsWith('/') ? h.substring(0, h.length - 1) : h;
    }
    if (h.contains('.onrender.com') || h.contains('.railway.app') || h.contains('.oraclecloud.com')) {
      return 'https://$h';
    }
    return 'http://$h:$port';
  }

  /// Construye la URL de prueba para verificar conectividad con cualquier host
  static String urlPruebaConexion(String input) {
    var s = input.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) {
      s = s.endsWith('/') ? s.substring(0, s.length - 1) : s;
      return '$s/api/v1/catalogo';
    }
    if (s.contains('.onrender.com') || s.contains('.railway.app') || s.contains('.oraclecloud.com')) {
      return 'https://$s/api/v1/catalogo';
    }
    return 'http://$s:$port/api/v1/catalogo';
  }

  /// URL base de los endpoints REST `/api/v1`
  static String get baseUrl => '$serverUrl/api/v1';

  /// Convierte una ruta relativa del backend (`/uploads/...`) en URL absoluta
  static String urlRecurso(String? ruta) {
    if (ruta == null || ruta.isEmpty) return '';
    if (ruta.startsWith('http')) return ruta;
    return '$serverUrl${ruta.startsWith('/') ? '' : '/'}$ruta';
  }
}

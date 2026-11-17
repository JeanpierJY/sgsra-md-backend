import 'package:flutter/foundation.dart';

/// [RF01] Constantes de conexión y URLs base hacia el Backend Spring Boot.
///
/// La IP del servidor se centraliza aquí. Para no editar código al cambiar de red Wi-Fi,
/// se puede indicar al compilar:
///   flutter run --dart-define=API_HOST=192.168.1.45
///   flutter build apk --release --dart-define=API_HOST=192.168.1.45
///
/// Requisitos en Android: `android:usesCleartextTraffic="true"` en AndroidManifest.xml
/// (llamadas HTTP sin SSL) y el puerto 8080 habilitado en el Firewall de Windows.
class ApiService {
  /// IP IPv4 de la laptop en la red Wi-Fi local donde corre Spring Boot
  static const String localIp = String.fromEnvironment('API_HOST', defaultValue: '192.168.18.57');
  static const String port = String.fromEnvironment('API_PORT', defaultValue: '8080');

  /// IP de loopback estándar para el emulador de Android Studio
  static const String emulatorIp = '10.0.2.2';

  /// Permite configurar dinámicamente el host si se ejecuta en emulador de Android Studio
  static String? _customHost;
  static set customHost(String? host) => _customHost = host;
  static String? get customHost => _customHost;

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

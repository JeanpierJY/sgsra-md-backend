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

  /// En Web (Chrome) el backend corre en la misma máquina
  static String get host => kIsWeb ? 'localhost' : localIp;

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

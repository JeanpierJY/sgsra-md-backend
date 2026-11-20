import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [RF01, RF03] Datos de la sesión activa persistidos en almacenamiento seguro.
/// Se guardan al iniciar sesión y se usan en Mi Perfil y en el Centro de Notificaciones.
class SessionManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String keyToken = 'jwt_token';
  static const String keyCorreo = 'correo_usuario';
  static const String keyDni = 'dni_usuario';
  static const String keyNombre = 'nombre_usuario';
  static const String keyRol = 'rol_usuario';

  static Future<void> guardar({
    required String token,
    required String correo,
    required String dni,
    required String nombre,
    required String rol,
  }) async {
    await _storage.write(key: keyToken, value: token);
    await _storage.write(key: keyCorreo, value: correo);
    await _storage.write(key: keyDni, value: dni);
    await _storage.write(key: keyNombre, value: nombre);
    await _storage.write(key: keyRol, value: rol);
  }

  static Future<String?> correo() => _storage.read(key: keyCorreo);
  static Future<String?> dni() => _storage.read(key: keyDni);
  static Future<String?> nombre() => _storage.read(key: keyNombre);
  static Future<String?> rol() => _storage.read(key: keyRol);

  static Future<void> cerrar() => _storage.deleteAll();
}

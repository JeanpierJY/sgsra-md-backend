import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_colors.dart';

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

  /// [H-GEN-01] Solo borra los datos de la sesión. Antes se usaba `deleteAll()`, que también
  /// eliminaba las credenciales biométricas y por eso la huella dejaba de funcionar al cerrar sesión.
  static Future<void> cerrar() async {
    for (final k in [keyToken, keyCorreo, keyDni, keyNombre, keyRol]) {
      await _storage.delete(key: k);
    }
  }

  /// [H-GEN-08] Cierre forzado cuando el administrador desactiva la cuenta: también se
  /// olvidan las credenciales biométricas para que no se pueda reingresar con la huella.
  static Future<void> cerrarPorCuentaDesactivada() async {
    await cerrar();
    await _storage.delete(key: 'biometric_correo');
    await _storage.delete(key: 'biometric_pass');
  }

  /// Llaves globales para navegar y mostrar mensajes desde fuera de un widget (p. ej. el cliente HTTP)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static bool _cerrandoForzado = false;

  /// [H-GEN-08] Cierra la sesión y vuelve al login mostrando el motivo (se ejecuta una sola vez)
  static Future<void> forzarCierreSesion(String mensaje) async {
    if (_cerrandoForzado) return;
    _cerrandoForzado = true;
    try {
      await cerrarPorCuentaDesactivada();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      _cerrandoForzado = false;
    }
  }
}

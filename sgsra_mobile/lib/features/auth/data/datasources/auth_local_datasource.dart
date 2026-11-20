import '../../../../core/session/session_manager.dart';
import '../models/login_response_model.dart';

/// [RF01, RF03] Datasource local para gestión de sesión y almacenamiento seguro de tokens
class AuthLocalDataSource {
  /// Guarda token y datos del usuario para Mi Perfil y el Centro de Notificaciones
  Future<void> guardarSesion(LoginResponseModel usuario) async {
    await SessionManager.guardar(
      token: usuario.token,
      correo: usuario.correo,
      dni: usuario.dni,
      nombre: usuario.nombre,
      rol: usuario.rol,
    );
  }

  Future<void> eliminarSesion() => SessionManager.cerrar();
}

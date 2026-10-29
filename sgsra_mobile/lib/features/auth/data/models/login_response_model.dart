import '../../domain/entities/user_entity.dart';

/// [RF01] Modelo de respuesta del login para mapeo de DTOs del Backend
class LoginResponseModel extends UserEntity {
  final String token;

  const LoginResponseModel({
    required String id,
    required String correo,
    required String nombre,
    required String rol,
    required String dni,
    required String telefono,
    required this.token,
  }) : super(
          id: id,
          correo: correo,
          nombre: nombre,
          rol: rol,
          dni: dni,
          telefono: telefono,
        );

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      id: json['id']?.toString() ?? '',
      correo: json['correo'] ?? '',
      nombre: json['nombre'] ?? '',
      rol: json['rol'] ?? 'MECANICO',
      dni: json['dni'] ?? '',
      telefono: json['telefono'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
/// [RF01, RF02] Entidad de dominio que representa al usuario en el sistema
class UserEntity {
  final String id;
  final String correo;
  final String nombre;
  final String rol; // MECANICO, ALMACENISTA, ADMINISTRADOR
  final String dni;
  final String telefono;

  const UserEntity({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.rol,
    required this.dni,
    required this.telefono,
  });
}
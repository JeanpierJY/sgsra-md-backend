class UsuarioModel {
  final int? idUsuario;
  final String dni;
  final String nombre;
  final String correoCorporativo;
  final String rol;
  final String estadoCuenta;
  final int intentosFallidos;

  UsuarioModel({
    this.idUsuario,
    required this.dni,
    required this.nombre,
    required this.correoCorporativo,
    required this.rol,
    required this.estadoCuenta,
    required this.intentosFallidos,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['idUsuario'],
      dni: json['dni'] ?? '',
      nombre: json['nombre'] ?? '',
      correoCorporativo: json['correoCorporativo'] ?? '',
      rol: json['rol'] ?? '',
      estadoCuenta: json['estadoCuenta'] ?? 'ACTIVO',
      intentosFallidos: json['intentosFallidos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dni': dni,
      'nombre': nombre,
      'correoCorporativo': correoCorporativo,
      'rol': rol,
      'estadoCuenta': estadoCuenta,
      'intentosFallidos': intentosFallidos,
    };
  }
}

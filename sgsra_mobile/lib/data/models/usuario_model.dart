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
      idUsuario: json['idUsuario'] as int?,
      dni: json['dni'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      correoCorporativo: json['correoCorporativo'] as String? ?? '',
      rol: json['rol'] as String? ?? 'MECANICO',
      estadoCuenta: json['estadoCuenta'] as String? ?? 'ACTIVO',
      intentosFallidos: json['intentosFallidos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idUsuario != null) 'idUsuario': idUsuario,
      'dni': dni,
      'nombre': nombre,
      'correoCorporativo': correoCorporativo,
      'rol': rol,
      'estadoCuenta': estadoCuenta,
      'intentosFallidos': intentosFallidos,
    };
  }
}
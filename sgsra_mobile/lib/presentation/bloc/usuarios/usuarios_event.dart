import '../../../data/models/usuario_model.dart';

abstract class UsuariosEvent {}

class FetchUsuariosRequested extends UsuariosEvent {}

class CreateUsuarioRequested extends UsuariosEvent {
  final UsuarioModel usuario;
  CreateUsuarioRequested(this.usuario);
}

class ToggleEstadoUsuarioRequested extends UsuariosEvent {
  final int idUsuario;
  final String nuevoEstado;
  ToggleEstadoUsuarioRequested(this.idUsuario, this.nuevoEstado);
}
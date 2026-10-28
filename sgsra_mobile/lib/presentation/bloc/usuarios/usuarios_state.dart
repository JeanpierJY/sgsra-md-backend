import '../../../data/models/usuario_model.dart';

abstract class UsuariosState {}

class UsuariosInitial extends UsuariosState {}
class UsuariosLoading extends UsuariosState {}

class UsuariosLoaded extends UsuariosState {
  final List<UsuarioModel> usuarios;
  UsuariosLoaded(this.usuarios);
}

class UsuariosActionSuccess extends UsuariosState {
  final String msg;
  UsuariosActionSuccess(this.msg);
}

class UsuariosFailure extends UsuariosState {
  final String error;
  UsuariosFailure(this.error);
}
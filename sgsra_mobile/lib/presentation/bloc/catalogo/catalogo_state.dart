import '../../../data/models/repuesto_model.dart';

abstract class CatalogoState {}

class CatalogoInitial extends CatalogoState {}
class CatalogoLoading extends CatalogoState {}

class CatalogoLoaded extends CatalogoState {
  final List<RepuestoModel> repuestos;
  CatalogoLoaded(this.repuestos);
}

class CatalogoFailure extends CatalogoState {
  final String error;
  CatalogoFailure(this.error);
}
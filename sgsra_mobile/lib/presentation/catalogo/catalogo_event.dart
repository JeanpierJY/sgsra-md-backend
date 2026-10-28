abstract class CatalogoEvent {}

class CargarCatalogoRequested extends CatalogoEvent {}

class BuscarRepuestoPredictivoRequested extends CatalogoEvent {
  final String termino;
  BuscarRepuestoPredictivoRequested(this.termino);
}
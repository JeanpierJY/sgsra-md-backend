abstract class CatalogoEvent {}

class FetchCatalogoRequested extends CatalogoEvent {}

class SearchRepuestosRequested extends CatalogoEvent {
  final String query;
  SearchRepuestosRequested(this.query);
}
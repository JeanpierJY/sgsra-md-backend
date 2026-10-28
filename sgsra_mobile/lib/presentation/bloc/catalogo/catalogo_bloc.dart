import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/repuesto_model.dart';
import '../../../data/services/api_service.dart';
import 'catalogo_event.dart';
import 'catalogo_state.dart';

class CatalogoBloc extends Bloc<CatalogoEvent, CatalogoState> {
  final ApiService _apiService = ApiService();

  CatalogoBloc() : super(CatalogoInitial()) {
    on<FetchCatalogoRequested>((event, emit) async {
      emit(CatalogoLoading());
      try {
        final res = await _apiService.obtenerCatalogo();
        final rawList = res.data['content'] as List? ?? [];
        final list = rawList.map((e) => RepuestoModel.fromJson(e as Map<String, dynamic>)).toList();
        emit(CatalogoLoaded(list));
      } catch (e) {
        emit(CatalogoFailure("No se pudo cargar el catalogo"));
      }
    });

    on<SearchRepuestosRequested>((event, emit) async {
      if (event.query.trim().length < 3) {
        add(FetchCatalogoRequested());
        return;
      }
      emit(CatalogoLoading());
      try {
        final res = await _apiService.buscarRepuestosPredictivo(event.query.trim());
        final rawList = res.data is List ? res.data as List : [];
        final list = rawList.map((e) => RepuestoModel.fromJson(e as Map<String, dynamic>)).toList();
        emit(CatalogoLoaded(list));
      } catch (e) {
        emit(CatalogoFailure("Error en busqueda predictiva"));
      }
    });
  }
}
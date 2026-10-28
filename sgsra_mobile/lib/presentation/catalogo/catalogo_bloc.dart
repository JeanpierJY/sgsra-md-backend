import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/repuesto_model.dart';
import '../../../data/services/api_service.dart';
import 'catalogo_event.dart';
import 'catalogo_state.dart';

class CatalogoBloc extends Bloc<CatalogoEvent, CatalogoState> {
  final ApiService apiService = ApiService();

  final List<RepuestoModel> _mockMasterList = [
    RepuestoModel(
      codParte: "P-REX-024",
      nombreRepuesto: "Bomba de pistones axiales Rexroth A4VSO",
      stockActual: 10,
      stockMinimo: 2,
      descripcion: "Bomba hidraulica para rotacion principal",
      activo: true,
    ),
    RepuestoModel(
      codParte: "H-ESP-118",
      nombreRepuesto: "Manguera espiral 4SP 1 pulgada",
      stockActual: 35,
      stockMinimo: 5,
      descripcion: "Manguera de alta presion 400 bar",
      activo: true,
    ),
    RepuestoModel(
      codParte: "F-HYD-882",
      nombreRepuesto: "Filtro hidraulico 10 micras",
      stockActual: 50,
      stockMinimo: 10,
      descripcion: "Filtro de retorno de aceite para tanque",
      activo: true,
    ),
  ];

  CatalogoBloc() : super(CatalogoInitial()) {
    on<CargarCatalogoRequested>((event, emit) async {
      emit(CatalogoLoading());
      try {
        final response = await apiService.obtenerCatalogo();
        if (response.statusCode == 200 && response.data['content'] != null) {
          final List dynamicList = response.data['content'];
          final lista = dynamicList.map((e) => RepuestoModel.fromJson(e)).toList();
          emit(CatalogoLoaded(repuestos: lista));
        } else {
          emit(CatalogoLoaded(repuestos: _mockMasterList));
        }
      } catch (e) {
        emit(CatalogoLoaded(repuestos: _mockMasterList));
      }
    });

    on<BuscarRepuestoPredictivoRequested>((event, emit) async {
      if (event.termino.trim().length < 3) {
        emit(CatalogoLoaded(repuestos: _mockMasterList));
        return;
      }
      try {
        final response = await apiService.buscarRepuestosPredictivo(event.termino);
        final List dynamicList = response.data;
        final lista = dynamicList.map((e) => RepuestoModel.fromJson(e)).toList();
        emit(CatalogoLoaded(repuestos: lista));
      } catch (e) {
        final filtrados = _mockMasterList.where((r) =>
            r.nombreRepuesto.toLowerCase().contains(event.termino.toLowerCase()) ||
            r.codParte.toLowerCase().contains(event.termino.toLowerCase())).toList();
        emit(CatalogoLoaded(repuestos: filtrados));
      }
    });
  }
}
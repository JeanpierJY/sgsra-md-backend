import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/repuesto_model.dart';

abstract class CatalogoEvent {}
class CargarCatalogoRequested extends CatalogoEvent {}
class BuscarRepuestosRequested extends CatalogoEvent { final String query; BuscarRepuestosRequested(this.query); }

abstract class CatalogoState {}
class CatalogoInitial extends CatalogoState {}
class CatalogoLoading extends CatalogoState {}
class CatalogoLoaded extends CatalogoState { 
  final List<RepuestoModel> items; 
  final List<RepuestoModel> sugerencias;
  CatalogoLoaded(this.items, {this.sugerencias = const []}); 
}

class CatalogoBloc extends Bloc<CatalogoEvent, CatalogoState> {
  final List<RepuestoModel> _mockMasterList = [
    RepuestoModel(codParte: "RB-001", nombreRepuesto: "Tricono de Perforación 12 1/4", stockActual: 15, stockMinimo: 2),
    RepuestoModel(codParte: "RB-002", nombreRepuesto: "Barra de Perforación Estándar 10''", stockActual: 45, stockMinimo: 5),
    RepuestoModel(codParte: "RB-003", nombreRepuesto: "Bomba Hidráulica Axial de Pistones", stockActual: 4, stockMinimo: 1),
  ];

  CatalogoBloc() : super(CatalogoInitial()) {
    on<CargarCatalogoRequested>((event, emit) async {
      emit(CatalogoLoading());
      await Future.delayed(const Duration(milliseconds: 400));
      emit(CatalogoLoaded(_mockMasterList));
    });

    on<BuscarRepuestosRequested>((event, emit) {
      if (state is CatalogoLoaded) {
        final q = event.query.toLowerCase().trim();
        if (q.isEmpty) {
          emit(CatalogoLoaded(_mockMasterList, sugerencias: const []));
          return;
        }
        final filtrados = _mockMasterList.where((item) {
          return item.nombreRepuesto.toLowerCase().contains(q) || item.codParte.toLowerCase().contains(q);
        }).toList();
        emit(CatalogoLoaded(_mockMasterList, sugerencias: filtrados));
      }
    });
  }
}

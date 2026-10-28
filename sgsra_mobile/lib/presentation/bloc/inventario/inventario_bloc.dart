import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/services/api_service.dart';
import 'inventario_event.dart';
import 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final ApiService apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  InventarioBloc() : super(InventarioInitial()) {
    on<CargarDashboardRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final response = await apiService.obtenerMetricasDashboard();
        emit(DashboardLoaded(metricas: response.data));
      } catch (e) {
        emit(InventarioFailure("Error al cargar metricas de panol"));
      }
    });
    
    on<EscanearCodigoQRRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final response = await apiService.consultarHerramientaPorCodigo(event.codigo);
        emit(HerramientaEscaneadaSuccess(herramienta: response.data));
      } catch (e) {
        emit(InventarioFailure("Herramienta no registrada en panol: ${event.codigo}"));
      }
    });

    on<RegistrarPrestamoRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final correoAlmacenista = await _secureStorage.read(key: "correo_corporativo") ?? "marcos.ramos@masterdrilling.com";
        final payload = {
          'dniMecanico': event.dniMecanico,
          'codigosHerramienta': event.codigosHerramienta,
          'firmaMecanico': event.firmaMecanico,
        };

        final response = await apiService.registrarPrestamo(correoAlmacenista, payload);
        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(PrestamoRegistradoSuccess(mensaje: response.data['mensaje'] ?? "Prestamo exitoso"));
        } else {
          emit(InventarioFailure("Error al procesar el despacho"));
        }
      } catch (e) {
        emit(InventarioFailure("Fallo al registrar prestamo: cupo excedido o herramientas no disponibles"));
      }
    });
  }
}
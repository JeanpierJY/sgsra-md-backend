import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/dashboard_metricas_model.dart';
import '../../../data/models/herramienta_model.dart';
import 'inventario_event.dart';
import 'inventario_state.dart';

class InventarioBloc extends Bloc<InventarioEvent, InventarioState> {
  final ApiService apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  InventarioBloc() : super(InventarioInitial()) {
    on<FetchMetricasDashboardRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final res = await apiService.obtenerMetricasDashboard();
        emit(DashboardMetricasLoaded(DashboardMetricasModel.fromJson(res.data)));
      } catch (e) {
        emit(InventarioFailure("Fallo al sincronizar stock actual del pañol."));
      }
    });

    on<EscanearCodigoQRRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final res = await apiService.consultarHerramientaPorCodigo(event.codigo);
        emit(HerramientaEscaneadaLoaded(HerramientaModel.fromJson(res.data)));
      } catch (e) {
        emit(InventarioFailure("El código QR/Barras no pertenece al inventario maestro de Master Drilling."));
      }
    });

    on<ConfirmarPrestamoRequested>((event, emit) async {
      emit(InventarioLoading());
      try {
        final correoAlmacenista = await _secureStorage.read(key: "correo_corporativo");
        final payload = {
          'dniMecanico': event.dniMecanico,
          'codigosHerramienta': event.codigosHerramientas,
          'firmaMecanico': event.firmaBase64
        };
        await apiService.registrarPrestamo(correoAlmacenista!, payload);
        emit(TransaccionSuccess("Préstamo registrado exitosamente bajo auditoría inalterable (RF36)."));
      } catch (e) {
        emit(InventarioFailure("Bloqueo: Operario en mora o cupo máximo de custodia excedido."));
      }
    });
  }
}

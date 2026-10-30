import '../entities/admin_entities.dart';
import '../repositories/admin_repository.dart';

class ObtenerBandejaUseCase {
  final AdminRepository repository;
  ObtenerBandejaUseCase(this.repository);
  Future<List<SolicitudBandejaEntity>> call() => repository.obtenerBandeja();
}

class EvaluarSolicitudUseCase {
  final AdminRepository repository;
  EvaluarSolicitudUseCase(this.repository);

  Future<void> aprobar(String id) => repository.aprobarSolicitud(id);
  Future<void> rechazar(String id, String motivo) => repository.rechazarSolicitud(id, motivo);
  Future<void> aprobarParcial(String id, int cantidad, String motivo) => repository.aprobarParcial(id, cantidad, motivo);
  Future<void> contactar(String id, String nroCotizacion) => repository.contactarOrden(id, nroCotizacion);
  Future<void> registrarCatalogo(Map<String, dynamic> data) => repository.registrarRepuestoCatalogo(data);
}
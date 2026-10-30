import '../entities/admin_entities.dart';

abstract class AdminRepository {
  Future<List<SolicitudBandejaEntity>> obtenerBandeja();
  Future<void> aprobarSolicitud(String id);
  Future<void> rechazarSolicitud(String id, String motivo);
  Future<void> aprobarParcial(String id, int cantidadAprobada, String motivo);
  Future<void> contactarOrden(String id, String nroCotizacion);
  Future<void> registrarRepuestoCatalogo(Map<String, dynamic> data);
}
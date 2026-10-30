import '../entities/repuesto_entity.dart';
import '../entities/solicitud_entity.dart';

abstract class RepuestoRepository {
  Future<List<RepuestoEntity>> obtenerCatalogo({int pagina = 0, String? buscar, String? maquinaria});
  Future<RepuestoEntity> obtenerDetalleRepuesto(String codParte);
  Future<String> enviarSolicitud(SolicitudEntity solicitud);
  Future<List<SolicitudEntity>> obtenerHistorialMecanico();
  Future<void> guardarBorradorLocal(SolicitudEntity solicitud);
  Future<List<SolicitudEntity>> obtenerBorradoresLocales();
  Future<void> sincronizarBorradores();
}
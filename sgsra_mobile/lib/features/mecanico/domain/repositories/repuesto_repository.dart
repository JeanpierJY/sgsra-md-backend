import '../entities/repuesto_entity.dart';
import '../entities/solicitud_entity.dart';

/// Contrato del repositorio de repuestos y solicitudes para el mecánico
abstract class RepuestoRepository {
  Future<List<RepuestoEntity>> obtenerCatalogo({int pagina = 0, String? buscar, String? maquinaria});
  Future<RepuestoEntity> obtenerDetalleRepuesto(String codParte);
  Future<String> enviarSolicitud(SolicitudEntity solicitud);
  Future<List<SolicitudEntity>> obtenerHistorialMecanico();
  Future<void> guardarBorradorLocal(SolicitudEntity solicitud); // [RF18] Offline
  Future<List<SolicitudEntity>> obtenerBorradoresLocales();
  Future<void> sincronizarBorradores(); // [RF18] Sincronización al volver conexión
}
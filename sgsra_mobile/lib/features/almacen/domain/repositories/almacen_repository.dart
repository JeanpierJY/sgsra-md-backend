import '../entities/almacen_entities.dart';

abstract class AlmacenRepository {
  Future<DashboardStockEntity> obtenerDashboard();
  Future<List<HerramientaEntity>> listarHerramientas({String? categoria});
  Future<HerramientaEntity> consultarHerramientaPorCodigo(String codigo);
  Future<List<PrestamoEntity>> listarPrestamos();
  Future<String> registrarPrestamo(String dniMecanico, List<String> codigosHerramienta, String firma);
  Future<void> registrarDevolucion(String prestamoNum, String codHerramienta, String estadoFisico, String incidencia);
  Future<String> reportarExtravio(String codHerramienta, String motivo);
  Future<void> registrarNuevaHerramienta(Map<String, dynamic> data);
}
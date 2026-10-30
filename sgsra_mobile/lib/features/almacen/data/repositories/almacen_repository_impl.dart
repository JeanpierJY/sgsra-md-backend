import '../../domain/entities/almacen_entities.dart';
import '../../domain/repositories/almacen_repository.dart';
import '../datasources/almacen_remote_datasource.dart';

class AlmacenRepositoryImpl implements AlmacenRepository {
  final AlmacenRemoteDataSource remoteDataSource;

  AlmacenRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardStockEntity> obtenerDashboard() => remoteDataSource.obtenerDashboard();

  @override
  Future<List<HerramientaEntity>> listarHerramientas({String? categoria}) =>
      remoteDataSource.listarHerramientas(categoria: categoria);

  @override
  Future<HerramientaEntity> consultarHerramientaPorCodigo(String codigo) =>
      remoteDataSource.consultarHerramienta(codigo);

  @override
  Future<List<PrestamoEntity>> listarPrestamos() => remoteDataSource.listarPrestamos();

  @override
  Future<String> registrarPrestamo(String dniMecanico, List<String> codigosHerramienta, String firma) =>
      remoteDataSource.registrarPrestamo(dniMecanico, codigosHerramienta, firma);

  @override
  Future<void> registrarDevolucion(String prestamoNum, String codHerramienta, String estadoFisico, String incidencia) =>
      remoteDataSource.registrarDevolucion(prestamoNum, codHerramienta, estadoFisico, incidencia);

  @override
  Future<String> reportarExtravio(String codHerramienta, String motivo) =>
      remoteDataSource.reportarExtravio(codHerramienta, motivo);

  @override
  Future<void> registrarNuevaHerramienta(Map<String, dynamic> data) =>
      remoteDataSource.registrarNuevaHerramienta(data);
}
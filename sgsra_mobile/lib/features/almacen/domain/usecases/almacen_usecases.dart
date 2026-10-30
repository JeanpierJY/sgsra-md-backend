import '../entities/almacen_entities.dart';
import '../repositories/almacen_repository.dart';

class ObtenerDashboardUseCase {
  final AlmacenRepository repository;
  ObtenerDashboardUseCase(this.repository);
  Future<DashboardStockEntity> call() => repository.obtenerDashboard();
}

class ListarHerramientasUseCase {
  final AlmacenRepository repository;
  ListarHerramientasUseCase(this.repository);
  Future<List<HerramientaEntity>> call({String? categoria}) => repository.listarHerramientas(categoria: categoria);
}

class RegistrarPrestamoUseCase {
  final AlmacenRepository repository;
  RegistrarPrestamoUseCase(this.repository);
  Future<String> call(String dni, List<String> cods, String firma) =>
      repository.registrarPrestamo(dni, cods, firma);
}

class RegistrarDevolucionUseCase {
  final AlmacenRepository repository;
  RegistrarDevolucionUseCase(this.repository);
  Future<void> call(String pres, String cod, String est, String obs) =>
      repository.registrarDevolucion(pres, cod, est, obs);
}

class ReportarExtravioUseCase {
  final AlmacenRepository repository;
  ReportarExtravioUseCase(this.repository);
  Future<String> call(String cod, String mot) => repository.reportarExtravio(cod, mot);
}
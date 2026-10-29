import '../entities/repuesto_entity.dart';
import '../entities/solicitud_entity.dart';
import '../repositories/repuesto_repository.dart';

class ObtenerCatalogoUseCase {
  final RepuestoRepository repository;
  ObtenerCatalogoUseCase(this.repository);
  Future<List<RepuestoEntity>> call({int pagina = 0, String? buscar, String? maquinaria}) {
    return repository.obtenerCatalogo(pagina: pagina, buscar: buscar, maquinaria: maquinaria);
  }
}

class EnviarSolicitudUseCase {
  final RepuestoRepository repository;
  EnviarSolicitudUseCase(this.repository);
  Future<String> call(SolicitudEntity solicitud) => repository.enviarSolicitud(solicitud);
}

class ObtenerHistorialMecanicoUseCase {
  final RepuestoRepository repository;
  ObtenerHistorialMecanicoUseCase(this.repository);
  Future<List<SolicitudEntity>> call() => repository.obtenerHistorialMecanico();
}

class SincronizarBorradoresUseCase {
  final RepuestoRepository repository;
  SincronizarBorradoresUseCase(this.repository);
  Future<void> call() => repository.sincronizarBorradores();
}
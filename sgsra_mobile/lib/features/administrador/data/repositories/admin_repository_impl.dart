import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SolicitudBandejaEntity>> obtenerBandeja() async {
    return await remoteDataSource.obtenerBandeja();
  }

  @override
  Future<void> aprobarSolicitud(String id) async {
    await remoteDataSource.aprobarSolicitud(id);
  }

  @override
  Future<void> rechazarSolicitud(String id, String motivo) async {
    await remoteDataSource.rechazarSolicitud(id, motivo);
  }

  @override
  Future<void> aprobarParcial(String id, int cantidadAprobada, String motivo) async {
    final payload = {
      "items": [
        {
          "item": 1,
          "aprobado": cantidadAprobada > 0,
          "motivoRechazoItem": motivo
        }
      ]
    };
    await remoteDataSource.aprobarParcial(id, payload);
  }

  @override
  Future<void> contactarOrden(String id, String nroCotizacion) async {
    await remoteDataSource.contactarOrden(id, nroCotizacion);
  }

  @override
  Future<void> registrarRepuestoCatalogo(Map<String, dynamic> data) async {
    await remoteDataSource.registrarRepuestoCatalogo(data);
  }
}
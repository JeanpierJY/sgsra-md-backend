import '../../domain/entities/repuesto_entity.dart';
import '../../domain/entities/solicitud_entity.dart';
import '../../domain/repositories/repuesto_repository.dart';
import '../datasources/repuesto_local_datasource.dart';
import '../datasources/repuesto_remote_datasource.dart';
import '../models/solicitud_request.dart';

class RepuestoRepositoryImpl implements RepuestoRepository {
  final RepuestoRemoteDataSource remoteDataSource;
  final RepuestoLocalDataSource localDataSource;

  RepuestoRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<List<RepuestoEntity>> obtenerCatalogo({int pagina = 0, String? buscar, String? maquinaria}) async {
    if (buscar != null && buscar.trim().isNotEmpty) {
      return await remoteDataSource.buscarPredictivo(buscar.trim());
    }
    return await remoteDataSource.listarCatalogo(page: pagina);
  }

  @override
  Future<RepuestoEntity> obtenerDetalleRepuesto(String codParte) async {
    return await remoteDataSource.obtenerDetalle(codParte);
  }

  @override
  Future<String> enviarSolicitud(SolicitudEntity solicitud) async {
    final dto = SolicitudCreacionDto(
      codMaquinaria: solicitud.codigoMaquinaria,
      prioridad: solicitud.prioridad,
      justificacionTecnica: solicitud.justificacion,
      items: [ItemRepuestoDto(codParte: solicitud.codParte, cantidad: solicitud.cantidad)],
    );
    return await remoteDataSource.registrarSolicitud(dto);
  }

  @override
  Future<List<SolicitudEntity>> obtenerHistorialMecanico() async {
    final rawList = await remoteDataSource.listarHistorial();
    return rawList.map((j) => SolicitudEntity(
      id: j['solicitudNum']?.toString(),
      correlativo: j['solicitudNum']?.toString() ?? '',
      codParte: j['codParte']?.toString() ?? '',
      nombreRepuesto: j['nombreRepuesto']?.toString() ?? 'Repuesto Solicitado',
      cantidad: j['totalComponentes'] is num ? (j['totalComponentes'] as num).toInt() : 1,
      prioridad: j['prioridad']?.toString() ?? 'MEDIA',
      codigoMaquinaria: j['codMaquinaria']?.toString() ?? '',
      justificacion: j['justificacionTecnica']?.toString() ?? '',
      estado: j['estado']?.toString() ?? 'PENDIENTE',
      fechaCreacion: DateTime.tryParse(j['fechaEmision']?.toString() ?? '') ?? DateTime.now(),
    )).toList();
  }

  @override
  Future<void> guardarBorradorLocal(SolicitudEntity solicitud) async {
    await localDataSource.guardarBorrador(solicitud);
  }

  @override
  Future<List<SolicitudEntity>> obtenerBorradoresLocales() async {
    return await localDataSource.listarBorradores();
  }

  @override
  Future<void> sincronizarBorradores() async {
    final borradores = await localDataSource.listarBorradores();
    for (final b in borradores) {
      try {
        await enviarSolicitud(b);
        if (b.id != null) {
          await localDataSource.limpiarBorrador(b.id!);
        }
      } catch (_) {}
    }
  }
}
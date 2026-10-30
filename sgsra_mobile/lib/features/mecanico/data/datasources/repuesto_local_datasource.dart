import '../../../../core/database/local_db_helper.dart';
import '../../domain/entities/solicitud_entity.dart';

class RepuestoLocalDataSource {
  final LocalDbHelper _dbHelper = LocalDbHelper.instance;

  Future<void> guardarBorrador(SolicitudEntity s) async {
    final db = await _dbHelper.database;
    await db.insert('borradores_solicitudes', {
      'correlativo': s.correlativo,
      'codParte': s.codParte,
      'nombreRepuesto': s.nombreRepuesto,
      'cantidad': s.cantidad,
      'prioridad': s.prioridad,
      'codigoMaquinaria': s.codigoMaquinaria,
      'justificacion': s.justificacion,
      'fechaCreacion': s.fechaCreacion.toIso8601String(),
    });
  }

  Future<List<SolicitudEntity>> listarBorradores() async {
    final db = await _dbHelper.database;
    final List<Map<String, Object?>> maps = await db.query('borradores_solicitudes');
    return maps.map((m) => SolicitudEntity(
      id: m['id'].toString(),
      correlativo: m['correlativo']?.toString() ?? 'BORRADOR',
      codParte: m['codParte']?.toString() ?? '',
      nombreRepuesto: m['nombreRepuesto']?.toString() ?? '',
      cantidad: (m['cantidad'] as num?)?.toInt() ?? 1,
      prioridad: m['prioridad']?.toString() ?? 'ALTA',
      codigoMaquinaria: m['codigoMaquinaria']?.toString() ?? '',
      justificacion: m['justificacion']?.toString() ?? '',
      estado: 'BORRADOR_LOCAL',
      fechaCreacion: DateTime.tryParse(m['fechaCreacion']?.toString() ?? '') ?? DateTime.now(),
    )).toList();
  }

  Future<void> limpiarBorrador(String id) async {
    final db = await _dbHelper.database;
    await db.delete('borradores_solicitudes', where: 'id = ?', whereArgs: [id]);
  }
}
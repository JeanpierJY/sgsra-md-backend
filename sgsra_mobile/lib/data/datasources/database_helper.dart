import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sgsra_md_secured_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    const String encryptionKey = "MasterDrillingSecuredKey2026_AES256_Prod";

    return await openDatabase(
      path,
      version: 1,
      password: encryptionKey,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE borradores_solicitudes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cod_maquinaria TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        justificacion TEXT NOT NULL,
        repuestos_json TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL
      )
    ''');
  }

  Future<int> guardarBorradorOffline(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('borradores_solicitudes', row);
  }

  Future<List<Map<String, dynamic>>> obtenerBorradoresOffline() async {
    final db = await instance.database;
    return await db.query('borradores_solicitudes', orderBy: 'fecha_creacion DESC');
  }

  Future<int> eliminarBorradorSincronizado(int id) async {
    final db = await instance.database;
    return await db.delete('borradores_solicitudes', where: 'id = ?', whereArgs: [id]);
  }
}


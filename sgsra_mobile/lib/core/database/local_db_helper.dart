import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbHelper {
  static final LocalDbHelper instance = LocalDbHelper._init();
  static Database? _database;

  LocalDbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('master_drilling_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE borradores_solicitudes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correlativo TEXT,
        codParte TEXT,
        nombreRepuesto TEXT,
        cantidad INTEGER,
        prioridad TEXT,
        codigoMaquinaria TEXT,
        justificacion TEXT,
        fechaCreacion TEXT
      )
    ''');
  }

  Future<void> cerrarDb() async {
    final db = await instance.database;
    db.close();
  }
}
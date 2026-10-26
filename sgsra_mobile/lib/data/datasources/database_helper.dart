import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sgsra_md_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // RNF19: Clave secreta industrial para cifrar la base local en AES-256
    // En producción esta llave debe recuperarse de forma ofuscada desde el Android KeyStore
    const String passwordCriptografica = "MasterDrillingSecuredKey2026_AES256";

    return await openDatabase(
      path,
      version: 1,
      password: passwordCriptografica, // Activa el cifrado de SQLCipher automáticamente
      onCreate: _createDB,
    );
  }

  // RF18: Estructura relacional local para encolar borradores de requerimientos en socavón
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE borradores_solicitudes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cod_maquina TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        justificacion TEXT NOT NULL,
        repuestos_json TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL
      )
    ''');
  }

  // Métodos CRUD básicos para gestionar la cola offline
  Future<int> insertarBorrador(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('borradores_solicitudes', row);
  }

  Future<List<Map<String, dynamic>>> obtenerBorradores() async {
    final db = await instance.database;
    return await db.query('borradores_solicitudes', orderBy: 'fecha_creacion DESC');
  }

  Future<int> eliminarBorrador(int id) async {
    final db = await instance.database;
    return await db.delete('borradores_solicitudes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}

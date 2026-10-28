import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'sgsra_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE borrador_solicitud (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codMaquinaria TEXT NOT NULL,
            prioridad TEXT NOT NULL,
            justificacionTecnica TEXT NOT NULL,
            payloadJson TEXT NOT NULL,
            sincronizado INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> guardarBorradorOffline(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('borrador_solicitud', data);
  }

  Future<List<Map<String, dynamic>>> obtenerBorradoresPendientes() async {
    final db = await database;
    return await db.query('borrador_solicitud', where: 'sincronizado = 0');
  }

  Future<int> marcarComoSincronizado(int id) async {
    final db = await database;
    return await db.update(
      'borrador_solicitud',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
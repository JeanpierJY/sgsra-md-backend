import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [RF01, RF03] Datasource local para gestión de sesión y almacenamiento seguro de tokens
class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> guardarToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<String?> obtenerToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<void> eliminarSesion() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
}
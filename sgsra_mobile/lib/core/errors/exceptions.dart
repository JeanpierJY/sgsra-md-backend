/// [RF06] Excepción lanzada cuando la cuenta se bloquea por 3 intentos fallidos
class CuentaBloqueadaException implements Exception {
  final String message;
  CuentaBloqueadaException([this.message = 'Cuenta bloqueada temporalmente por seguridad.']);
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
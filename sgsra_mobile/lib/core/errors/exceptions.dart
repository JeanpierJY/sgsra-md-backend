import 'package:dio/dio.dart';

/// [RF04, RF06] Cuenta bloqueada: temporal (con cuenta regresiva) o total.
class CuentaBloqueadaException implements Exception {
  final String message;
  final int segundosRestantes;
  final bool bloqueoPermanente;

  CuentaBloqueadaException([
    this.message = 'Cuenta bloqueada temporalmente por seguridad.',
    this.segundosRestantes = 0,
    this.bloqueoPermanente = false,
  ]);

  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

/// Convierte cualquier error de red o del backend en un mensaje legible para el usuario.
/// El backend responde con `ErrorDetalle { mensaje, erroresValidacion }`.
String mensajeDeError(Object error) {
  if (error is CuentaBloqueadaException) return error.message;
  if (error is ServerException) return error.message;
  if (error is DioException) {
    if (error.error is CuentaBloqueadaException) {
      return (error.error as CuentaBloqueadaException).message;
    }
    final data = error.response?.data;
    if (data is Map) {
      final validaciones = data['erroresValidacion'];
      if (validaciones is List && validaciones.isNotEmpty) {
        return validaciones.join('\n');
      }
      final mensaje = data['mensaje'] ?? data['message'];
      if (mensaje is String && mensaje.isNotEmpty) return mensaje;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'El servidor tardó demasiado en responder. Verifique su conexión Wi-Fi.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar con el servidor. Verifique que esté en la misma red Wi-Fi.';
      default:
        break;
    }
    return 'Error de comunicación con el servidor (${error.response?.statusCode ?? 'sin respuesta'}).';
  }
  return error.toString().replaceFirst('Exception: ', '');
}

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

/// Convierte cualquier error de red, backend o base de datos en un mensaje claro y amigable
/// para el usuario, eliminando códigos técnicos, trazas SQL y excepciones crudas.
String mensajeDeError(Object error) {
  if (error is CuentaBloqueadaException) return error.message;
  if (error is ServerException) return _sanitizarMensajeTecnico(error.message);
  if (error is DioException) {
    if (error.error is CuentaBloqueadaException) {
      return (error.error as CuentaBloqueadaException).message;
    }
    final data = error.response?.data;
    if (data is Map) {
      final validaciones = data['erroresValidacion'];
      if (validaciones is List && validaciones.isNotEmpty) {
        return validaciones.map((e) => _sanitizarMensajeTecnico('$e')).join('\n');
      }
      final mensaje = data['mensaje'] ?? data['message'];
      if (mensaje is String && mensaje.isNotEmpty) {
        return _sanitizarMensajeTecnico(mensaje);
      }
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
    final code = error.response?.statusCode;
    if (code == 401) return 'Credenciales incorrectas o sesión expirada.';
    if (code == 403) return 'No tiene permisos para realizar esta operación.';
    if (code == 404) return 'El recurso solicitado no fue encontrado.';
    return 'Error de comunicación con el servidor (${code ?? 'sin respuesta'}).';
  }
  return _sanitizarMensajeTecnico(error.toString());
}

/// Traduce y limpia cualquier mensaje técnico de BD o Spring Boot a lenguaje comprensible
String _sanitizarMensajeTecnico(String raw) {
  var texto = raw.replaceFirst('Exception: ', '').trim();

  // 1. Restricciones de base de datos PostgreSQL
  if (texto.contains('repuesto_stock_actual_check') || texto.contains('stock_actual')) {
    return 'El stock ingresado no puede ser un valor negativo.';
  }
  if (texto.contains('repuesto_stock_minimo_check') || texto.contains('stock_minimo')) {
    return 'El stock mínimo debe ser un número igual o mayor a 0.';
  }
  if (texto.contains('duplicate key') || texto.contains('violates unique constraint')) {
    if (texto.contains('dni')) return 'El DNI ingresado ya se encuentra registrado.';
    if (texto.contains('correo')) return 'El correo corporativo ya pertenece a otra cuenta.';
    if (texto.contains('cod_parte')) return 'El código de repuesto ya existe en el catálogo.';
    if (texto.contains('cod_herramienta')) return 'El código de herramienta ya existe en el pañol.';
    return 'El registro ingresado ya existe en el sistema.';
  }
  if (texto.contains('violates foreign key constraint') || texto.contains('fk_')) {
    return 'No se puede completar la acción porque el registro está vinculado a otros datos.';
  }
  if (texto.contains('DataIntegrityViolationException')) {
    return 'Conflicto de integridad en los datos enviados. Verifique los valores.';
  }
  if (texto.contains('HttpMessageNotReadableException') || texto.contains('JSON parse error')) {
    return 'Formato de datos no válido. Verifique los campos ingresados.';
  }
  if (texto.contains('Bad credentials') || texto.contains('Credenciales no validas')) {
    return 'Correo o contraseña incorrectos.';
  }

  // 2. Limpieza de prefijos técnicos comunes de errores
  if (texto.startsWith('ERROR:')) {
    final partes = texto.split('\n');
    texto = partes.first.replaceFirst('ERROR:', '').trim();
  }
  if (texto.contains('[SQLState:')) {
    texto = texto.replaceAll(RegExp(r'\[SQLState:\s*\w+\]'), '').trim();
  }

  return texto;
}

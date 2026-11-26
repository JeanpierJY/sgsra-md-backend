import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../models/almacen_models.dart';

class AlmacenRemoteDataSource {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AlmacenRemoteDataSource(this._dioClient);

  Future<String> obtenerCorreoAlmacenista() async {
    return await _storage.read(key: 'correo_usuario') ?? 'marcos.baro@masterdrilling.com';
  }

  Future<DashboardStockModel> obtenerDashboard() async {
    final res = await _dioClient.dio.get('/inventario/dashboard');
    return DashboardStockModel.fromJson(res.data);
  }

  Future<List<HerramientaModel>> listarHerramientas({String? categoria}) async {
    final params = <String, dynamic>{};
    if (categoria != null && categoria != 'TODAS') {
      params['categoria'] = categoria;
    }
    final res = await _dioClient.dio.get('/inventario/herramientas', queryParameters: params);
    if (res.data is List) {
      return (res.data as List).map((x) => HerramientaModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<HerramientaModel> consultarHerramienta(String codigo) async {
    final res = await _dioClient.dio.get('/inventario/herramientas/$codigo');
    return HerramientaModel.fromJson(res.data);
  }

  Future<List<PrestamoModel>> listarPrestamos() async {
    final res = await _dioClient.dio.get('/prestamos');
    if (res.data is List) {
      return (res.data as List).map((x) => PrestamoModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<List<dynamic>> listarMecanicos() async {
    try {
      final res = await _dioClient.dio.get('/auth/usuarios', queryParameters: {'rol': 'MECANICO', 'size': 50});
      if (res.data is Map && res.data['content'] != null) {
        return List<dynamic>.from(res.data['content']);
      }
    } catch (_) {}
    return [
      {'dni': '70000001', 'nombre': 'Carlos Baro Cordillera', 'correoCorporativo': 'carlos.baro@masterdrilling.com'}
    ];
  }

  Future<String> registrarPrestamo(String dniMecanico, List<String> codigos, String firma) async {
    final correo = await obtenerCorreoAlmacenista();
    final res = await _dioClient.dio.post(
      '/prestamos',
      queryParameters: {'correoAlmacenista': correo},
      data: {
        'dniMecanico': dniMecanico,
        'codigosHerramienta': codigos,
        'firmaMecanico': firma.isEmpty ? 'FIRMA_DIGITAL_RECEPCION_OK' : firma,
      },
    );
    return res.data['dato']?.toString() ?? res.data['mensaje']?.toString() ?? 'PRES-OK';
  }

  Future<void> registrarDevolucion(String prestamoNum, String codHerramienta, String estadoFisico, String obs) async {
    final correo = await obtenerCorreoAlmacenista();
    await _dioClient.dio.post(
      '/prestamos/devolucion',
      queryParameters: {'correoAlmacenista': correo},
      data: {
        'prestamoNum': prestamoNum,
        'detalleIncidencia': obs.isEmpty ? 'Inspeccion de retorno conforme' : obs,
        'items': [
          {
            'codHerramienta': codHerramienta,
            'estadoFisico': estadoFisico,
          }
        ]
      },
    );
  }

  Future<String> reportarExtravio(String codHerramienta, String motivo) async {
    final correo = await obtenerCorreoAlmacenista();
    final res = await _dioClient.dio.post(
      '/prestamos/extravio',
      queryParameters: {'correoAlmacenista': correo},
      data: {
        'codHerramienta': codHerramienta,
        'motivoExtravio': motivo,
      },
    );
    return res.data['dato']?.toString() ?? 'Custodio registrado';
  }

  Future<void> registrarNuevaHerramienta(Map<String, dynamic> data) async {
    final correo = await obtenerCorreoAlmacenista();
    await _dioClient.dio.post(
      '/inventario/herramientas',
      queryParameters: {'correoAlmacenista': correo},
      data: data,
    );
  }

  Future<List<dynamic>> listarSolicitudesAprobadas() => listarSolicitudesPorEstado('APROBADA');

  /// [ALM-01] Solicitudes de repuestos por estado (APROBADA, APROBADA_PARCIAL, ENTREGADA...)
  Future<List<Map<String, dynamic>>> listarSolicitudesPorEstado(String estado) async {
    final res = await _dioClient.dio.get('/solicitudes/bandeja', queryParameters: {'estado': estado});
    if (res.data is! List) return [];
    return (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// [ALM-01] Detalle de la solicitud con el stock actual de cada repuesto
  Future<Map<String, dynamic>> obtenerDetalleSolicitud(String solicitudNum) async {
    final res = await _dioClient.dio.get('/solicitudes/$solicitudNum');
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// [ALM-01] Salida formal de repuestos: descuenta stock y marca la solicitud como ENTREGADA.
  /// Devuelve el mensaje del backend, que incluye el resumen de stock "[COD: antes -> después]".
  Future<String> despacharSolicitud(String solicitudNum) async {
    final correo = await obtenerCorreoAlmacenista();
    final res = await _dioClient.dio.put(
      '/solicitudes/$solicitudNum/entregar',
      queryParameters: {'correoAlmacenista': correo},
    );
    return res.data['mensaje']?.toString() ?? 'Repuestos despachados';
  }
}
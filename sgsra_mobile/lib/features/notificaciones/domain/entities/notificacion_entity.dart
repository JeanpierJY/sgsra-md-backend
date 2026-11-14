import 'package:flutter/material.dart';

/// [RF46 - RF50] Notificación persistida en la tabla `notificacion` del backend
class NotificacionEntity {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipoAlerta;
  final bool leida;
  final DateTime? fechaCreacion;

  const NotificacionEntity({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipoAlerta,
    required this.leida,
    this.fechaCreacion,
  });

  factory NotificacionEntity.fromJson(Map<String, dynamic> json) {
    return NotificacionEntity(
      id: (json['idNotificacion'] as num?)?.toInt() ?? 0,
      titulo: json['titulo']?.toString() ?? 'Notificación',
      mensaje: json['mensaje']?.toString() ?? '',
      tipoAlerta: json['tipoAlerta']?.toString().toUpperCase() ?? 'INFO',
      leida: json['leida'] == true,
      fechaCreacion: DateTime.tryParse(json['fechaCreacion']?.toString() ?? ''),
    );
  }

  NotificacionEntity marcarLeida() => NotificacionEntity(
        id: id,
        titulo: titulo,
        mensaje: mensaje,
        tipoAlerta: tipoAlerta,
        leida: true,
        fechaCreacion: fechaCreacion,
      );

  /// Ícono y color según el tipo de alerta para lectura rápida
  IconData get icono {
    if (tipoAlerta.contains('PRIORIDAD')) return Icons.priority_high_rounded;
    if (tipoAlerta.contains('EXTRAVIO')) return Icons.report_gmailerrorred_rounded;
    if (tipoAlerta.contains('MORA') || tipoAlerta.contains('VENC') || tipoAlerta.contains('RETRASO')) {
      return Icons.schedule_rounded;
    }
    if (tipoAlerta.contains('RECUPERACION') || tipoAlerta.contains('SEGURIDAD')) return Icons.lock_reset_rounded;
    if (tipoAlerta.contains('STOCK')) return Icons.inventory_2_outlined;
    if (tipoAlerta.contains('APROB') || tipoAlerta.contains('ENTREG')) return Icons.check_circle_outline_rounded;
    if (tipoAlerta.contains('RECHAZ')) return Icons.cancel_outlined;
    return Icons.notifications_none_rounded;
  }

  Color get color {
    if (tipoAlerta.contains('PRIORIDAD') || tipoAlerta.contains('EXTRAVIO') || tipoAlerta.contains('MORA') ||
        tipoAlerta.contains('RECHAZ') || tipoAlerta.contains('SEGURIDAD')) {
      return const Color(0xFFD9534F);
    }
    if (tipoAlerta.contains('STOCK') || tipoAlerta.contains('VENC') || tipoAlerta.contains('RECUPERACION')) {
      return const Color(0xFFE6A100);
    }
    if (tipoAlerta.contains('APROB') || tipoAlerta.contains('ENTREG')) return const Color(0xFF2E7D32);
    return const Color(0xFF0056B3);
  }
}

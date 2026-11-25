import 'package:flutter/foundation.dart';

/// [H-ADM-05] Canal simple para pedir desde cualquier pantalla (p. ej. el Centro de
/// Notificaciones) que el módulo Administrador abra la Bandeja con una solicitud concreta.
class NavegacionSolicitud {
  NavegacionSolicitud._();

  /// Código de la solicitud a abrir (SOL-AAAA-NNNN) o null si no hay pedido pendiente
  static final ValueNotifier<String?> pendiente = ValueNotifier<String?>(null);

  static void abrirEnBandeja(String solicitudNum) {
    // Se limpia primero para que el mismo código vuelva a notificar a los oyentes
    pendiente.value = null;
    pendiente.value = solicitudNum;
  }
}

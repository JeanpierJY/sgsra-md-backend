import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/session/session_manager.dart';
import '../../data/datasources/notificacion_remote_datasource.dart';
import '../screens/centro_notificaciones_screen.dart';

/// [RF50] Campana con badge dinámico de no leídas para el AppBar de los 3 módulos.
/// Consulta el conteo cada 30 s y al volver del Centro de Notificaciones.
/// Todas las campanas comparten el mismo contador para no repetir peticiones.
class NotificacionBell extends StatefulWidget {
  const NotificacionBell({super.key});

  @override
  State<NotificacionBell> createState() => _NotificacionBellState();
}

class _NotificacionBellState extends State<NotificacionBell> {
  static final ValueNotifier<int> _noLeidas = ValueNotifier<int>(0);
  static Timer? _timer;
  static int _instancias = 0;
  static final NotificacionRemoteDataSource _datasource = NotificacionRemoteDataSource();

  @override
  void initState() {
    super.initState();
    _instancias++;
    if (_timer == null) {
      _refrescar();
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refrescar());
    }
  }

  @override
  void dispose() {
    _instancias--;
    if (_instancias == 0) {
      _timer?.cancel();
      _timer = null;
    }
    super.dispose();
  }

  static Future<void> _refrescar() async {
    final dni = await SessionManager.dni();
    if (dni == null || dni.isEmpty) return;
    try {
      _noLeidas.value = await _datasource.contarNoLeidas(dni);
    } catch (_) {
      // Sin red: se conserva el último valor conocido
    }
  }

  Future<void> _abrirCentro() async {
    final dni = await SessionManager.dni();
    if (!mounted) return;
    if (dni == null || dni.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión no encontrada. Vuelva a iniciar sesión.')),
      );
      return;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CentroNotificacionesScreen(dni: dni)));
    _refrescar();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _noLeidas,
      builder: (context, cantidad, _) => IconButton(
        tooltip: cantidad > 0 ? '$cantidad notificaciones sin leer' : 'Notificaciones',
        onPressed: _abrirCentro,
        icon: Badge(
          isLabelVisible: cantidad > 0,
          label: Text(cantidad > 99 ? '99+' : '$cantidad'),
          backgroundColor: const Color(0xFFD9534F),
          child: Icon(cantidad > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded),
        ),
      ),
    );
  }
}

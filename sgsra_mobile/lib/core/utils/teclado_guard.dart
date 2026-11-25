import 'package:flutter/material.dart';

/// [H-GEN-10] Espacio en blanco que a veces queda en lugar del teclado.
///
/// Ocurre (de forma intermitente) cuando el teclado sigue abierto mientras se cierra un
/// diálogo/bottom sheet, se cambia de pantalla o la app pasa a segundo plano: Android no
/// siempre informa el cierre del teclado y Flutter conserva el `viewInsets.bottom` anterior,
/// dejando ese hueco blanco hasta volver a tocar un campo.
///
/// Solución: quitar el foco (cerrar el teclado) ANTES de cada transición de ruta y al salir
/// de primer plano, para que el sistema notifique el cierre a tiempo.
void cerrarTeclado() => FocusManager.instance.primaryFocus?.unfocus();

/// Observa push/pop/replace de rutas (pantallas, diálogos y bottom sheets).
class TecladoNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => cerrarTeclado();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => cerrarTeclado();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => cerrarTeclado();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => cerrarTeclado();
}

/// Cierra el teclado cuando la app deja de estar en primer plano y, además, permite
/// cerrarlo tocando cualquier zona vacía de la pantalla.
class TecladoGuard extends StatefulWidget {
  final Widget child;
  const TecladoGuard({super.key, required this.child});

  @override
  State<TecladoGuard> createState() => _TecladoGuardState();
}

class _TecladoGuardState extends State<TecladoGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) cerrarTeclado();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: cerrarTeclado,
      child: widget.child,
    );
  }
}

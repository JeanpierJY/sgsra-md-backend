import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../presentation/screens/login_screen.dart';

class SessionTimeoutWrapper extends StatefulWidget {
  final Widget child;
  final int durationMinutes;

  const SessionTimeoutWrapper({
    super.key,
    required this.child,
    this.durationMinutes = 15,
  });

  @override
  State<SessionTimeoutWrapper> createState() => _SessionTimeoutWrapperState();
}

class _SessionTimeoutWrapperState extends State<SessionTimeoutWrapper> {
  Timer? _timer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: widget.durationMinutes), _handleTimeout);
  }

  void _handleTimeout() async {
    await _apiService.cerrarSesion();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.red),
            SizedBox(width: 8),
            Text("Sesion Expirada"),
          ],
        ),
        content: const Text(
          "Su sesion ha finalizado automaticamente por inactividad prolongada por motivos de seguridad.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Entendido"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
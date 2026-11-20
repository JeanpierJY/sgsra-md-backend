import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../network/dio_client.dart';
import '../session/session_manager.dart';
import '../../features/auth/presentation/screens/mi_perfil_screen.dart';

/// [GEN-02] Acceso a "Mi Perfil" desde la esquina superior derecha de cada pantalla.
/// Muestra la foto de perfil (o las iniciales) del usuario en sesión.
class PerfilBoton extends StatefulWidget {
  const PerfilBoton({super.key});

  /// Se llama después de cambiar la foto para que todos los avatares la muestren
  static void refrescar() => _PerfilBotonState._cargado = false;

  @override
  State<PerfilBoton> createState() => _PerfilBotonState();
}

class _PerfilBotonState extends State<PerfilBoton> {
  // Compartido por todas las instancias para no repetir la consulta en cada pantalla
  static final ValueNotifier<({String iniciales, String foto})> _datos =
      ValueNotifier((iniciales: '', foto: ''));
  static bool _cargado = false;

  @override
  void initState() {
    super.initState();
    if (!_cargado) _cargar();
  }

  static Future<void> _cargar() async {
    _cargado = true;
    final nombre = (await SessionManager.nombre()) ?? '';
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final iniciales = partes.take(2).map((p) => p[0].toUpperCase()).join();
    _datos.value = (iniciales: iniciales, foto: _datos.value.foto);
    try {
      final correo = await SessionManager.correo();
      if (correo == null) return;
      final res = await DioClient().dio.get('/auth/perfil', queryParameters: {'correo': correo});
      _datos.value = (iniciales: iniciales, foto: ApiService.urlRecurso(res.data['fotoPerfilUrl']?.toString()));
    } catch (_) {
      // Sin red: se queda con las iniciales
    }
  }

  Future<void> _abrir() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const MiPerfilScreen()));
    _cargar(); // por si cambió la foto
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 2),
      child: Tooltip(
        message: 'Mi Perfil',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _abrir,
          child: ValueListenableBuilder(
            valueListenable: _datos,
            builder: (context, d, _) => Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                foregroundImage: d.foto.isNotEmpty ? NetworkImage(d.foto) : null,
                onForegroundImageError: d.foto.isNotEmpty ? (_, __) {} : null,
                child: d.iniciales.isEmpty
                    ? const Icon(Icons.person_rounded, size: 18, color: AppColors.primaryBlue)
                    : Text(d.iniciales,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

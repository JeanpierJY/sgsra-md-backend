import 'package:flutter/material.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile, DioMediaType, Options;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/utils/validators.dart';
import '../../../notificaciones/presentation/widgets/notificacion_bell.dart';
import 'login_screen.dart';

/// [RF07, REQ-01] Mi Perfil universal para Mecánico, Almacenista y Administrador.
/// DNI, nombre, correo y rol son de solo lectura; solo se edita el teléfono
/// (Mecánico y Almacenista) y la contraseña propia.
class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  final DioClient _dioClient = DioClient();
  final _telefonoCtrl = TextEditingController();
  final _telefonoKey = GlobalKey<FormState>();

  Map<String, dynamic>? _perfil;
  String? _correo;
  String? _error;
  bool _cargando = true;
  bool _guardandoTelefono = false;
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      _correo = await SessionManager.correo();
      if (_correo == null || _correo!.isEmpty) throw ServerException('Sesión no encontrada. Vuelva a iniciar sesión.');
      final res = await _dioClient.dio.get('/auth/perfil', queryParameters: {'correo': _correo});
      _perfil = Map<String, dynamic>.from(res.data as Map);
      _telefonoCtrl.text = _perfil!['telefono']?.toString() ?? '';
    } catch (e) {
      _error = mensajeDeError(e);
    }
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardarTelefono() async {
    if (!_telefonoKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _guardandoTelefono = true);
    try {
      await _dioClient.dio.put('/auth/perfil',
          queryParameters: {'correo': _correo}, data: {'telefono': _telefonoCtrl.text.trim()});
      _perfil?['telefono'] = _telefonoCtrl.text.trim();
      _snack('Teléfono actualizado correctamente');
    } catch (e) {
      _snack(mensajeDeError(e), error: true);
    }
    if (mounted) setState(() => _guardandoTelefono = false);
  }

  /// [AUT-03] Foto de perfil: Administración la compara con la selfie al recuperar la contraseña
  Future<void> _cambiarFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Foto de perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_front_rounded, color: AppColors.primaryBlue),
            title: const Text('Tomar foto'),
            subtitle: const Text('Rostro de frente y con buena luz'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBlue),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (origen == null) return;
    try {
      final foto = await ImagePicker().pickImage(
        source: origen,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (foto == null) return;
      setState(() => _subiendoFoto = true);
      final bytes = await foto.readAsBytes();
      final form = FormData.fromMap({
        'foto': MultipartFile.fromBytes(bytes, filename: 'perfil.jpg', contentType: DioMediaType('image', 'jpeg')),
      });
      final res = await _dioClient.dio.post('/auth/perfil/foto',
          queryParameters: {'correo': _correo}, data: form, options: Options(contentType: 'multipart/form-data'));
      setState(() => _perfil?['fotoPerfilUrl'] = res.data is Map ? res.data['dato'] : null);
      _snack('Foto de perfil actualizada');
    } catch (e) {
      _snack(mensajeDeError(e), error: true);
    }
    if (mounted) setState(() => _subiendoFoto = false);
  }

  Future<void> _cambiarContrasena() async {
    final cambiado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CambiarClaveDialog(correo: _correo!, dioClient: _dioClient),
    );
    if (cambiado == true) _snack('Contraseña actualizada. Úsela en su próximo inicio de sesión.');
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Desea salir de su cuenta en este dispositivo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await SessionManager.cerrar();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _snack(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: error ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  String get _rolLegible {
    switch (_perfil?['rol']?.toString()) {
      case 'ADMINISTRADOR':
        return 'Administrador / Jefatura de Taller';
      case 'ALMACENISTA':
        return 'Almacenista / Encargado de Pañol';
      default:
        return 'Mecánico';
    }
  }

  IconData get _iconoRol {
    switch (_perfil?['rol']?.toString()) {
      case 'ADMINISTRADOR':
        return Icons.admin_panel_settings_rounded;
      case 'ALMACENISTA':
        return Icons.warehouse_rounded;
      default:
        return Icons.engineering_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          const NotificacionBell(),
          IconButton(tooltip: 'Cerrar sesión', icon: const Icon(Icons.logout_rounded), onPressed: _cerrarSesion),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorCarga(mensaje: _error!, onReintentar: _cargar)
              : RefreshIndicator(onRefresh: _cargar, child: _contenido()),
    );
  }

  Widget _contenido() {
    final p = _perfil!;
    final telefonoEditable = p['telefonoEditable'] == true;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              // Cabecera
              Card(
                color: AppColors.pureWhite,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      _AvatarEditable(
                        url: ApiService.urlRecurso(p['fotoPerfilUrl']?.toString()),
                        iniciales: _iniciales(p['nombre']?.toString() ?? ''),
                        subiendo: _subiendoFoto,
                        onTap: _subiendoFoto ? null : _cambiarFoto,
                      ),
                      if ((p['fotoPerfilUrl'] ?? '').toString().isEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _subiendoFoto ? null : _cambiarFoto,
                          icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                          label: const Text('Agregar foto de perfil'),
                        ),
                        const Text(
                          'Ayuda a Administración a confirmar su identidad si olvida su contraseña.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(p['nombre']?.toString() ?? '',
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Chip(
                        avatar: Icon(_iconoRol, size: 18, color: AppColors.primaryBlue),
                        label: Text(_rolLegible),
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // [H-GEN-06] "Cerrar sesión" visible sin hacer scroll (antes quedaba al final de la pantalla)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed, side: const BorderSide(color: AppColors.errorRed)),
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.exit_to_app_rounded),
                  label: const Text('Cerrar sesión'),
                ),
              ),
              const SizedBox(height: 14),
              // Datos institucionales de solo lectura
              _Seccion(
                titulo: 'Datos institucionales',
                subtitulo: 'Solo Administración / TI puede modificar estos datos',
                icono: Icons.lock_outline_rounded,
                children: [
                  _CampoLectura(icono: Icons.badge_outlined, etiqueta: 'DNI', valor: p['dni']?.toString() ?? ''),
                  _CampoLectura(icono: Icons.person_outline_rounded, etiqueta: 'Nombre completo', valor: p['nombre']?.toString() ?? ''),
                  _CampoLectura(
                      icono: Icons.alternate_email_rounded, etiqueta: 'Correo corporativo', valor: p['correoCorporativo']?.toString() ?? ''),
                  _CampoLectura(icono: _iconoRol, etiqueta: 'Rol operativo', valor: _rolLegible),
                  if (p['sedeAsignada'] != null)
                    _CampoLectura(icono: Icons.location_on_outlined, etiqueta: 'Sede asignada', valor: p['sedeAsignada'].toString()),
                ],
              ),
              const SizedBox(height: 14),
              // Datos editables
              _Seccion(
                titulo: 'Contacto y seguridad',
                icono: Icons.edit_outlined,
                children: [
                  if (telefonoEditable)
                    Form(
                      key: _telefonoKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoCtrl,
                              keyboardType: TextInputType.phone,
                              maxLength: 9,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Teléfono móvil (9 dígitos)',
                                helperText: 'Debe iniciar con 9 y tener 9 dígitos',
                                prefixIcon: Icon(Icons.phone_iphone_rounded),
                                border: OutlineInputBorder(),
                                counterText: '',
                              ),
                              validator: AppValidators.validarTelefono,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                              onPressed: _guardandoTelefono ? null : _guardarTelefono,
                              child: _guardandoTelefono
                                  ? const SizedBox(
                                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (telefonoEditable) const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                      onPressed: _cambiarContrasena,
                      icon: const Icon(Icons.password_rounded),
                      label: const Text('Cambiar mi contraseña'),
                    ),
                  ),
                ],
              ),
              // Margen final para que el contenido no quede bajo la barra de navegación del teléfono
              SizedBox(height: 18 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  static String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final List<Widget> children;

  const _Seccion({required this.titulo, this.subtitulo, required this.icono, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.pureWhite,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ],
            ),
            if (subtitulo != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 26),
                child: Text(subtitulo!, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
              ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _CampoLectura extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _CampoLectura({required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: valor,
        readOnly: true,
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono, color: Colors.grey),
          suffixIcon: const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey),
          filled: true,
          fillColor: AppColors.backgroundGray,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}

class _ErrorCarga extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;
  const _ErrorCarga({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No se pudo cargar su perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onReintentar, icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de cambio de contraseña propia: exige la actual y confirma la nueva
class _CambiarClaveDialog extends StatefulWidget {
  final String correo;
  final DioClient dioClient;
  const _CambiarClaveDialog({required this.correo, required this.dioClient});

  @override
  State<_CambiarClaveDialog> createState() => _CambiarClaveDialogState();
}

class _CambiarClaveDialogState extends State<_CambiarClaveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  // [H-GEN-09] Cada campo tiene su propio botón de ver/ocultar
  bool _verActual = false;
  bool _verNueva = false;
  bool _verConfirmar = false;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await widget.dioClient.dio.put('/auth/cambiar-clave', queryParameters: {
        'correo': widget.correo,
        'claveActual': _actualCtrl.text,
        'claveNueva': _nuevaCtrl.text,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _enviando = false;
        _error = mensajeDeError(e);
      });
    }
  }

  InputDecoration _deco(String label, IconData icono, bool visible, VoidCallback alternar) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          tooltip: visible ? 'Ocultar contraseña' : 'Ver contraseña',
          onPressed: () => setState(alternar),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.password_rounded, color: AppColors.primaryBlue),
          SizedBox(width: 8),
          Text('Cambiar contraseña'),
        ],
      ),
      // [H-GEN-07] Contenido desplazable para que el teclado no tape los campos
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
         child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _actualCtrl,
                obscureText: !_verActual,
                decoration: _deco('Contraseña actual', Icons.lock_outline_rounded, _verActual,
                    () => _verActual = !_verActual),
                validator: (v) => (v == null || v.isEmpty) ? 'Ingrese su contraseña actual' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nuevaCtrl,
                obscureText: !_verNueva,
                decoration: _deco('Nueva contraseña', Icons.lock_reset_rounded, _verNueva,
                        () => _verNueva = !_verNueva)
                    .copyWith(helperText: 'Mínimo 8 caracteres'),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Debe tener al menos 8 caracteres';
                  if (v == _actualCtrl.text) return 'Debe ser distinta a la actual';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmarCtrl,
                obscureText: !_verConfirmar,
                decoration: _deco('Confirmar nueva contraseña', Icons.check_circle_outline_rounded, _verConfirmar,
                    () => _verConfirmar = !_verConfirmar),
                validator: (v) => v != _nuevaCtrl.text ? 'Las contraseñas no coinciden' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.errorRed)),
              ],
            ],
          ),
         ),
        ),
      ),
      actions: [
        TextButton(onPressed: _enviando ? null : () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          onPressed: _enviando ? null : _guardar,
          child: _enviando
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}


class _AvatarEditable extends StatelessWidget {
  final String url;
  final String iniciales;
  final bool subiendo;
  final VoidCallback? onTap;
  const _AvatarEditable({required this.url, required this.iniciales, required this.subiendo, this.onTap});

  Widget get textoIniciales =>
      Text(iniciales, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // [H-GEN-05] Si la foto no carga se muestran las iniciales en lugar de un círculo vacío
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.primaryBlue,
            child: url.isEmpty
                ? textoIniciales
                : ClipOval(
                    child: Image.network(
                      url,
                      key: ValueKey(url),
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progreso) => progreso == null
                          ? child
                          : const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            ),
                      errorBuilder: (_, __, ___) => textoIniciales,
                    ),
                  ),
          ),
          if (subiendo)
            const Positioned.fill(
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

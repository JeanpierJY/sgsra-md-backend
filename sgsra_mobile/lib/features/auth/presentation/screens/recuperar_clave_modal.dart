import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/validators.dart';
import '../../data/datasources/auth_remote_datasource.dart';

/// [RF06, REQ-02] Modal de recuperación de contraseña / solicitud de desbloqueo.
/// El operario valida su identidad con DNI + teléfono registrado y adjunta una selfie
/// tomada en vivo con la cámara frontal. La solicitud llega al Administrador, que la
/// acepta (asignando una clave temporal) o la deniega.
Future<void> mostrarModalRecuperarClave(BuildContext context, {bool esDesbloqueo = false}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RecuperarClaveDialog(esDesbloqueo: esDesbloqueo),
  );
}

class _RecuperarClaveDialog extends StatefulWidget {
  final bool esDesbloqueo;
  const _RecuperarClaveDialog({required this.esDesbloqueo});

  @override
  State<_RecuperarClaveDialog> createState() => _RecuperarClaveDialogState();
}

class _RecuperarClaveDialogState extends State<_RecuperarClaveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  final _datasource = AuthRemoteDataSource(DioClient());

  Uint8List? _selfie;
  bool _enviando = false;
  bool _selfieFaltante = false;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _tomarSelfie() async {
    try {
      final foto = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      setState(() {
        _selfie = bytes;
        _selfieFaltante = false;
      });
    } catch (e) {
      _snack('No se pudo abrir la cámara: ${mensajeDeError(e)}', error: true);
    }
  }

  Future<void> _enviar() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _selfieFaltante = _selfie == null);
    if (!formOk || _selfie == null) return;

    setState(() => _enviando = true);
    try {
      final mensaje = await _datasource.solicitarRecuperacion(
        dni: _dniCtrl.text,
        telefono: _telefonoCtrl.text,
        motivo: _motivoCtrl.text.isEmpty
            ? (widget.esDesbloqueo ? 'Solicitud de desbloqueo de cuenta' : null)
            : _motivoCtrl.text,
        selfieBytes: _selfie,
        selfieNombre: 'selfie_${_dniCtrl.text.trim()}.jpg',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _mostrarConfirmacion(mensaje);
    } catch (e) {
      setState(() => _enviando = false);
      _snack(mensajeDeError(e), error: true);
    }
  }

  void _mostrarConfirmacion(String mensaje) {
    final navigatorContext = Navigator.of(context, rootNavigator: true).context;
    showDialog(
      context: navigatorContext,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 48),
        title: const Text('Solicitud enviada'),
        content: Text(
          '$mensaje\n\nCuando Administración la apruebe, solicite su clave temporal al administrador '
          'y cámbiela desde "Mi Perfil" al ingresar.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _snack(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: error ? AppColors.errorRed : AppColors.primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.esDesbloqueo ? 'Solicitar Desbloqueo' : 'Recuperar Contraseña';
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Icon(widget.esDesbloqueo ? Icons.lock_open_rounded : Icons.lock_reset_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PasoInfo(
                  texto: 'Valide su identidad con los datos registrados en su ficha. '
                      'Administración revisará su solicitud y su selfie antes de asignarle una clave temporal.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dniCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (v) => (v == null || v.length != 8) ? 'El DNI debe tener 8 dígitos' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Teléfono registrado',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: AppValidators.validarTelefono,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motivoCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Motivo (opcional)',
                    hintText: widget.esDesbloqueo ? 'Ej: Olvidé mi contraseña y se bloqueó la cuenta' : 'Ej: Olvidé mi contraseña',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _SelfieSelector(
                  selfie: _selfie,
                  faltante: _selfieFaltante,
                  onTomar: _enviando ? null : _tomarSelfie,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          onPressed: _enviando ? null : _enviar,
          icon: _enviando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded),
          label: Text(_enviando ? 'Enviando...' : 'Enviar solicitud'),
        ),
      ],
    );
  }
}

class _PasoInfo extends StatelessWidget {
  final String texto;
  const _PasoInfo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 12.5, color: Colors.black87))),
        ],
      ),
    );
  }
}

class _SelfieSelector extends StatelessWidget {
  final Uint8List? selfie;
  final bool faltante;
  final VoidCallback? onTomar;

  const _SelfieSelector({required this.selfie, required this.faltante, required this.onTomar});

  @override
  Widget build(BuildContext context) {
    final colorBorde = faltante ? AppColors.errorRed : Colors.grey.shade400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTomar,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: colorBorde, width: faltante ? 1.6 : 1),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.backgroundGray,
            ),
            child: selfie == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_front_rounded, size: 44, color: faltante ? AppColors.errorRed : AppColors.primaryBlue),
                      const SizedBox(height: 8),
                      const Text('Tomar selfie de verificación', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Text('Use la cámara frontal, rostro visible', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.memory(selfie!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: FilledButton.tonalIcon(
                          onPressed: onTomar,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Repetir'),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (faltante)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text('La selfie es obligatoria para validar su identidad',
                style: TextStyle(color: AppColors.errorRed, fontSize: 12)),
          ),
      ],
    );
  }
}

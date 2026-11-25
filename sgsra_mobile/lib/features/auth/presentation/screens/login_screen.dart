import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/validators.dart';
import 'home_router.dart';
import 'recuperar_clave_modal.dart';
import '../bloc/auth_bloc.dart';

/// [RF01, RF04, RF05, RF06] Pantalla de inicio de sesión conectada al BLoC y Backend Spring Boot
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _verPassword = false;
  Timer? _timerBloqueo;
  Duration _restante = Duration.zero;

  @override
  void initState() {
    super.initState();
    _precargarCredenciales();
  }

  Future<void> _precargarCredenciales() async {
    final ultimoCorreo = await _storage.read(key: 'ultimo_correo');
    if (ultimoCorreo != null && ultimoCorreo.isNotEmpty && mounted) {
      setState(() {
        _correoController.text = ultimoCorreo;
      });
    }
  }

  @override
  void dispose() {
    _timerBloqueo?.cancel();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// [RF04] Cuenta regresiva reactiva del bloqueo temporal
  void _iniciarCuentaRegresiva(DateTime desbloqueoEn) {
    _timerBloqueo?.cancel();
    void tick() {
      final r = desbloqueoEn.difference(DateTime.now());
      if (r.isNegative || r == Duration.zero) {
        _timerBloqueo?.cancel();
        setState(() => _restante = Duration.zero);
        context.read<AuthBloc>().add(AuthBloqueoExpirado());
      } else {
        setState(() => _restante = r);
      }
    }

    tick();
    _timerBloqueo = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  String _formatear(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _autenticarBiometria() async {
    try {
      final bioCorreo = await _storage.read(key: 'biometric_correo');
      final bioPass = await _storage.read(key: 'biometric_pass');

      if (bioCorreo == null ||
          bioPass == null ||
          bioCorreo.isEmpty ||
          bioPass.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Para activar el acceso biométrico, primero inicie sesión con su correo y contraseña.'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
        return;
      }

      bool canCheck =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canCheck) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Este dispositivo no cuenta con sensor biométrico o no está configurado.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }

      bool authenticated = await _auth.authenticate(
        localizedReason: 'Escanee su huella para ingresar al sistema SGSRA-MD',
        options:
            const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );

      if (authenticated && mounted) {
        _correoController.text = bioCorreo;
        _passwordController.text = bioPass;
        context.read<AuthBloc>().add(AuthLoginRequested(bioCorreo, bioPass));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error biométrico: ${mensajeDeError(e)}'),
            backgroundColor: AppColors.errorRed),
      );
    }
  }

  void _iniciarSesion() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
                _correoController.text.trim(), _passwordController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated) {
            _timerBloqueo?.cancel();
            // Guardar credenciales para acceso biométrico y último correo
            final correo = _correoController.text.trim();
            final pass = _passwordController.text.trim();
            if (correo.isNotEmpty) {
              await _storage.write(key: 'ultimo_correo', value: correo);
            }
            if (correo.isNotEmpty && pass.isNotEmpty) {
              await _storage.write(key: 'biometric_correo', value: correo);
              await _storage.write(key: 'biometric_pass', value: pass);
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bienvenido, ${state.user.nombre}')),
            );
            // [RF02, RF08] Redirección automática de interfaz por rol
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeRouter(
                    rol: state.user.rol, nombreUsuario: state.user.nombre),
              ),
            );
          } else if (state is AuthLockedOut) {
            _passwordController.clear();
            if (state.desbloqueoEn != null) {
              _iniciarCuentaRegresiva(state.desbloqueoEn!);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final bloqueo = state is AuthLockedOut ? state : null;
          final isLocked = bloqueo != null;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // [H-GEN-02] Se retiró el botón de configuración y prueba de servidor
                        Center(
                          child: Image.asset(
                            'assets/images/logo_master_drilling.png',
                            height: 52,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.precision_manufacturing_rounded,
                              size: 44,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'MASTER DRILLING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue),
                        ),
                        const Text(
                          'Sistema de Gestión de Repuestos y Almacén',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        if (isLocked) ...[
                          _BannerBloqueo(
                            mensaje: bloqueo.message,
                            permanente: bloqueo.permanente,
                            restante: _formatear(_restante),
                            onSolicitarDesbloqueo: () =>
                                mostrarModalRecuperarClave(context,
                                    esDesbloqueo: true),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Correo corporativo',
                            hintText: 'usuario@masterdrilling.com',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: AppValidators.validarCorreo,
                          enabled: !isLocked && !isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_verPassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _iniciarSesion(),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _verPassword
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              icon: Icon(_verPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _verPassword = !_verPassword),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Ingrese su contraseña'
                              : null,
                          enabled: !isLocked && !isLoading,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => mostrarModalRecuperarClave(context),
                            child: const Text('¿Olvidó su contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.pureWhite,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed:
                              (isLocked || isLoading) ? null : _iniciarSesion,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Iniciar Sesión'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: isLocked ? null : _autenticarBiometria,
                          icon: const Icon(Icons.fingerprint,
                              color: AppColors.iconBlack),
                          label: const Text('Acceso con Huella',
                              style: TextStyle(color: AppColors.iconBlack)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// [RF04] Aviso de bloqueo: temporal con cuenta regresiva o total con opción de desbloqueo
class _BannerBloqueo extends StatelessWidget {
  final String mensaje;
  final bool permanente;
  final String restante;
  final VoidCallback onSolicitarDesbloqueo;

  const _BannerBloqueo({
    required this.mensaje,
    required this.permanente,
    required this.restante,
    required this.onSolicitarDesbloqueo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(permanente ? Icons.lock_rounded : Icons.timer_outlined,
              color: AppColors.errorRed, size: 30),
          const SizedBox(height: 6),
          Text(
            permanente ? 'Cuenta bloqueada' : 'Acceso pausado por seguridad',
            style: const TextStyle(
                color: AppColors.errorRed, fontWeight: FontWeight.bold),
          ),
          if (!permanente) ...[
            const SizedBox(height: 4),
            Text(
              restante,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorRed,
                  fontFeatures: [FontFeature.tabularFigures()]),
            ),
            const Text('Podrá intentarlo nuevamente al terminar el contador',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ] else ...[
            const SizedBox(height: 4),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
            const SizedBox(height: 10),
            FilledButton.icon(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
              onPressed: onSolicitarDesbloqueo,
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Solicitar Desbloqueo'),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'home_router.dart';
import '../bloc/auth_bloc.dart';

/// [RF01, RF05, RF06] Pantalla de inicio de sesión conectada al BLoC y Backend Spring Boot
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _autenticarBiometria() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (canCheck) {
        bool authenticated = await _auth.authenticate(
          localizedReason: 'Autentíquese para ingresar al sistema Master Drilling',
          options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
        );
        if (authenticated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autenticación biométrica exitosa.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error biométrico: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: // Busca el BlocConsumer en tu archivo login_screen.dart y actualiza el listener:
      BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bienvenido, ${state.user.nombre}')),
            );
            
            // 🚀 REDIRECCIÓN AUTOMÁTICA DE INTERFAZ POR ROL (RF02, RF08)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeRouter(
                  rol: state.user.rol,
                  nombreUsuario: state.user.nombre,
                ),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.errorRed),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is AuthLoading;
          bool isLocked = state is AuthLockedOut;

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
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'MASTER DRILLING',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: AppColors.errorRed.withOpacity(0.1),
                          child: const Text(
                            'Cuenta bloqueada temporalmente por seguridad (3 intentos fallidos). [RF06]',
                            style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _correoController,
                        decoration: const InputDecoration(labelText: 'Correo Corporativo (@masterdrilling.com)'),
                        validator: AppValidators.validarCorreo,
                        enabled: !isLocked && !isLoading,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Contraseña'),
                        validator: (v) => v == null || v.isEmpty ? 'Ingrese su contraseña' : null,
                        enabled: !isLocked && !isLoading,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.pureWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: (isLocked || isLoading)
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  // Dispara el evento real hacia Spring Boot mediante el BLoC
                                  BlocProvider.of<AuthBloc>(context).add(
                                    AuthLoginRequested(
                                      _correoController.text.trim(),
                                      _passwordController.text.trim(),
                                    ),
                                  );
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Iniciar Sesión [RF01]'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _autenticarBiometria,
                        icon: const Icon(Icons.fingerprint, color: AppColors.iconBlack),
                        label: const Text('Acceso con Huella [RF05]', style: TextStyle(color: AppColors.iconBlack)),
                      ),
                    ],
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
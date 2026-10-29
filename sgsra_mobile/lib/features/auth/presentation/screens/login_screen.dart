import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';

/// [RF01, RF05, RF06] Pantalla de inicio de sesión con soporte biométrico y manejo de bloqueos
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
  
  int _intentosFallidos = 0;
  bool _cuentaBloqueada = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // [RF05] Autenticación Biométrica (Huella / FaceID)
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
          // Redirección a dashboard según rol ([RF02])
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error biométrico: $e')),
      );
    }
  }

  void _login() {
    if (_cuentaBloqueada) return;

    if (_formKey.currentState!.validate()) {
      // Simulación de respuesta del backend con reintentos [RF06]
      bool loginExitoso = _correoController.text.contains('admin'); 

      if (!loginExitoso) {
        setState(() {
          _intentosFallidos++;
          if (_intentosFallidos >= 3) {
            _cuentaBloqueada = true; // [RF06] Bloqueo tras 3 intentos
          }
        });
      } else {
        setState(() => _intentosFallidos = 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
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
                  if (_cuentaBloqueada)
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.errorRed.withOpacity(0.1),
                      child: const Text(
                        'Cuenta bloqueada temporalmente por 5 minutos debido a 3 intentos fallidos. [RF06]',
                        style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(labelText: 'Correo Corporativo (@masterdrilling.com)'),
                    validator: AppValidators.validarCorreo,
                    enabled: !_cuentaBloqueada,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (v) => v == null || v.isEmpty ? 'Ingrese su contraseña' : null,
                    enabled: !_cuentaBloqueada,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _cuentaBloqueada ? null : _login,
                    child: const Text('Iniciar Sesión [RF01]'),
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
      ),
    );
  }
}
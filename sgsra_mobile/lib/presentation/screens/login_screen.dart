import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../bloc/auth_bloc.dart';
import 'home_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics && isDeviceSupported) {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'SGSRA-MD: Escanee su huella digital para control de accesos',
          options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
        );
        if (authenticated && mounted) {
          context.read<AuthBloc>().add(LoginRequested("mecanico@masterdrilling.com", "bypass_biometric_login")); // RF05
        }
      } else {
        _showSnackBar("El hardware biométrico no se encuentra disponible.");
      }
    } catch (e) {
      _showSnackBar("Error al procesar la huella digital.");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeRouter(role: state.role)));
          } else if (state is AuthError) {
            _showSnackBar(state.message);
          } else if (state is AuthAccountLocked) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Cuenta bloqueada por seguridad tras 3 intentos fallidos (RF06)."),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("SGSRA-MD", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text("Sistema de Gestión de Repuestos y Almacén", textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Correo Corporativo", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LoginRequested(_emailController.text, _passwordController.text)); // RF01
                },
                child: const Text("INICIAR SESIÓN"),
              ),
              const SizedBox(height: 32),
              IconButton(
                iconSize: 56,
                icon: const Icon(Icons.fingerprint, color: Color(0xFFFFB300)),
                onPressed: _authenticateWithBiometrics,
              )
            ],
          ),
        ),
      ),
    );
  }
}

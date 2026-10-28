import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'home_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController(text: "leao.chura@masterdrilling.com");
  final _passwordController = TextEditingController(text: "Admin123*");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeRouter(role: state.rol)),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.precision_manufacturing, size: 70, color: Color(0xFFFFB300)),
                    const SizedBox(height: 16),
                    const Text(
                      "MASTER DRILLING",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const Text(
                      "SGSRA-MD Sistema Operativo",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _correoController,
                      decoration: const InputDecoration(labelText: "Correo Corporativo"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Contraseña"),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                    LoginRequested(
                                      _correoController.text.trim(),
                                      _passwordController.text,
                                    ),
                                  );
                            },
                      child: state is AuthLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text("INICIAR SESION"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
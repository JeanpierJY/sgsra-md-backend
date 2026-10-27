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
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeRouter(role: state.role)));
          } else if (state is AuthAccountLocked) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.msg), backgroundColor: Colors.red));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.orange));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.precision_manufacturing, size: 72, color: Color(0xFFFFB300)),
                  const SizedBox(height: 16),
                  Text("SGSRA-MD", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text("Plataforma Móvil Logística - Master Drilling", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Correo Corporativo (RF01)", border: OutlineInputBorder()),
                    validator: (v) => (v == null || !v.contains('@masterdrilling.com')) ? 'Debe usar su correo institucional validado' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)));
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(AuthenticationSubmitRequested(
                              email: _correoController.text.trim(),
                              password: _passwordController.text,
                            ));
                          }
                        },
                        child: const Text("INICIAR SESIÓN"),
                      );
                    },
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

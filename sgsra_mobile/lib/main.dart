import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/catalogo_bloc.dart'; // ◄── Inyección del nuevo import de lógica
import 'presentation/screens/login_screen.dart';

void main() {
  // Asegura la inicialización de los canales nativos en Android (KeyStore, Cámara, etc.)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SgsraMdApp());
}

class SgsraMdApp extends StatelessWidget {
  const SgsraMdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Gestor global de autenticación, seguridad y bloqueos por intentos fallidos
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        // Gestor global del catálogo de repuestos pesados de Master Drilling (RF09, RF10)
        BlocProvider<CatalogoBloc>(
          create: (context) => CatalogoBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'SGSRA-MD',
        debugShowCheckedModeBanner: false,
        // Aplicación del tema de alto contraste para baja iluminación en mina (RNF01)
        theme: AppTheme.darkTheme,
        // Pantalla inicial del flujo logístico: Control de acceso con validación
        home: const LoginScreen(),
      ),
    );
  }
}

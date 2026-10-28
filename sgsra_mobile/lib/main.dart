import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/catalogo/catalogo_bloc.dart';
import 'presentation/bloc/inventario/inventario_bloc.dart';
import 'presentation/bloc/usuarios/usuarios_bloc.dart';
import 'presentation/screens/login_screen.dart';
import 'data/services/sincronizacion_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final SincronizacionService redSincronizador = SincronizacionService();
  redSincronizador.inicializarEscuchaRed();

  runApp(const SgsraMdFrontendApp());
}

class SgsraMdFrontendApp extends StatelessWidget {
  const SgsraMdFrontendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<CatalogoBloc>(create: (context) => CatalogoBloc()),
        BlocProvider<InventarioBloc>(create: (context) => InventarioBloc()),
        BlocProvider<UsuariosBloc>(create: (context) => UsuariosBloc()),
      ],
      child: MaterialApp(
        title: 'SGSRA-MD Master Drilling',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
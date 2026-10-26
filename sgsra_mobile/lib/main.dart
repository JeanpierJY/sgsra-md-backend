import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/catalogo_bloc.dart'; 
import 'presentation/screens/login_screen.dart';
import 'data/services/sincronizacion_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final syncService = SincronizacionService();
  syncService.inicializarMonitoreoRed();

  runApp(const SgsraMdApp());
}

class SgsraMdApp extends StatelessWidget {
  const SgsraMdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<CatalogoBloc>(create: (context) => CatalogoBloc()),
      ],
      child: MaterialApp(
        title: 'SGSRA-MD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
  }
}

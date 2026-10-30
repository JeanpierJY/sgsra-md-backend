// En home_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sgsra_mobile/core/network/dio_client.dart';
import 'package:sgsra_mobile/features/administrador/data/datasources/admin_remote_datasource.dart';
import 'package:sgsra_mobile/features/administrador/data/repositories/admin_repository_impl.dart';
import 'package:sgsra_mobile/features/administrador/domain/usecases/admin_usecases.dart';
import 'package:sgsra_mobile/features/administrador/presentation/screens/admin_main_screen.dart';
import '../../../administrador/presentation/bloc/admin_bloc.dart' show LoadBandejaEvent, AdminBloc;
import '../../../../core/constants/app_colors.dart';

class HomeRouter extends StatelessWidget {
  final String rol;
  final String nombreUsuario;

  const HomeRouter({Key? key, required this.rol, required this.nombreUsuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rolClean = rol.toUpperCase().trim();

    // [RF02, RF08] Derivación de vistas protegidas según rol operativo
    if (rolClean.contains('ADMINISTRADOR')) {
      return BlocProvider(
        create: (context) => AdminBloc(
          obtenerBandejaUseCase: ObtenerBandejaUseCase(AdminRepositoryImpl(AdminRemoteDataSource(DioClient()))),
          evaluarSolicitudUseCase: EvaluarSolicitudUseCase(AdminRepositoryImpl(AdminRemoteDataSource(DioClient()))),
        )..add(LoadBandejaEvent()),
        child: const AdminMainScreen(),
      );
    } else if (rolClean.contains('ALMACENISTA')) {
      return const PlaceholderAlmacenScreen(); // Reemplazarás con tu vista Almacén
    } else {
      return const PlaceholderMecanicoScreen(); // Reemplazarás con tu vista Mecánico
    }
  }
}

// Pantallas temporales de ejemplo para validar la transición de interfaz
class PlaceholderAdminScreen extends StatelessWidget {
  const PlaceholderAdminScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administrador - Master Drilling'), backgroundColor: AppColors.primaryBlue),
      body: const Center(child: Text('Bienvenido al Panel de Jefatura / Auditoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}

class PlaceholderAlmacenScreen extends StatelessWidget {
  const PlaceholderAlmacenScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Pañol / Almacén - Master Drilling'), backgroundColor: AppColors.primaryBlue),
      body: const Center(child: Text('Bienvenido al Control de Pañol y Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}

class PlaceholderMecanicoScreen extends StatelessWidget {
  const PlaceholderMecanicoScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Mecánico - Master Drilling'), backgroundColor: AppColors.primaryBlue),
      body: const Center(child: Text('Bienvenido al Catálogo y Requerimiento de Repuestos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    );
  }
}
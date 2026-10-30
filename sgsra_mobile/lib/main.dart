import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Capa de Red y Almacenamiento Local
  final dioClient = DioClient();
  final authRemoteDataSource = AuthRemoteDataSource(dioClient);
  final authLocalDataSource = AuthLocalDataSource();

  // 2. Repositorio (Efecto dominó cubierto con ambos datasources)
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );

  // 3. Casos de Uso
  final loginUseCase = LoginUseCase(authRepository);
  final cerrarSesionUseCase = CerrarSesionUseCase(authRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            loginUseCase: loginUseCase,
            cerrarSesionUseCase: cerrarSesionUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
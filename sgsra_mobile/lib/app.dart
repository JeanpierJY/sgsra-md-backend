import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/session/session_manager.dart';
import 'core/utils/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Drilling App',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundGray,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        useMaterial3: true,
        // GEN-03: barra superior azul con títulos e íconos blancos en toda la app
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      // [H-GEN-08] Permiten cerrar la sesión desde el cliente HTTP si la cuenta fue desactivada
      navigatorKey: SessionManager.navigatorKey,
      scaffoldMessengerKey: SessionManager.messengerKey,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
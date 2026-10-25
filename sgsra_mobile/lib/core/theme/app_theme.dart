import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFFFB300), // Amarillo maquinaria Master Drilling
      scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro para talleres (RNF01)
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFB300),
        secondary: Color(0xFF29B6F6),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFEF5350),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500), // RNF07
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        titleLarge: TextStyle(fontSize: 22, color: Color(0xFFFFB300), fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48), // RNF02: Área táctil mínima para uso con guantes
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: const Color(0xFFFFB300),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

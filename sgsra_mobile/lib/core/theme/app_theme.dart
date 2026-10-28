import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, 
      primaryColor: const Color(0xFF0D47A1), 
      scaffoldBackgroundColor: const Color(0xFFF4F6F9), 
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0D47A1),
        secondary: Color(0xFF29B6F6),
        surface: Colors.white,
        error: Color(0xFFEF5350),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}


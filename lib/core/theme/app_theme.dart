// ===========================
// 📁 core/theme/app_theme.dart
// ===========================
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF26A69A),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      dividerColor: Colors.grey[300],
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Color(0xFF424242)), // Grey 800 para contraste
        labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF26A69A),
        secondary: const Color(0xFF26A69A),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF26A69A),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      cardColor: const Color(0xFF111111),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      dividerColor: const Color(0xFF2A2A2A),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white54),
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF26A69A),
        secondary: const Color(0xFF26A69A),
        surface: const Color(0xFF111111),
        background: const Color(0xFF0A0A0A),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryLight = Color(0xFF0E7490);
  static const Color _accentAitmatov = Color(0xFFEA580C);
  static const Color _backgroundLight = Color(0xFFF5F7FA);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _error = Color(0xFFB3261E);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: _primaryLight,
          secondary: _accentAitmatov,
          surface: Colors.white,
          error: _error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1C1B1F),
        ),
        scaffoldBackgroundColor: _backgroundLight,
        textTheme: _buildTextTheme(Brightness.light),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: _backgroundLight,
          foregroundColor: Color(0xFF1C1B1F),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          backgroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primaryLight,
          secondary: _accentAitmatov,
          surface: _surfaceDark,
          error: _error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFE6E1E5),
        ),
        scaffoldBackgroundColor: _backgroundDark,
        textTheme: _buildTextTheme(Brightness.dark),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: _backgroundDark,
          foregroundColor: Color(0xFFE6E1E5),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: _surfaceDark,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: _surfaceDark,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          backgroundColor: _surfaceDark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? const Color(0xFF1C1B1F)
        : const Color(0xFFE6E1E5);
    return TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.5),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.15),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color, letterSpacing: 0.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color, letterSpacing: 0.25),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.5),
    );
  }
}

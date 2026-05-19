import 'package:flutter/material.dart';

class AppColors {
  // Primary & Brand Colors
  static const Color primary = Color(0xFF0E7490);
  static const Color accent = Color(0xFFEA580C);
  static const Color error = Color(0xFFB3261E);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color textHint = Color(0xFFB3B3B3);
  static const Color textOnPrimary = Colors.white;

  // Dialog Colors
  static const Color dialogWhite = Colors.white;
  static const Color dialogGradientEnd = Color(0xFFFAFAFA); // Colors.grey.shade50

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Icon Colors
  static Color iconWarning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.orange.shade400
          : Colors.orange.shade700;

  static Color iconError(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.red.shade400
          : Colors.red.shade700;

  // Container Colors
  static Color containerWarning(BuildContext context) =>
      Colors.orange.shade100;

  static Color containerError(BuildContext context) =>
      Colors.red.shade100;

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFE5E5E5);

  // Grey Shades
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
}

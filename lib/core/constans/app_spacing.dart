/// Система отступов на основе сетки 8px
/// Источник: Flutter Complete Guide - соблюдение сетки кратность 8px для консистентности
class AppSpacing {
  // Базовая единица - 8px
  static const double base = 8.0;

  // Padding & Margin Values (кратно 8px)
  static const double xs = 4.0;   // 0.5 * base
  static const double sm = 8.0;   // 1 * base
  static const double md = 16.0;  // 2 * base
  static const double lg = 24.0;  // 3 * base
  static const double xl = 32.0;  // 4 * base
  static const double xxl = 40.0; // 5 * base
  static const double xxxl = 48.0; // 6 * base

  // Dialog Padding
  static const double dialogPaddingDefault = 24.0;

  // Button Padding
  static const double buttonPaddingVertical = 16.0;
  static const double buttonPaddingHorizontal = 24.0;

  // Section Spacing
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 16.0;

  // Card Padding
  static const double cardPadding = 16.0;

  // App Bar Height
  static const double appBarHeight = 56.0;
}

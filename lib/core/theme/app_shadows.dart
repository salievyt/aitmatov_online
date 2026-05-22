import 'package:flutter/material.dart';

/// Система теней для визуальной иерархии
/// Источник: 5 приемов отличного UI - тени для иерархии → задачи на 15% быстрее
class AppShadows {
  // Легкие тени для карточек
  static List<BoxShadow> card(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : color.withOpacity(0.08),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  // Средние тени для поднятых элементов
  static List<BoxShadow> elevated(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.4) : color.withOpacity(0.12),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ];

  // Сильные тени для модальных окон
  static List<BoxShadow> modal(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.5) : color.withOpacity(0.16),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 12),
        ),
      ];

  // Тени для кнопок при наведении
  static List<BoxShadow> button(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : color.withOpacity(0.2),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  // Внутренние тени для вдавленных элементов
  static List<BoxShadow> inset(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.2) : color.withOpacity(0.06),
          blurRadius: 8,
          spreadRadius: -2,
          offset: const Offset(0, 2),
        ),
      ];

  // Тени для аватаров и круглых элементов
  static List<BoxShadow> avatar(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : color.withOpacity(0.2),
          blurRadius: 16,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
}

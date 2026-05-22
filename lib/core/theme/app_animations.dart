import 'package:flutter/animation.dart';

/// Константы анимаций на основе принципов UX из вики
/// Источник: 5 приемов отличного UI - анимации 200-300мс с ease-out снижают отказы на 23%
class AppAnimations {
  // Длительности анимаций (200-300мс оптимально)
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration verySlow = Duration(milliseconds: 400);

  // Кривые анимаций
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;

  // Специфичные анимации для микровзаимодействий
  static const Duration microInteraction = Duration(milliseconds: 150);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration cardHover = Duration(milliseconds: 200);

  // Анимации появления элементов
  static const Duration fadeIn = Duration(milliseconds: 300);
  static const Duration slideIn = Duration(milliseconds: 250);

  // Задержки для каскадных анимаций
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration itemDelay = Duration(milliseconds: 80);
}

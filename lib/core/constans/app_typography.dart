/// Типографическая система на основе принципов UX
/// Источник: 5 приемов отличного UI - типографика (высота строки, контраст, отступы) → +28% скорость задач
class AppTypography {
  // Font Weights
  static const int fontWeightRegular = 400;
  static const int fontWeightMedium = 500;
  static const int fontWeightSemiBold = 600;
  static const int fontWeightBold = 700;

  // Font Sizes (кратно 4px для консистентности)
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;
  static const double fontSizeDisplay = 32.0;

  // Line Heights - улучшенная читаемость
  // Для мелкого текста - больше высота строки
  static const double lineHeightTight = 1.3;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Letter Spacing - улучшенная читаемость
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;

  // Dialog Text
  static const double dialogTitleSize = 20.0;
  static const int dialogTitleWeight = 700;

  static const double dialogBodySize = 14.0;
  static const int dialogBodyWeight = 400;

  // Button Text
  static const double buttonTextSize = 16.0;
  static const int buttonTextWeight = 600;
}

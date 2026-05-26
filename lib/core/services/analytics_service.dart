import 'package:logger/logger.dart';

/// Сервис для отслеживания событий пользователей
///
/// Отслеживает ключевые события для анализа поведения:
/// - Регистрация и вход
/// - Просмотр и завершение курсов/уроков
/// - Прохождение тестов
/// - Использование мессенджера
/// - Взаимодействие с разделом Айтматова
class AnalyticsService {
  final Logger _logger;

  AnalyticsService({
    Logger? logger,
  }) : _logger = logger ?? Logger();

  // ============================================================================
  // AUTH EVENTS
  // ============================================================================

  /// Пользователь зарегистрировался
  Future<void> logSignUp({
    required String method, // email, phone, google
    required String role, // student, teacher, admin
  }) async {
    _logger.i('Analytics: sign_up (method: $method, role: $role)');
  }

  /// Пользователь вошёл
  Future<void> logLogin({
    required String method,
    required String userId,
    required String role,
  }) async {
    _logger.i('Analytics: login (method: $method, userId: $userId)');
  }

  /// Пользователь вышел
  Future<void> logLogout() async {
    _logger.i('Analytics: logout');
  }

  // ============================================================================
  // COURSE EVENTS
  // ============================================================================

  /// Пользователь открыл курс
  Future<void> logCourseView({
    required String courseId,
    required String courseName,
    required String subject,
  }) async {
    _logger.i('Analytics: course_view (id: $courseId, name: $courseName)');
  }

  /// Пользователь начал курс
  Future<void> logCourseStart({
    required String courseId,
    required String courseName,
    required String subject,
  }) async {
    _logger.i('Analytics: course_start (id: $courseId)');
  }

  /// Пользователь завершил курс
  Future<void> logCourseComplete({
    required String courseId,
    required String courseName,
    required String subject,
    required int lessonsCompleted,
    required double completionRate,
  }) async {
    _logger.i('Analytics: course_complete (id: $courseId, rate: $completionRate%)');
  }

  // ============================================================================
  // LESSON EVENTS
  // ============================================================================

  /// Пользователь открыл урок
  Future<void> logLessonView({
    required String lessonId,
    required String lessonTitle,
    required String courseId,
    required String contentType, // video, audio, text
  }) async {
    _logger.i('Analytics: lesson_view (id: $lessonId, type: $contentType)');
  }

  /// Пользователь начал урок
  Future<void> logLessonStart({
    required String lessonId,
    required String courseId,
  }) async {
    _logger.i('Analytics: lesson_start (id: $lessonId)');
  }

  /// Пользователь завершил урок
  Future<void> logLessonComplete({
    required String lessonId,
    required String courseId,
    required int durationSeconds,
  }) async {
    _logger.i('Analytics: lesson_complete (id: $lessonId, duration: ${durationSeconds}s)');
  }

  // ============================================================================
  // TEST EVENTS
  // ============================================================================

  /// Пользователь начал тест
  Future<void> logTestStart({
    required String testId,
    required String lessonId,
    required int questionsCount,
  }) async {
    _logger.i('Analytics: test_start (id: $testId)');
  }

  /// Пользователь завершил тест
  Future<void> logTestComplete({
    required String testId,
    required String lessonId,
    required int score,
    required int maxScore,
    required int correctAnswers,
    required int totalQuestions,
    required bool passed,
  }) async {
    _logger.i('Analytics: test_complete (id: $testId, score: $score/$maxScore, passed: $passed)');
  }

  // ============================================================================
  // MESSENGER EVENTS
  // ============================================================================

  /// Пользователь отправил сообщение
  Future<void> logMessageSent({
    required String groupId,
    required String messageType, // text, image, file
  }) async {
    _logger.i('Analytics: message_sent (group: $groupId, type: $messageType)');
  }

  /// Пользователь присоединился к группе
  Future<void> logGroupJoin({
    required String groupId,
    required String groupName,
  }) async {
    _logger.i('Analytics: group_join (id: $groupId)');
  }

  // ============================================================================
  // AITMATOV SECTION EVENTS
  // ============================================================================

  /// Пользователь открыл раздел Айтматова
  Future<void> logAitmatovSectionView() async {
    _logger.i('Analytics: aitmatov_section_view');
  }

  /// Пользователь открыл материал об Айтматове
  Future<void> logAitmatovContentView({
    required String contentId,
    required String contentTitle,
    required String contentType, // biography, work, philosophy
  }) async {
    _logger.i('Analytics: aitmatov_content_view (id: $contentId, type: $contentType)');
  }

  // ============================================================================
  // ENGAGEMENT EVENTS
  // ============================================================================

  /// Пользователь открыл экран
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _logger.i('Analytics: screen_view ($screenName)');
  }

  /// Пользователь провёл время в приложении (сессия)
  Future<void> logSessionDuration({
    required int durationSeconds,
  }) async {
    _logger.i('Analytics: session_duration (${durationSeconds}s)');
  }

  // ============================================================================
  // RETENTION EVENTS
  // ============================================================================

  /// Пользователь вернулся в приложение (для отслеживания retention)
  Future<void> logAppOpen() async {
    _logger.i('Analytics: app_open');
  }

  /// Пользователь достиг streak (дней подряд)
  Future<void> logStreakAchieved({
    required int streakDays,
  }) async {
    _logger.i('Analytics: streak_achieved ($streakDays days)');
  }

  // ============================================================================
  // MONETIZATION EVENTS (для будущего Freemium)
  // ============================================================================

  /// Пользователь увидел paywall
  Future<void> logPaywallView({
    required String location, // course_locked, premium_feature
  }) async {
    _logger.i('Analytics: paywall_view (location: $location)');
  }

  /// Пользователь начал процесс покупки
  Future<void> logPurchaseStart({
    required String productId,
    required double price,
    required String currency,
  }) async {
    _logger.i('Analytics: purchase_start (product: $productId, price: $price $currency)');
  }

  /// Пользователь завершил покупку
  Future<void> logPurchaseComplete({
    required String productId,
    required double price,
    required String currency,
    required String transactionId,
  }) async {
    _logger.i('Analytics: purchase_complete (product: $productId, price: $price $currency)');
  }

  // ============================================================================
  // USER PROPERTIES
  // ============================================================================

  /// Установить свойства пользователя
  Future<void> setUserProperties({
    String? grade, // класс (5-11)
    String? city,
    String? school,
    bool? isPremium,
  }) async {
    _logger.i('Analytics: user_properties updated');
  }
}

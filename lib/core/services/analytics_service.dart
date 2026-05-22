import 'package:firebase_analytics/firebase_analytics.dart';
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
  final FirebaseAnalytics _analytics;
  final Logger _logger;

  AnalyticsService({
    FirebaseAnalytics? analytics,
    Logger? logger,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _logger = logger ?? Logger();

  // ============================================================================
  // AUTH EVENTS
  // ============================================================================

  /// Пользователь зарегистрировался
  Future<void> logSignUp({
    required String method, // email, phone, google
    required String role, // student, teacher, admin
  }) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      await _analytics.setUserProperty(name: 'user_role', value: role);
      _logger.i('Analytics: sign_up (method: $method, role: $role)');
    } catch (e) {
      _logger.e('Analytics error: logSignUp', error: e);
    }
  }

  /// Пользователь вошёл
  Future<void> logLogin({
    required String method,
    required String userId,
    required String role,
  }) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.setUserId(id: userId);
      await _analytics.setUserProperty(name: 'user_role', value: role);
      _logger.i('Analytics: login (method: $method, userId: $userId)');
    } catch (e) {
      _logger.e('Analytics error: logLogin', error: e);
    }
  }

  /// Пользователь вышел
  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout');
      _logger.i('Analytics: logout');
    } catch (e) {
      _logger.e('Analytics error: logLogout', error: e);
    }
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
    try {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: courseId,
            itemName: courseName,
            itemCategory: subject,
          ),
        ],
      );
      _logger.i('Analytics: course_view (id: $courseId, name: $courseName)');
    } catch (e) {
      _logger.e('Analytics error: logCourseView', error: e);
    }
  }

  /// Пользователь начал курс
  Future<void> logCourseStart({
    required String courseId,
    required String courseName,
    required String subject,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'course_start',
        parameters: {
          'course_id': courseId,
          'course_name': courseName,
          'subject': subject,
        },
      );
      _logger.i('Analytics: course_start (id: $courseId)');
    } catch (e) {
      _logger.e('Analytics error: logCourseStart', error: e);
    }
  }

  /// Пользователь завершил курс
  Future<void> logCourseComplete({
    required String courseId,
    required String courseName,
    required String subject,
    required int lessonsCompleted,
    required double completionRate,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'course_complete',
        parameters: {
          'course_id': courseId,
          'course_name': courseName,
          'subject': subject,
          'lessons_completed': lessonsCompleted,
          'completion_rate': completionRate,
        },
      );
      _logger.i('Analytics: course_complete (id: $courseId, rate: $completionRate%)');
    } catch (e) {
      _logger.e('Analytics error: logCourseComplete', error: e);
    }
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
    try {
      await _analytics.logEvent(
        name: 'lesson_view',
        parameters: {
          'lesson_id': lessonId,
          'lesson_title': lessonTitle,
          'course_id': courseId,
          'content_type': contentType,
        },
      );
      _logger.i('Analytics: lesson_view (id: $lessonId, type: $contentType)');
    } catch (e) {
      _logger.e('Analytics error: logLessonView', error: e);
    }
  }

  /// Пользователь начал урок
  Future<void> logLessonStart({
    required String lessonId,
    required String courseId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'lesson_start',
        parameters: {
          'lesson_id': lessonId,
          'course_id': courseId,
        },
      );
      _logger.i('Analytics: lesson_start (id: $lessonId)');
    } catch (e) {
      _logger.e('Analytics error: logLessonStart', error: e);
    }
  }

  /// Пользователь завершил урок
  Future<void> logLessonComplete({
    required String lessonId,
    required String courseId,
    required int durationSeconds,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'lesson_complete',
        parameters: {
          'lesson_id': lessonId,
          'course_id': courseId,
          'duration_seconds': durationSeconds,
        },
      );
      _logger.i('Analytics: lesson_complete (id: $lessonId, duration: ${durationSeconds}s)');
    } catch (e) {
      _logger.e('Analytics error: logLessonComplete', error: e);
    }
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
    try {
      await _analytics.logEvent(
        name: 'test_start',
        parameters: {
          'test_id': testId,
          'lesson_id': lessonId,
          'questions_count': questionsCount,
        },
      );
      _logger.i('Analytics: test_start (id: $testId)');
    } catch (e) {
      _logger.e('Analytics error: logTestStart', error: e);
    }
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
    try {
      await _analytics.logEvent(
        name: 'test_complete',
        parameters: {
          'test_id': testId,
          'lesson_id': lessonId,
          'score': score,
          'max_score': maxScore,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
          'passed': passed,
          'success_rate': (correctAnswers / totalQuestions * 100).toInt(),
        },
      );
      _logger.i('Analytics: test_complete (id: $testId, score: $score/$maxScore, passed: $passed)');
    } catch (e) {
      _logger.e('Analytics error: logTestComplete', error: e);
    }
  }

  // ============================================================================
  // MESSENGER EVENTS
  // ============================================================================

  /// Пользователь отправил сообщение
  Future<void> logMessageSent({
    required String groupId,
    required String messageType, // text, image, file
  }) async {
    try {
      await _analytics.logEvent(
        name: 'message_sent',
        parameters: {
          'group_id': groupId,
          'message_type': messageType,
        },
      );
      _logger.i('Analytics: message_sent (group: $groupId, type: $messageType)');
    } catch (e) {
      _logger.e('Analytics error: logMessageSent', error: e);
    }
  }

  /// Пользователь присоединился к группе
  Future<void> logGroupJoin({
    required String groupId,
    required String groupName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'group_join',
        parameters: {
          'group_id': groupId,
          'group_name': groupName,
        },
      );
      _logger.i('Analytics: group_join (id: $groupId)');
    } catch (e) {
      _logger.e('Analytics error: logGroupJoin', error: e);
    }
  }

  // ============================================================================
  // AITMATOV SECTION EVENTS
  // ============================================================================

  /// Пользователь открыл раздел Айтматова
  Future<void> logAitmatovSectionView() async {
    try {
      await _analytics.logEvent(name: 'aitmatov_section_view');
      _logger.i('Analytics: aitmatov_section_view');
    } catch (e) {
      _logger.e('Analytics error: logAitmatovSectionView', error: e);
    }
  }

  /// Пользователь открыл материал об Айтматове
  Future<void> logAitmatovContentView({
    required String contentId,
    required String contentTitle,
    required String contentType, // biography, work, philosophy
  }) async {
    try {
      await _analytics.logEvent(
        name: 'aitmatov_content_view',
        parameters: {
          'content_id': contentId,
          'content_title': contentTitle,
          'content_type': contentType,
        },
      );
      _logger.i('Analytics: aitmatov_content_view (id: $contentId, type: $contentType)');
    } catch (e) {
      _logger.e('Analytics error: logAitmatovContentView', error: e);
    }
  }

  // ============================================================================
  // ENGAGEMENT EVENTS
  // ============================================================================

  /// Пользователь открыл экран
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      _logger.i('Analytics: screen_view ($screenName)');
    } catch (e) {
      _logger.e('Analytics error: logScreenView', error: e);
    }
  }

  /// Пользователь провёл время в приложении (сессия)
  Future<void> logSessionDuration({
    required int durationSeconds,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'session_duration',
        parameters: {
          'duration_seconds': durationSeconds,
        },
      );
      _logger.i('Analytics: session_duration (${durationSeconds}s)');
    } catch (e) {
      _logger.e('Analytics error: logSessionDuration', error: e);
    }
  }

  // ============================================================================
  // RETENTION EVENTS
  // ============================================================================

  /// Пользователь вернулся в приложение (для отслеживания retention)
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      _logger.i('Analytics: app_open');
    } catch (e) {
      _logger.e('Analytics error: logAppOpen', error: e);
    }
  }

  /// Пользователь достиг streak (дней подряд)
  Future<void> logStreakAchieved({
    required int streakDays,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'streak_achieved',
        parameters: {
          'streak_days': streakDays,
        },
      );
      _logger.i('Analytics: streak_achieved ($streakDays days)');
    } catch (e) {
      _logger.e('Analytics error: logStreakAchieved', error: e);
    }
  }

  // ============================================================================
  // MONETIZATION EVENTS (для будущего Freemium)
  // ============================================================================

  /// Пользователь увидел paywall
  Future<void> logPaywallView({
    required String location, // course_locked, premium_feature
  }) async {
    try {
      await _analytics.logEvent(
        name: 'paywall_view',
        parameters: {
          'location': location,
        },
      );
      _logger.i('Analytics: paywall_view (location: $location)');
    } catch (e) {
      _logger.e('Analytics error: logPaywallView', error: e);
    }
  }

  /// Пользователь начал процесс покупки
  Future<void> logPurchaseStart({
    required String productId,
    required double price,
    required String currency,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'purchase_start',
        parameters: {
          'product_id': productId,
          'price': price,
          'currency': currency,
        },
      );
      _logger.i('Analytics: purchase_start (product: $productId, price: $price $currency)');
    } catch (e) {
      _logger.e('Analytics error: logPurchaseStart', error: e);
    }
  }

  /// Пользователь завершил покупку
  Future<void> logPurchaseComplete({
    required String productId,
    required double price,
    required String currency,
    required String transactionId,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: price,
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: productId,
            price: price,
          ),
        ],
        transactionId: transactionId,
      );
      _logger.i('Analytics: purchase_complete (product: $productId, price: $price $currency)');
    } catch (e) {
      _logger.e('Analytics error: logPurchaseComplete', error: e);
    }
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
    try {
      if (grade != null) {
        await _analytics.setUserProperty(name: 'grade', value: grade);
      }
      if (city != null) {
        await _analytics.setUserProperty(name: 'city', value: city);
      }
      if (school != null) {
        await _analytics.setUserProperty(name: 'school', value: school);
      }
      if (isPremium != null) {
        await _analytics.setUserProperty(
          name: 'is_premium',
          value: isPremium.toString(),
        );
      }
      _logger.i('Analytics: user_properties updated');
    } catch (e) {
      _logger.e('Analytics error: setUserProperties', error: e);
    }
  }
}

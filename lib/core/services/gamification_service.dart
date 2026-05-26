import 'package:logger/logger.dart';

import '../../domain/constants/achievements.dart';
import '../../domain/entities/gamification.dart';
import '../services/analytics_service.dart';

/// Сервис для управления геймификацией
///
/// Отвечает за:
/// - Начисление XP за действия
/// - Проверку и разблокировку достижений
/// - Обновление стриков
/// - Отслеживание прогресса
class GamificationService {
  final AnalyticsService _analytics;
  final Logger _logger;

  // Счётчики для достижений (в реальном приложении хранить в БД)
  final Map<String, int> _counters = {};

  GamificationService({
    required AnalyticsService analytics,
    Logger? logger,
  })  : _analytics = analytics,
        _logger = logger ?? Logger();

  // ============================================================================
  // XP MANAGEMENT
  // ============================================================================

  /// Начислить XP за завершение урока
  Future<GamificationProgress> awardLessonComplete({
    required GamificationProgress progress,
    required bool isFirstLesson,
  }) async {
    final xp = isFirstLesson ? XpRewards.firstLesson : XpRewards.lessonComplete;
    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for lesson complete (first: $isFirstLesson)');

    // Проверить достижения
    return await _checkAchievements(
      progress: newProgress,
      action: 'lesson_complete',
    );
  }

  /// Начислить XP за завершение курса
  Future<GamificationProgress> awardCourseComplete({
    required GamificationProgress progress,
    required bool isFirstCourse,
  }) async {
    const xp = XpRewards.courseComplete;
    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for course complete (first: $isFirstCourse)');

    return await _checkAchievements(
      progress: newProgress,
      action: 'course_complete',
    );
  }

  /// Начислить XP за прохождение теста
  Future<GamificationProgress> awardTestComplete({
    required GamificationProgress progress,
    required bool isPerfect,
  }) async {
    final xp = isPerfect ? XpRewards.testPerfect : XpRewards.testPassed;
    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for test complete (perfect: $isPerfect)');

    return await _checkAchievements(
      progress: newProgress,
      action: isPerfect ? 'test_perfect' : 'test_complete',
    );
  }

  /// Начислить XP за streak
  Future<GamificationProgress> awardStreak({
    required GamificationProgress progress,
    required int streakDays,
  }) async {
    int xp = XpRewards.dailyStreak;

    if (streakDays % 30 == 0) {
      xp = XpRewards.monthStreak;
    } else if (streakDays % 7 == 0) {
      xp = XpRewards.weekStreak;
    }

    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for $streakDays day streak');

    // Track streak achievement
    await _analytics.logStreakAchieved(streakDays: streakDays);

    return await _checkAchievements(
      progress: newProgress,
      action: 'streak_$streakDays',
    );
  }

  /// Начислить XP за социальное действие
  Future<GamificationProgress> awardSocialAction({
    required GamificationProgress progress,
    required String action, // 'message_sent', 'group_joined'
  }) async {
    int xp = 0;

    switch (action) {
      case 'message_sent':
        xp = XpRewards.messageSent;
        break;
      case 'group_joined':
        xp = XpRewards.groupJoined;
        break;
    }

    if (xp == 0) return progress;

    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for social action: $action');

    return await _checkAchievements(
      progress: newProgress,
      action: action,
    );
  }

  /// Начислить XP за действие в разделе Айтматова
  Future<GamificationProgress> awardAitmatovAction({
    required GamificationProgress progress,
    required String action, // 'content_view', 'course_complete'
  }) async {
    int xp = 0;

    switch (action) {
      case 'content_view':
        xp = XpRewards.aitmatovContentView;
        break;
      case 'course_complete':
        xp = XpRewards.aitmatovCourseComplete;
        break;
    }

    if (xp == 0) return progress;

    final newProgress = progress.addXp(xp);

    _logger.i('Awarded $xp XP for Aitmatov action: $action');

    return await _checkAchievements(
      progress: newProgress,
      action: 'aitmatov_$action',
    );
  }

  // ============================================================================
  // STREAK MANAGEMENT
  // ============================================================================

  /// Обновить streak пользователя
  Future<GamificationProgress> updateStreak({
    required GamificationProgress progress,
  }) async {
    final now = DateTime.now();
    final newProgress = progress.updateStreak(now);

    // Если streak увеличился, начислить XP
    if (newProgress.currentStreak > progress.currentStreak) {
      return await awardStreak(
        progress: newProgress,
        streakDays: newProgress.currentStreak,
      );
    }

    return newProgress;
  }

  /// Проверить, нужно ли напомнить о streak
  bool shouldRemindAboutStreak(GamificationProgress progress) {
    final lastDate = progress.lastActivityDate;
    if (lastDate == null) return false;

    final now = DateTime.now();
    final hoursSinceLastActivity = now.difference(lastDate).inHours;

    // Напомнить, если прошло 20+ часов (риск потери streak)
    return hoursSinceLastActivity >= 20 && hoursSinceLastActivity < 24;
  }

  // ============================================================================
  // ACHIEVEMENTS
  // ============================================================================

  /// Проверить и разблокировать достижения
  Future<GamificationProgress> _checkAchievements({
    required GamificationProgress progress,
    required String action,
  }) async {
    var updatedProgress = progress;
    final newAchievements = <Achievement>[];

    // Инкрементировать счётчик
    _incrementCounter(action);

    // Проверить достижения по действию
    final achievementsToCheck = _getAchievementsForAction(action);

    for (final achievement in achievementsToCheck) {
      // Пропустить уже разблокированные
      if (updatedProgress.unlockedAchievements.any((a) => a.id == achievement.id)) {
        continue;
      }

      // Проверить условие
      if (_checkAchievementCondition(achievement, action)) {
        final unlockedAchievement = achievement.unlock();
        updatedProgress = updatedProgress.unlockAchievement(unlockedAchievement);
        updatedProgress = updatedProgress.addXp(achievement.xpReward);
        newAchievements.add(unlockedAchievement);

        _logger.i('Achievement unlocked: ${achievement.title} (+${achievement.xpReward} XP)');
      }
    }

    // Проверить достижения по уровню
    final levelAchievements = _checkLevelAchievements(updatedProgress);
    for (final achievement in levelAchievements) {
      if (!updatedProgress.unlockedAchievements.any((a) => a.id == achievement.id)) {
        final unlockedAchievement = achievement.unlock();
        updatedProgress = updatedProgress.unlockAchievement(unlockedAchievement);
        updatedProgress = updatedProgress.addXp(achievement.xpReward);
        newAchievements.add(unlockedAchievement);

        _logger.i('Level achievement unlocked: ${achievement.title}');
      }
    }

    return updatedProgress;
  }

  /// Получить достижения для проверки по действию
  List<Achievement> _getAchievementsForAction(String action) {
    if (action.startsWith('lesson_')) {
      return [
        Achievements.firstLesson,
        Achievements.lessons10,
        Achievements.lessons50,
        Achievements.lessons100,
      ];
    }

    if (action.startsWith('course_')) {
      return [
        Achievements.firstCourse,
        Achievements.courses5,
      ];
    }

    if (action.startsWith('test_')) {
      return [
        Achievements.perfectTest,
        Achievements.perfectTests10,
      ];
    }

    if (action.startsWith('streak_')) {
      return [
        Achievements.streak3,
        Achievements.streak7,
        Achievements.streak14,
        Achievements.streak30,
        Achievements.streak100,
      ];
    }

    if (action == 'message_sent') {
      return [
        Achievements.firstMessage,
        Achievements.messages100,
      ];
    }

    if (action == 'group_joined') {
      return [Achievements.joinGroup];
    }

    if (action.startsWith('aitmatov_')) {
      return [
        Achievements.aitmatovFirst,
        Achievements.aitmatovContent5,
        Achievements.aitmatovCourse,
        Achievements.aitmatovExpert,
      ];
    }

    return [];
  }

  /// Проверить условие достижения
  bool _checkAchievementCondition(Achievement achievement, String action) {
    final count = _getCounter(action);

    switch (achievement.id) {
      // Learning
      case 'first_lesson':
        return count >= 1;
      case 'lessons_10':
        return count >= 10;
      case 'lessons_50':
        return count >= 50;
      case 'lessons_100':
        return count >= 100;
      case 'first_course':
        return count >= 1;
      case 'courses_5':
        return count >= 5;
      case 'perfect_test':
        return count >= 1;
      case 'perfect_tests_10':
        return count >= 10;

      // Streak
      case 'streak_3':
        return action == 'streak_3' || _getCounter('streak') >= 3;
      case 'streak_7':
        return action == 'streak_7' || _getCounter('streak') >= 7;
      case 'streak_14':
        return action == 'streak_14' || _getCounter('streak') >= 14;
      case 'streak_30':
        return action == 'streak_30' || _getCounter('streak') >= 30;
      case 'streak_100':
        return action == 'streak_100' || _getCounter('streak') >= 100;

      // Social
      case 'first_message':
        return count >= 1;
      case 'messages_100':
        return count >= 100;
      case 'join_group':
        return count >= 1;

      // Aitmatov
      case 'aitmatov_first':
        return count >= 1;
      case 'aitmatov_content_5':
        return _getCounter('aitmatov_content_view') >= 5;
      case 'aitmatov_course':
        return _getCounter('aitmatov_course_complete') >= 1;

      default:
        return false;
    }
  }

  /// Проверить достижения по уровню
  List<Achievement> _checkLevelAchievements(GamificationProgress progress) {
    final achievements = <Achievement>[];

    if (progress.level >= 10) {
      achievements.add(Achievements.level10);
    }
    if (progress.level >= 25) {
      achievements.add(Achievements.level25);
    }
    if (progress.level >= 50) {
      achievements.add(Achievements.level50);
    }

    return achievements;
  }

  // ============================================================================
  // COUNTERS (В реальном приложении хранить в БД)
  // ============================================================================

  void _incrementCounter(String key) {
    _counters[key] = (_counters[key] ?? 0) + 1;
  }

  int _getCounter(String key) {
    return _counters[key] ?? 0;
  }

  /// Установить счётчик (для загрузки из БД)
  void setCounter(String key, int value) {
    _counters[key] = value;
  }

  /// Получить все счётчики
  Map<String, int> getCounters() {
    return Map.from(_counters);
  }
}

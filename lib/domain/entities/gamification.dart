import 'dart:math';

import 'package:equatable/equatable.dart';

/// Модель пользовательского прогресса в геймификации
class GamificationProgress extends Equatable {
  /// ID пользователя
  final String userId;

  /// Общее количество XP (опыта)
  final int totalXp;

  /// Текущий уровень
  final int level;

  /// XP для следующего уровня
  final int xpForNextLevel;

  /// Текущий прогресс до следующего уровня (0.0 - 1.0)
  final double progressToNextLevel;

  /// Список разблокированных достижений
  final List<Achievement> unlockedAchievements;

  /// Текущий streak (дни подряд)
  final int currentStreak;

  /// Лучший streak
  final int bestStreak;

  /// Последняя дата активности
  final DateTime? lastActivityDate;

  /// Позиция в общем рейтинге
  final int? globalRank;

  /// Позиция в рейтинге класса
  final int? classRank;

  const GamificationProgress({
    required this.userId,
    required this.totalXp,
    required this.level,
    required this.xpForNextLevel,
    required this.progressToNextLevel,
    required this.unlockedAchievements,
    required this.currentStreak,
    required this.bestStreak,
    this.lastActivityDate,
    this.globalRank,
    this.classRank,
  });

  /// Вычислить уровень по XP
  static int calculateLevel(int xp) {
    // Формула: level = floor(sqrt(xp / 100))
    // Уровень 1: 0-99 XP
    // Уровень 2: 100-399 XP
    // Уровень 3: 400-899 XP
    // Уровень 10: 10000+ XP
    return sqrt(xp / 100).floor() + 1;
  }

  /// Вычислить XP для следующего уровня
  static int calculateXpForNextLevel(int currentLevel) {
    // XP для достижения уровня N = (N-1)^2 * 100
    return currentLevel * currentLevel * 100;
  }

  /// Создать начальный прогресс для нового пользователя
  factory GamificationProgress.initial(String userId) {
    return GamificationProgress(
      userId: userId,
      totalXp: 0,
      level: 1,
      xpForNextLevel: 100,
      progressToNextLevel: 0.0,
      unlockedAchievements: [],
      currentStreak: 0,
      bestStreak: 0,
      lastActivityDate: null,
    );
  }

  /// Добавить XP и пересчитать уровень
  GamificationProgress addXp(int xp) {
    final newTotalXp = totalXp + xp;
    final newLevel = calculateLevel(newTotalXp);
    final xpForNext = calculateXpForNextLevel(newLevel);
    final currentLevelXp = calculateXpForNextLevel(newLevel - 1);
    final progress = (newTotalXp - currentLevelXp) / (xpForNext - currentLevelXp);

    return GamificationProgress(
      userId: userId,
      totalXp: newTotalXp,
      level: newLevel,
      xpForNextLevel: xpForNext,
      progressToNextLevel: progress.clamp(0.0, 1.0),
      unlockedAchievements: unlockedAchievements,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastActivityDate: lastActivityDate,
      globalRank: globalRank,
      classRank: classRank,
    );
  }

  /// Обновить streak
  GamificationProgress updateStreak(DateTime now) {
    final lastDate = lastActivityDate;
    int newStreak = currentStreak;

    if (lastDate == null) {
      // Первая активность
      newStreak = 1;
    } else {
      final daysSinceLastActivity = now.difference(lastDate).inDays;

      if (daysSinceLastActivity == 0) {
        // Та же дата - streak не меняется
        newStreak = currentStreak;
      } else if (daysSinceLastActivity == 1) {
        // Следующий день - увеличиваем streak
        newStreak = currentStreak + 1;
      } else {
        // Пропущено больше 1 дня - streak сбрасывается
        newStreak = 1;
      }
    }

    return GamificationProgress(
      userId: userId,
      totalXp: totalXp,
      level: level,
      xpForNextLevel: xpForNextLevel,
      progressToNextLevel: progressToNextLevel,
      unlockedAchievements: unlockedAchievements,
      currentStreak: newStreak,
      bestStreak: newStreak > bestStreak ? newStreak : bestStreak,
      lastActivityDate: now,
      globalRank: globalRank,
      classRank: classRank,
    );
  }

  /// Разблокировать достижение
  GamificationProgress unlockAchievement(Achievement achievement) {
    if (unlockedAchievements.any((a) => a.id == achievement.id)) {
      return this; // Уже разблокировано
    }

    return GamificationProgress(
      userId: userId,
      totalXp: totalXp,
      level: level,
      xpForNextLevel: xpForNextLevel,
      progressToNextLevel: progressToNextLevel,
      unlockedAchievements: [...unlockedAchievements, achievement],
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastActivityDate: lastActivityDate,
      globalRank: globalRank,
      classRank: classRank,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalXp,
        level,
        xpForNextLevel,
        progressToNextLevel,
        unlockedAchievements,
        currentStreak,
        bestStreak,
        lastActivityDate,
        globalRank,
        classRank,
      ];
}

/// Достижение (Badge)
class Achievement extends Equatable {
  /// ID достижения
  final String id;

  /// Название
  final String title;

  /// Описание
  final String description;

  /// Иконка (emoji или asset path)
  final String icon;

  /// Категория
  final AchievementCategory category;

  /// Награда в XP
  final int xpReward;

  /// Дата разблокировки (null если ещё не разблокировано)
  final DateTime? unlockedAt;

  /// Редкость
  final AchievementRarity rarity;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.xpReward,
    this.unlockedAt,
    this.rarity = AchievementRarity.common,
  });

  /// Разблокировать достижение
  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      category: category,
      xpReward: xpReward,
      unlockedAt: DateTime.now(),
      rarity: rarity,
    );
  }

  bool get isUnlocked => unlockedAt != null;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        category,
        xpReward,
        unlockedAt,
        rarity,
      ];
}

/// Категория достижения
enum AchievementCategory {
  learning, // Обучение
  streak, // Стрики
  social, // Социальные
  aitmatov, // Айтматов
  special, // Специальные
}

/// Редкость достижения
enum AchievementRarity {
  common, // Обычное (серое)
  rare, // Редкое (синее)
  epic, // Эпическое (фиолетовое)
  legendary, // Легендарное (золотое)
}

/// Запись в лидерборде
class LeaderboardEntry extends Equatable {
  /// Позиция
  final int rank;

  /// ID пользователя
  final String userId;

  /// Имя пользователя
  final String userName;

  /// Аватар (URL или null)
  final String? avatarUrl;

  /// Общий XP
  final int totalXp;

  /// Уровень
  final int level;

  /// Класс (для школьников)
  final String? grade;

  /// Это текущий пользователь?
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.totalXp,
    required this.level,
    this.grade,
    this.isCurrentUser = false,
  });

  @override
  List<Object?> get props => [
        rank,
        userId,
        userName,
        avatarUrl,
        totalXp,
        level,
        grade,
        isCurrentUser,
      ];
}

/// Тип лидерборда
enum LeaderboardType {
  global, // Глобальный
  classRoom, // По классу
  school, // По школе
  friends, // Друзья
}

/// Награды за действия (XP)
class XpRewards {
  // Курсы и уроки
  static const int lessonComplete = 10;
  static const int courseComplete = 50;
  static const int firstLesson = 20; // Бонус за первый урок

  // Тесты
  static const int testPassed = 15;
  static const int testPerfect = 30; // 100% правильных ответов

  // Стрики
  static const int dailyStreak = 5;
  static const int weekStreak = 50;
  static const int monthStreak = 200;

  // Социальные
  static const int messageSent = 1;
  static const int groupJoined = 5;

  // Айтматов
  static const int aitmatovContentView = 5;
  static const int aitmatovCourseComplete = 30;

  // Специальные
  static const int profileComplete = 25;
  static const int inviteFriend = 50;
}

import '../entities/gamification.dart';

/// Предопределённые достижения для Aitmatov App
class Achievements {
  // ============================================================================
  // LEARNING (Обучение)
  // ============================================================================

  static final firstLesson = Achievement(
    id: 'first_lesson',
    title: 'Первый шаг',
    description: 'Завершите свой первый урок',
    icon: '🎓',
    category: AchievementCategory.learning,
    xpReward: 20,
    rarity: AchievementRarity.common,
  );

  static final lessons10 = Achievement(
    id: 'lessons_10',
    title: 'Ученик',
    description: 'Завершите 10 уроков',
    icon: '📚',
    category: AchievementCategory.learning,
    xpReward: 50,
    rarity: AchievementRarity.common,
  );

  static final lessons50 = Achievement(
    id: 'lessons_50',
    title: 'Знаток',
    description: 'Завершите 50 уроков',
    icon: '🎯',
    category: AchievementCategory.learning,
    xpReward: 100,
    rarity: AchievementRarity.rare,
  );

  static final lessons100 = Achievement(
    id: 'lessons_100',
    title: 'Мастер обучения',
    description: 'Завершите 100 уроков',
    icon: '🏆',
    category: AchievementCategory.learning,
    xpReward: 200,
    rarity: AchievementRarity.epic,
  );

  static final firstCourse = Achievement(
    id: 'first_course',
    title: 'Целеустремлённый',
    description: 'Завершите свой первый курс',
    icon: '✅',
    category: AchievementCategory.learning,
    xpReward: 50,
    rarity: AchievementRarity.common,
  );

  static final courses5 = Achievement(
    id: 'courses_5',
    title: 'Эрудит',
    description: 'Завершите 5 курсов',
    icon: '🌟',
    category: AchievementCategory.learning,
    xpReward: 150,
    rarity: AchievementRarity.rare,
  );

  static final perfectTest = Achievement(
    id: 'perfect_test',
    title: 'Отличник',
    description: 'Пройдите тест на 100%',
    icon: '💯',
    category: AchievementCategory.learning,
    xpReward: 30,
    rarity: AchievementRarity.common,
  );

  static final perfectTests10 = Achievement(
    id: 'perfect_tests_10',
    title: 'Гений',
    description: 'Пройдите 10 тестов на 100%',
    icon: '🧠',
    category: AchievementCategory.learning,
    xpReward: 150,
    rarity: AchievementRarity.epic,
  );

  // ============================================================================
  // STREAK (Стрики)
  // ============================================================================

  static final streak3 = Achievement(
    id: 'streak_3',
    title: 'Начало пути',
    description: 'Учитесь 3 дня подряд',
    icon: '🔥',
    category: AchievementCategory.streak,
    xpReward: 30,
    rarity: AchievementRarity.common,
  );

  static final streak7 = Achievement(
    id: 'streak_7',
    title: 'Неделя силы',
    description: 'Учитесь 7 дней подряд',
    icon: '⚡',
    category: AchievementCategory.streak,
    xpReward: 70,
    rarity: AchievementRarity.rare,
  );

  static final streak14 = Achievement(
    id: 'streak_14',
    title: 'Две недели',
    description: 'Учитесь 14 дней подряд',
    icon: '💪',
    category: AchievementCategory.streak,
    xpReward: 150,
    rarity: AchievementRarity.rare,
  );

  static final streak30 = Achievement(
    id: 'streak_30',
    title: 'Месяц упорства',
    description: 'Учитесь 30 дней подряд',
    icon: '🏅',
    category: AchievementCategory.streak,
    xpReward: 300,
    rarity: AchievementRarity.epic,
  );

  static final streak100 = Achievement(
    id: 'streak_100',
    title: 'Легенда',
    description: 'Учитесь 100 дней подряд',
    icon: '👑',
    category: AchievementCategory.streak,
    xpReward: 1000,
    rarity: AchievementRarity.legendary,
  );

  // ============================================================================
  // SOCIAL (Социальные)
  // ============================================================================

  static final firstMessage = Achievement(
    id: 'first_message',
    title: 'Общительный',
    description: 'Отправьте первое сообщение',
    icon: '💬',
    category: AchievementCategory.social,
    xpReward: 10,
    rarity: AchievementRarity.common,
  );

  static final messages100 = Achievement(
    id: 'messages_100',
    title: 'Болтун',
    description: 'Отправьте 100 сообщений',
    icon: '💭',
    category: AchievementCategory.social,
    xpReward: 50,
    rarity: AchievementRarity.common,
  );

  static final joinGroup = Achievement(
    id: 'join_group',
    title: 'Командный игрок',
    description: 'Присоединитесь к группе',
    icon: '👥',
    category: AchievementCategory.social,
    xpReward: 15,
    rarity: AchievementRarity.common,
  );

  static final inviteFriend = Achievement(
    id: 'invite_friend',
    title: 'Друг познаётся',
    description: 'Пригласите друга в приложение',
    icon: '🤝',
    category: AchievementCategory.social,
    xpReward: 50,
    rarity: AchievementRarity.rare,
  );

  // ============================================================================
  // AITMATOV (Айтматов)
  // ============================================================================

  static final aitmatovFirst = Achievement(
    id: 'aitmatov_first',
    title: 'Знакомство с Айтматовым',
    description: 'Откройте раздел "Мир Айтматова"',
    icon: '📖',
    category: AchievementCategory.aitmatov,
    xpReward: 10,
    rarity: AchievementRarity.common,
  );

  static final aitmatovContent5 = Achievement(
    id: 'aitmatov_content_5',
    title: 'Читатель',
    description: 'Изучите 5 материалов об Айтматове',
    icon: '📚',
    category: AchievementCategory.aitmatov,
    xpReward: 50,
    rarity: AchievementRarity.common,
  );

  static final aitmatovCourse = Achievement(
    id: 'aitmatov_course',
    title: 'Ценитель культуры',
    description: 'Завершите курс по произведению Айтматова',
    icon: '🎭',
    category: AchievementCategory.aitmatov,
    xpReward: 100,
    rarity: AchievementRarity.rare,
  );

  static final aitmatovExpert = Achievement(
    id: 'aitmatov_expert',
    title: 'Эксперт по Айтматову',
    description: 'Завершите все курсы по Айтматову',
    icon: '🌟',
    category: AchievementCategory.aitmatov,
    xpReward: 300,
    rarity: AchievementRarity.epic,
  );

  // ============================================================================
  // SPECIAL (Специальные)
  // ============================================================================

  static final earlyBird = Achievement(
    id: 'early_bird',
    title: 'Ранняя пташка',
    description: 'Завершите урок до 8:00 утра',
    icon: '🌅',
    category: AchievementCategory.special,
    xpReward: 20,
    rarity: AchievementRarity.rare,
  );

  static final nightOwl = Achievement(
    id: 'night_owl',
    title: 'Сова',
    description: 'Завершите урок после 22:00',
    icon: '🦉',
    category: AchievementCategory.special,
    xpReward: 20,
    rarity: AchievementRarity.rare,
  );

  static final speedRunner = Achievement(
    id: 'speed_runner',
    title: 'Спидраннер',
    description: 'Завершите 5 уроков за один день',
    icon: '⚡',
    category: AchievementCategory.special,
    xpReward: 50,
    rarity: AchievementRarity.rare,
  );

  static final profileComplete = Achievement(
    id: 'profile_complete',
    title: 'Готов к старту',
    description: 'Заполните профиль полностью',
    icon: '✨',
    category: AchievementCategory.special,
    xpReward: 25,
    rarity: AchievementRarity.common,
  );

  static final level10 = Achievement(
    id: 'level_10',
    title: 'Уровень 10',
    description: 'Достигните 10 уровня',
    icon: '🎖️',
    category: AchievementCategory.special,
    xpReward: 100,
    rarity: AchievementRarity.rare,
  );

  static final level25 = Achievement(
    id: 'level_25',
    title: 'Уровень 25',
    description: 'Достигните 25 уровня',
    icon: '🏆',
    category: AchievementCategory.special,
    xpReward: 250,
    rarity: AchievementRarity.epic,
  );

  static final level50 = Achievement(
    id: 'level_50',
    title: 'Уровень 50',
    description: 'Достигните 50 уровня',
    icon: '👑',
    category: AchievementCategory.special,
    xpReward: 500,
    rarity: AchievementRarity.legendary,
  );

  // ============================================================================
  // ALL ACHIEVEMENTS
  // ============================================================================

  /// Все доступные достижения
  static List<Achievement> get all => [
        // Learning
        firstLesson,
        lessons10,
        lessons50,
        lessons100,
        firstCourse,
        courses5,
        perfectTest,
        perfectTests10,

        // Streak
        streak3,
        streak7,
        streak14,
        streak30,
        streak100,

        // Social
        firstMessage,
        messages100,
        joinGroup,
        inviteFriend,

        // Aitmatov
        aitmatovFirst,
        aitmatovContent5,
        aitmatovCourse,
        aitmatovExpert,

        // Special
        earlyBird,
        nightOwl,
        speedRunner,
        profileComplete,
        level10,
        level25,
        level50,
      ];

  /// Получить достижение по ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Получить достижения по категории
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Получить достижения по редкости
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}

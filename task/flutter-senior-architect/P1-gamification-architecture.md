# Архитектура геймификации и retention механик

**Приоритет:** P1 (High)  
**Срок:** 3-6 недель  
**Роль:** Flutter Senior Architect  
**Связанные задачи:** senior-product-manager/P1-retention-gamification.md

## Обзор
Спроектировать систему геймификации (XP, уровни, достижения, стрики, лидерборды) для повышения retention и engagement пользователей.

## Целевые метрики
- D1 Retention: 50-60%
- D7 Retention: 30-40%
- % пользователей с активным стриком (3+ дней): 40%
- Sessions per user: +50%

## Архитектура

### Domain Models

```dart
// XP и уровни
@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    required int totalXP,
    required int currentLevel,
    required int xpForNextLevel,
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastActivityDate,
    required List<String> unlockedAchievements,
    required int streakFreezes, // Доступные заморозки стрика
  }) = _UserProgress;
  
  const UserProgress._();
  
  int get xpProgress => totalXP % xpForNextLevel;
  double get levelProgress => xpProgress / xpForNextLevel;
  
  bool get isStreakActive {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastActivityDate!);
    return diff.inHours < 24;
  }
  
  bool get isStreakAtRisk {
    if (lastActivityDate == null) return true;
    final now = DateTime.now();
    final diff = now.difference(lastActivityDate!);
    return diff.inHours >= 20 && diff.inHours < 24;
  }
}

// Достижения
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String name,
    required String description,
    required String iconUrl,
    required AchievementCategory category,
    required int xpReward,
    required AchievementTier tier,
    required AchievementCriteria criteria,
  }) = _Achievement;
}

enum AchievementCategory {
  learning,
  streak,
  social,
  speed,
  cultural,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

@freezed
class AchievementCriteria with _$AchievementCriteria {
  const factory AchievementCriteria.lessonsCompleted(int count) = _LessonsCompleted;
  const factory AchievementCriteria.coursesCompleted(int count) = _CoursesCompleted;
  const factory AchievementCriteria.streakDays(int days) = _StreakDays;
  const factory AchievementCriteria.quizPerfectScore(int count) = _QuizPerfectScore;
  const factory AchievementCriteria.messagesHelped(int count) = _MessagesHelped;
}

// Лидерборды
@freezed
class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String userName,
    required String? avatarUrl,
    required int rank,
    required int score,
    required int xpThisWeek,
  }) = _LeaderboardEntry;
}

enum LeaderboardType {
  classmates,
  friends,
  global,
  course,
}

enum LeaderboardPeriod {
  weekly,
  monthly,
  allTime,
}
```

### Repository Interfaces

```dart
abstract class GamificationRepository {
  /// Получить прогресс пользователя
  Future<Either<Failure, UserProgress>> getUserProgress();
  
  /// Добавить XP
  Future<Either<Failure, XPResult>> addXP(int amount, String source);
  
  /// Обновить стрик
  Future<Either<Failure, StreakResult>> updateStreak();
  
  /// Использовать заморозку стрика
  Future<Either<Failure, Unit>> useStreakFreeze();
  
  /// Получить все достижения
  Future<Either<Failure, List<Achievement>>> getAllAchievements();
  
  /// Получить разблокированные достижения
  Future<Either<Failure, List<Achievement>>> getUnlockedAchievements();
  
  /// Проверить и разблокировать достижения
  Future<Either<Failure, List<Achievement>>> checkAndUnlockAchievements();
}

abstract class LeaderboardRepository {
  /// Получить лидерборд
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    required LeaderboardType type,
    required LeaderboardPeriod period,
    int limit = 100,
  });
  
  /// Получить позицию пользователя
  Future<Either<Failure, LeaderboardEntry>> getUserRank({
    required LeaderboardType type,
    required LeaderboardPeriod period,
  });
  
  /// Обновить счёт пользователя
  Future<Either<Failure, Unit>> updateUserScore(int xpDelta);
}

@freezed
class XPResult with _$XPResult {
  const factory XPResult({
    required int addedXP,
    required int totalXP,
    required bool leveledUp,
    int? newLevel,
    List<Achievement>? unlockedAchievements,
  }) = _XPResult;
}

@freezed
class StreakResult with _$StreakResult {
  const factory StreakResult({
    required int currentStreak,
    required bool streakContinued,
    required bool streakBroken,
    required bool milestoneReached,
    int? milestoneDay,
    int? bonusXP,
  }) = _StreakResult;
}
```

### Use Cases

```dart
class AddXPUseCase {
  final GamificationRepository _repository;
  final AnalyticsService _analytics;
  
  Future<Either<Failure, XPResult>> call(int amount, String source) async {
    final result = await _repository.addXP(amount, source);
    
    return result.fold(
      (failure) => Left(failure),
      (xpResult) {
        // Логируем добавление XP
        _analytics.logEvent(XPEarnedEvent(
          amount: amount,
          source: source,
          totalXP: xpResult.totalXP,
        ));
        
        // Если повысился уровень
        if (xpResult.leveledUp) {
          _analytics.logEvent(LevelUpEvent(
            newLevel: xpResult.newLevel!,
          ));
        }
        
        // Если разблокированы достижения
        if (xpResult.unlockedAchievements?.isNotEmpty ?? false) {
          for (final achievement in xpResult.unlockedAchievements!) {
            _analytics.logEvent(AchievementUnlockedEvent(
              achievementId: achievement.id,
              achievementName: achievement.name,
            ));
          }
        }
        
        return Right(xpResult);
      },
    );
  }
}

class UpdateStreakUseCase {
  final GamificationRepository _repository;
  final AnalyticsService _analytics;
  
  Future<Either<Failure, StreakResult>> call() async {
    final result = await _repository.updateStreak();
    
    return result.fold(
      (failure) => Left(failure),
      (streakResult) {
        if (streakResult.streakContinued) {
          _analytics.logEvent(DailyStreakContinuedEvent(
            streakCount: streakResult.currentStreak,
          ));
        }
        
        if (streakResult.streakBroken) {
          _analytics.logEvent(DailyStreakBrokenEvent(
            previousStreak: streakResult.currentStreak,
          ));
        }
        
        if (streakResult.milestoneReached) {
          _analytics.logEvent(StreakMilestoneEvent(
            milestoneDay: streakResult.milestoneDay!,
            bonusXP: streakResult.bonusXP!,
          ));
        }
        
        return Right(streakResult);
      },
    );
  }
}

class CheckAchievementsUseCase {
  final GamificationRepository _repository;
  
  Future<Either<Failure, List<Achievement>>> call() async {
    return await _repository.checkAndUnlockAchievements();
  }
}
```

### BLoC

```dart
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GetUserProgressUseCase _getUserProgress;
  final AddXPUseCase _addXP;
  final UpdateStreakUseCase _updateStreak;
  final CheckAchievementsUseCase _checkAchievements;
  
  GamificationBloc(
    this._getUserProgress,
    this._addXP,
    this._updateStreak,
    this._checkAchievements,
  ) : super(GamificationInitial()) {
    on<LoadUserProgress>(_onLoadUserProgress);
    on<AddXP>(_onAddXP);
    on<UpdateStreak>(_onUpdateStreak);
    on<CheckAchievements>(_onCheckAchievements);
  }
  
  Future<void> _onLoadUserProgress(
    LoadUserProgress event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());
    
    final result = await _getUserProgress();
    
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (progress) => emit(GamificationLoaded(progress)),
    );
  }
  
  Future<void> _onAddXP(
    AddXP event,
    Emitter<GamificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GamificationLoaded) return;
    
    final result = await _addXP(event.amount, event.source);
    
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (xpResult) {
        // Показываем celebration если повысился уровень
        if (xpResult.leveledUp) {
          emit(GamificationLevelUp(
            progress: currentState.progress.copyWith(
              totalXP: xpResult.totalXP,
              currentLevel: xpResult.newLevel!,
            ),
            newLevel: xpResult.newLevel!,
          ));
        } else {
          emit(GamificationLoaded(
            currentState.progress.copyWith(
              totalXP: xpResult.totalXP,
            ),
          ));
        }
        
        // Показываем разблокированные достижения
        if (xpResult.unlockedAchievements?.isNotEmpty ?? false) {
          emit(GamificationAchievementsUnlocked(
            progress: currentState.progress,
            achievements: xpResult.unlockedAchievements!,
          ));
        }
      },
    );
  }
}

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboardUseCase _getLeaderboard;
  final GetUserRankUseCase _getUserRank;
  
  LeaderboardBloc(
    this._getLeaderboard,
    this._getUserRank,
  ) : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }
  
  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    
    final leaderboardResult = await _getLeaderboard(
      type: event.type,
      period: event.period,
    );
    
    final userRankResult = await _getUserRank(
      type: event.type,
      period: event.period,
    );
    
    if (leaderboardResult.isRight() && userRankResult.isRight()) {
      emit(LeaderboardLoaded(
        entries: leaderboardResult.getOrElse(() => []),
        userRank: userRankResult.getOrElse(() => throw Exception()),
        type: event.type,
        period: event.period,
      ));
    } else {
      emit(LeaderboardError('Failed to load leaderboard'));
    }
  }
}
```

## Система начисления XP

### XP за действия

```dart
class XPRewards {
  // Обучение
  static const int lessonCompleted = 50;
  static const int shortLessonCompleted = 10; // <5 минут
  static const int longLessonCompleted = 100; // >30 минут
  static const int quizCompleted = 20;
  static const int quizPerfectScore = 100;
  static const int courseCompleted = 500;
  
  // Ежедневная активность
  static const int dailyLogin = 5;
  static const int firstLessonOfDay = 15;
  
  // Стрики
  static int streakBonus(int streakDays) => 10 * streakDays;
  
  // Социальные
  static const int helpClassmate = 5;
  static const int createNote = 3;
  
  // Достижения
  static const int achievementBronze = 50;
  static const int achievementSilver = 100;
  static const int achievementGold = 200;
  static const int achievementPlatinum = 500;
}

class XPCalculator {
  int calculateLessonXP(Lesson lesson, int durationSeconds) {
    if (durationSeconds < 300) {
      return XPRewards.shortLessonCompleted;
    } else if (durationSeconds > 1800) {
      return XPRewards.longLessonCompleted;
    } else {
      return XPRewards.lessonCompleted;
    }
  }
  
  int calculateQuizXP(Quiz quiz, int score, int maxScore) {
    final baseXP = XPRewards.quizCompleted;
    final perfectBonus = score == maxScore ? XPRewards.quizPerfectScore : 0;
    return baseXP + perfectBonus;
  }
  
  int calculateStreakBonusXP(int streakDays) {
    return XPRewards.streakBonus(streakDays);
  }
}
```

### Система уровней

```dart
class LevelSystem {
  static const List<int> xpThresholds = [
    0,      // Level 1
    100,    // Level 2
    250,    // Level 3
    500,    // Level 4
    1000,   // Level 5
    2000,   // Level 6
    3500,   // Level 7
    5000,   // Level 8
    7500,   // Level 9
    10000,  // Level 10
    // ... до Level 50
  ];
  
  static int getLevelFromXP(int totalXP) {
    for (int i = xpThresholds.length - 1; i >= 0; i--) {
      if (totalXP >= xpThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }
  
  static int getXPForNextLevel(int currentLevel) {
    if (currentLevel >= xpThresholds.length) {
      return xpThresholds.last + (currentLevel - xpThresholds.length + 1) * 10000;
    }
    return xpThresholds[currentLevel];
  }
  
  static String getLevelTitle(int level) {
    if (level <= 10) return 'Новичок';
    if (level <= 20) return 'Ученик';
    if (level <= 30) return 'Знаток';
    if (level <= 40) return 'Эксперт';
    if (level <= 50) return 'Мастер';
    return 'Легенда';
  }
}
```

## Система стриков

### Streak Manager

```dart
class StreakManager {
  final GamificationRepository _repository;
  final NotificationService _notificationService;
  
  Future<StreakResult> checkAndUpdateStreak() async {
    final progressResult = await _repository.getUserProgress();
    
    return progressResult.fold(
      (failure) => throw Exception(failure.message),
      (progress) async {
        final now = DateTime.now();
        final lastActivity = progress.lastActivityDate;
        
        if (lastActivity == null) {
          // Первая активность
          return await _repository.updateStreak();
        }
        
        final hoursSinceLastActivity = now.difference(lastActivity).inHours;
        
        if (hoursSinceLastActivity < 24) {
          // Стрик продолжается (активность в течение 24 часов)
          return StreakResult(
            currentStreak: progress.currentStreak,
            streakContinued: true,
            streakBroken: false,
            milestoneReached: false,
          );
        } else if (hoursSinceLastActivity < 48) {
          // Стрик под угрозой (24-48 часов)
          // Проверяем, есть ли заморозка
          if (progress.streakFreezes > 0) {
            // Используем заморозку автоматически
            await _repository.useStreakFreeze();
            return StreakResult(
              currentStreak: progress.currentStreak,
              streakContinued: true,
              streakBroken: false,
              milestoneReached: false,
            );
          } else {
            // Стрик сломан
            return await _repository.updateStreak();
          }
        } else {
          // Стрик точно сломан (>48 часов)
          return await _repository.updateStreak();
        }
      },
    );
  }
  
  Future<void> scheduleStreakReminder() async {
    final progressResult = await _repository.getUserProgress();
    
    progressResult.fold(
      (failure) => null,
      (progress) {
        if (progress.isStreakAtRisk) {
          _notificationService.scheduleNotification(
            title: '🔥 Твой стрик под угрозой!',
            body: 'Твой стрик ${progress.currentStreak} дней под угрозой! Завершите 1 урок, чтобы сохранить его',
            scheduledTime: DateTime.now().add(Duration(hours: 1)),
          );
        }
      },
    );
  }
}
```

## Система достижений

### Achievement Checker

```dart
class AchievementChecker {
  final GamificationRepository _repository;
  
  Future<List<Achievement>> checkAchievements(UserProgress progress) async {
    final allAchievements = await _repository.getAllAchievements();
    final unlockedIds = progress.unlockedAchievements;
    
    final newlyUnlocked = <Achievement>[];
    
    for (final achievement in allAchievements.getOrElse(() => [])) {
      if (unlockedIds.contains(achievement.id)) continue;
      
      final isUnlocked = _checkCriteria(achievement.criteria, progress);
      if (isUnlocked) {
        newlyUnlocked.add(achievement);
      }
    }
    
    return newlyUnlocked;
  }
  
  bool _checkCriteria(AchievementCriteria criteria, UserProgress progress) {
    return criteria.when(
      lessonsCompleted: (count) {
        // Проверяем количество завершённых уроков
        // Требует дополнительных данных из UserProgress
        return false; // TODO: implement
      },
      coursesCompleted: (count) {
        // Проверяем количество завершённых курсов
        return false; // TODO: implement
      },
      streakDays: (days) {
        return progress.currentStreak >= days;
      },
      quizPerfectScore: (count) {
        // Проверяем количество идеальных квизов
        return false; // TODO: implement
      },
      messagesHelped: (count) {
        // Проверяем количество помощи одноклассникам
        return false; // TODO: implement
      },
    );
  }
}
```

## UI Components

### XP Progress Widget

```dart
class XPProgressWidget extends StatelessWidget {
  final UserProgress progress;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${progress.currentLevel}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${progress.xpProgress}/${progress.xpForNextLevel} XP',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.levelProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
            SizedBox(height: 4),
            Text(
              LevelSystem.getLevelTitle(progress.currentLevel),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Streak Widget

```dart
class StreakWidget extends StatelessWidget {
  final UserProgress progress;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: progress.isStreakActive ? Colors.orange : Colors.grey,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${progress.currentStreak} дней подряд',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 4),
                  Text(
                    progress.isStreakAtRisk
                        ? 'Стрик под угрозой! Завершите урок сегодня'
                        : 'Продолжайте в том же духе!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progress.isStreakAtRisk ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Level Up Animation

```dart
class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/level_up.json',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 16),
            Text(
              'Поздравляем!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Вы достигли уровня $newLevel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Чек-лист внедрения

### Неделя 1-2: Core система
- [ ] Реализовать domain models
- [ ] Реализовать repositories
- [ ] Реализовать use cases
- [ ] Настроить DI
- [ ] Реализовать XP систему

### Неделя 3-4: Стрики и достижения
- [ ] Реализовать streak manager
- [ ] Реализовать achievement checker
- [ ] Интегрировать с уроками/курсами
- [ ] Настроить push-уведомления для стриков

### Неделя 5-6: Лидерборды и UI
- [ ] Реализовать leaderboard repository
- [ ] Создать UI компоненты
- [ ] Реализовать анимации (level up, achievements)
- [ ] Интегрировать с профилем пользователя

## Критерии успеха
- ✅ XP начисляется за все образовательные действия
- ✅ Стрики отслеживаются корректно
- ✅ Push-уведомления отправляются вовремя
- ✅ Достижения разблокируются автоматически
- ✅ Лидерборды обновляются в реальном времени
- ✅ Анимации работают плавно (60 FPS)

# Руководство по интеграции геймификации

## ✅ Что уже создано

### 1. Модели данных
- ✅ `GamificationProgress` — прогресс пользователя (XP, уровень, streak)
- ✅ `Achievement` — достижения
- ✅ `LeaderboardEntry` — запись в лидерборде
- ✅ `XpRewards` — константы наград за действия

### 2. Достижения
- ✅ 27 предопределённых достижений в `Achievements`
- ✅ 5 категорий: Learning, Streak, Social, Aitmatov, Special
- ✅ 4 уровня редкости: Common, Rare, Epic, Legendary

### 3. Сервисы
- ✅ `GamificationService` — управление XP, достижениями, стриками
- ✅ Зарегистрирован в DI

### 4. UI компоненты
- ✅ `GamificationProgressCard` — карточка с прогрессом
- ✅ `CompactLevelBadge` — компактный бейдж уровня
- ✅ `StreakWidget` — виджет streak
- ✅ `XpGainAnimation` — анимация получения XP
- ✅ `AchievementsScreen` — экран достижений
- ✅ `LeaderboardScreen` — экран лидерборда

## 📋 Что нужно интегрировать

### 1. Backend API (критично)

Нужно создать API endpoints для:

```
GET  /api/gamification/progress/:userId
POST /api/gamification/award-xp
POST /api/gamification/update-streak
GET  /api/gamification/achievements/:userId
GET  /api/gamification/leaderboard?type=global|class|school
```

**Структура БД:**

```sql
-- Таблица прогресса пользователей
CREATE TABLE user_gamification (
  user_id VARCHAR PRIMARY KEY,
  total_xp INT DEFAULT 0,
  level INT DEFAULT 1,
  current_streak INT DEFAULT 0,
  best_streak INT DEFAULT 0,
  last_activity_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Таблица разблокированных достижений
CREATE TABLE user_achievements (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR NOT NULL,
  achievement_id VARCHAR NOT NULL,
  unlocked_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- Таблица счётчиков для достижений
CREATE TABLE user_counters (
  user_id VARCHAR NOT NULL,
  counter_key VARCHAR NOT NULL,
  counter_value INT DEFAULT 0,
  PRIMARY KEY(user_id, counter_key)
);

-- Индексы для лидерборда
CREATE INDEX idx_gamification_xp ON user_gamification(total_xp DESC);
CREATE INDEX idx_gamification_level ON user_gamification(level DESC);
```

### 2. Интеграция в существующие экраны

#### Home Screen
```dart
import '../../core/services/gamification_service.dart';
import '../../core/presentation/widgets/gamification_widgets.dart';

class HomeScreen extends StatelessWidget {
  final _gamification = getIt<GamificationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          // Показать уровень и XP
          FutureBuilder<GamificationProgress>(
            future: _loadProgress(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return CompactLevelBadge(
                progress: snapshot.data!,
                onTap: () {
                  // Открыть экран прогресса
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamificationProgressScreen(
                        progress: snapshot.data!,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Карточка прогресса
          FutureBuilder<GamificationProgress>(
            future: _loadProgress(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return GamificationProgressCard(
                progress: snapshot.data!,
                onTap: () {
                  // Открыть детальный экран
                },
              );
            },
          ),
          // Остальной контент
        ],
      ),
    );
  }

  Future<GamificationProgress> _loadProgress() async {
    // TODO: Загрузить из API
    return GamificationProgress.initial('user_id');
  }
}
```

#### Lesson Screen (начисление XP)
```dart
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Course course;
  // ...
}

class _LessonScreenState extends State<LessonScreen> {
  final _gamification = getIt<GamificationService>();
  final _analytics = getIt<AnalyticsService>();
  GamificationProgress? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    // TODO: Загрузить прогресс из API
    final progress = await _api.getGamificationProgress(userId);
    setState(() => _progress = progress);
  }

  Future<void> _onLessonComplete() async {
    if (_progress == null) return;

    // Начислить XP
    final newProgress = await _gamification.awardLessonComplete(
      progress: _progress!,
      isFirstLesson: _isFirstLesson(),
    );

    // Обновить streak
    final updatedProgress = await _gamification.updateStreak(
      progress: newProgress,
    );

    // Сохранить в API
    await _api.updateGamificationProgress(updatedProgress);

    // Показать анимацию XP
    _showXpAnimation(XpRewards.lessonComplete);

    // Проверить новые достижения
    final newAchievements = updatedProgress.unlockedAchievements
        .where((a) => !_progress!.unlockedAchievements.contains(a))
        .toList();

    if (newAchievements.isNotEmpty) {
      _showAchievementDialog(newAchievements.first);
    }

    setState(() => _progress = updatedProgress);

    // Track analytics
    _analytics.logLessonComplete(
      lessonId: widget.lesson.id,
      courseId: widget.course.id,
      durationSeconds: _getDuration(),
    );
  }

  void _showXpAnimation(int xp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: XpGainAnimation(
          xp: xp,
          onComplete: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showAchievementDialog(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Достижение разблокировано!',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(achievement.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '+${achievement.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отлично!'),
          ),
        ],
      ),
    );
  }
}
```

#### Profile Screen (показать достижения)
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // ... профиль пользователя
          
          // Карточка геймификации
          FutureBuilder<GamificationProgress>(
            future: _loadProgress(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return GamificationProgressCard(
                progress: snapshot.data!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AchievementsScreen(
                        progress: snapshot.data!,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Кнопка "Рейтинг"
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Рейтинг'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(
                    entries: [], // TODO: Загрузить из API
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 3. Streak напоминания (push-уведомления)

```dart
// В main.dart или app lifecycle
class _AitmatovAppState extends State<AitmatovApp> with WidgetsBindingObserver {
  final _gamification = getIt<GamificationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStreak();
  }

  Future<void> _checkStreak() async {
    final progress = await _api.getGamificationProgress(userId);
    
    // Проверить, нужно ли напомнить о streak
    if (_gamification.shouldRemindAboutStreak(progress)) {
      // Отправить push-уведомление
      await _pushService.sendNotification(
        title: '🔥 Не потеряй свой streak!',
        body: 'Ты учишься ${progress.currentStreak} дней подряд. Пройди хотя бы один урок сегодня!',
      );
    }
  }
}
```

### 4. Ежедневные цели (Daily Goals)

Создать виджет с ежедневными целями:

```dart
class DailyGoalsWidget extends StatelessWidget {
  final int lessonsCompleted;
  final int dailyGoal;

  const DailyGoalsWidget({
    required this.lessonsCompleted,
    this.dailyGoal = 3, // По умолчанию 3 урока в день
  });

  @override
  Widget build(BuildContext context) {
    final progress = lessonsCompleted / dailyGoal;
    final isComplete = lessonsCompleted >= dailyGoal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.flag,
                  color: isComplete ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ежедневная цель',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$lessonsCompleted / $dailyGoal уроков',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎯 Приоритеты внедрения

### P0 (Критично — сделать сразу)
1. ✅ Создать модели данных — **ГОТОВО**
2. ✅ Создать GamificationService — **ГОТОВО**
3. ✅ Создать UI компоненты — **ГОТОВО**
4. ⏳ Создать Backend API для геймификации
5. ⏳ Интегрировать начисление XP в Lesson/Course screens
6. ⏳ Показать прогресс на Home screen

### P1 (Важно — сделать в течение недели)
7. ⏳ Создать экран с детальным прогрессом
8. ⏳ Интегрировать streak обновление
9. ⏳ Добавить анимации получения XP и достижений
10. ⏳ Создать лидерборд (backend + frontend)

### P2 (Желательно — сделать в течение месяца)
11. ⏳ Добавить ежедневные цели (Daily Goals)
12. ⏳ Добавить еженедельные челленджи
13. ⏳ Добавить сезонные события
14. ⏳ Добавить возможность делиться достижениями

## 📊 Метрики для отслеживания

После внедрения геймификации отслеживайте:

### Engagement
- **DAU / MAU** — должен вырасти на 20-30%
- **Session Length** — должна увеличиться на 15-25%
- **Lessons per Session** — должно увеличиться на 30-40%

### Retention
- **D1 Retention** — цель: 50-60% (с геймификацией)
- **D7 Retention** — цель: 30-40%
- **D30 Retention** — цель: 20-25%

### Gamification-specific
- **% пользователей с streak > 3** — цель: 40%+
- **% пользователей с streak > 7** — цель: 20%+
- **Среднее количество разблокированных достижений** — цель: 5-7
- **% пользователей, открывших экран достижений** — цель: 60%+
- **% пользователей, открывших лидерборд** — цель: 40%+

## 🚀 A/B тестирование

Рекомендуется протестировать:

### Тест 1: XP награды
- **Группа A:** Текущие награды (10 XP за урок, 50 за курс)
- **Группа B:** Увеличенные награды (15 XP за урок, 75 за курс)
- **Метрика:** Lessons completed per user

### Тест 2: Streak напоминания
- **Группа A:** Напоминание в 20:00
- **Группа B:** Напоминание в 18:00
- **Метрика:** Streak retention rate

### Тест 3: Ежедневная цель
- **Группа A:** 3 урока в день
- **Группа B:** 1 урок в день
- **Метрика:** Daily goal completion rate

## 📝 Чеклист внедрения

- [x] Создать модели данных (GamificationProgress, Achievement, etc.)
- [x] Создать предопределённые достижения (27 штук)
- [x] Создать GamificationService
- [x] Зарегистрировать в DI
- [x] Создать UI компоненты (карточки, виджеты, экраны)
- [ ] Создать Backend API
- [ ] Создать БД таблицы
- [ ] Интегрировать в Lesson/Course screens
- [ ] Интегрировать в Home screen
- [ ] Интегрировать в Profile screen
- [ ] Добавить анимации XP и достижений
- [ ] Создать лидерборд
- [ ] Настроить streak напоминания
- [ ] Добавить ежедневные цели
- [ ] Протестировать все сценарии
- [ ] Запустить A/B тесты

## 🎨 Дизайн рекомендации

### Цвета по редкости достижений
- **Common (Обычное):** Серый (#9E9E9E)
- **Rare (Редкое):** Синий (#2196F3)
- **Epic (Эпическое):** Фиолетовый (#9C27B0)
- **Legendary (Легендарное):** Золотой (#FFC107)

### Анимации
- **XP получение:** Fade in + Slide up (1.5s)
- **Level up:** Конфетти + звук (2s)
- **Achievement unlock:** Modal с bounce эффектом (2s)
- **Streak fire:** Pulse анимация (бесконечная)

### Звуки (опционально)
- **XP получение:** Короткий "ding" звук
- **Level up:** Фанфары
- **Achievement unlock:** Триумфальный звук
- **Streak milestone:** Звук огня

## 🔗 Связанные задачи

- Task #3: Внедрить механику стриков (streak) — частично покрыто
- Task #4: Настроить push-уведомления — нужно для streak напоминаний
- Task #1: Firebase Analytics — отслеживать gamification events

## 📚 Полезные ресурсы

- [Duolingo Gamification](https://blog.duolingo.com/gamification/) — лучшие практики
- [Habitica](https://habitica.com/) — пример геймификации привычек
- [Khan Academy Badges](https://www.khanacademy.org/badges) — система достижений

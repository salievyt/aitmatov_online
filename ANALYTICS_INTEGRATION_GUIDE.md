# Руководство по интеграции аналитики

## ✅ Уже интегрировано

### AuthBloc
- ✅ `logSignUp()` — при регистрации
- ✅ `logLogin()` — при входе
- ✅ `logLogout()` — при выходе

## 📋 Нужно интегрировать

### 1. Course Screens

#### `courses_list_screen.dart`
```dart
import '../../../core/services/analytics_service.dart';
import '../../../app/di.dart';

class CoursesListScreen extends StatefulWidget {
  // ...
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    // Track screen view
    _analytics.logScreenView(screenName: 'courses_list');
  }
}
```

#### `course_screen.dart`
```dart
class CourseScreen extends StatefulWidget {
  final Course course;
  // ...
}

class _CourseScreenState extends State<CourseScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    // Track course view
    _analytics.logCourseView(
      courseId: widget.course.id,
      courseName: widget.course.title,
      subject: widget.course.subject,
    );
  }

  void _onStartCourse() {
    // Track course start
    _analytics.logCourseStart(
      courseId: widget.course.id,
      courseName: widget.course.title,
      subject: widget.course.subject,
    );
    // ... navigate to first lesson
  }
}
```

### 2. Lesson Screens

#### `lesson_screen.dart`
```dart
class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Course course;
  // ...
}

class _LessonScreenState extends State<LessonScreen> {
  final _analytics = getIt<AnalyticsService>();
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    // Track lesson view
    _analytics.logLessonView(
      lessonId: widget.lesson.id,
      lessonTitle: widget.lesson.title,
      courseId: widget.course.id,
      contentType: _getContentType(widget.lesson),
    );

    // Track lesson start
    _analytics.logLessonStart(
      lessonId: widget.lesson.id,
      courseId: widget.course.id,
    );
  }

  String _getContentType(Lesson lesson) {
    if (lesson.videoUrl != null) return 'video';
    if (lesson.audioUrl != null) return 'audio';
    return 'text';
  }

  void _onLessonComplete() {
    final duration = DateTime.now().difference(_startTime!).inSeconds;

    // Track lesson complete
    _analytics.logLessonComplete(
      lessonId: widget.lesson.id,
      courseId: widget.course.id,
      durationSeconds: duration,
    );

    // ... mark as complete, navigate to next
  }
}
```

### 3. Test Screens

#### `test_screen.dart`
```dart
class TestScreen extends StatefulWidget {
  final Test test;
  final Lesson lesson;
  // ...
}

class _TestScreenState extends State<TestScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();

    // Track test start
    _analytics.logTestStart(
      testId: widget.test.id,
      lessonId: widget.lesson.id,
      questionsCount: widget.test.questions.length,
    );
  }

  void _onTestSubmit() {
    final score = _calculateScore();
    final correctAnswers = _countCorrectAnswers();
    final passed = score >= widget.test.passingScore;

    // Track test complete
    _analytics.logTestComplete(
      testId: widget.test.id,
      lessonId: widget.lesson.id,
      score: score,
      maxScore: widget.test.maxScore,
      correctAnswers: correctAnswers,
      totalQuestions: widget.test.questions.length,
      passed: passed,
    );

    // ... show results
  }
}
```

### 4. Messenger Screens

#### `messenger_screen.dart`
```dart
class MessengerScreen extends StatefulWidget {
  // ...
}

class _MessengerScreenState extends State<MessengerScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView(screenName: 'messenger');
  }

  void _onSendMessage(String groupId, String messageType) {
    // Track message sent
    _analytics.logMessageSent(
      groupId: groupId,
      messageType: messageType, // 'text', 'image', 'file'
    );

    // ... send message
  }

  void _onJoinGroup(String groupId, String groupName) {
    // Track group join
    _analytics.logGroupJoin(
      groupId: groupId,
      groupName: groupName,
    );

    // ... join group
  }
}
```

### 5. Aitmatov Section

#### `aitmatov_section_screen.dart`
```dart
class AitmatovSectionScreen extends StatefulWidget {
  // ...
}

class _AitmatovSectionScreenState extends State<AitmatovSectionScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    // Track Aitmatov section view
    _analytics.logAitmatovSectionView();
  }
}
```

#### `aitmatov_content_screen.dart`
```dart
class AitmatovContentScreen extends StatefulWidget {
  final AitmatovContent content;
  // ...
}

class _AitmatovContentScreenState extends State<AitmatovContentScreen> {
  final _analytics = getIt<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    // Track content view
    _analytics.logAitmatovContentView(
      contentId: widget.content.id,
      contentTitle: widget.content.title,
      contentType: widget.content.type, // 'biography', 'work', 'philosophy'
    );
  }
}
```

### 6. App Lifecycle (для retention)

#### `app.dart` или `main.dart`
```dart
class AitmatovApp extends StatefulWidget {
  // ...
}

class _AitmatovAppState extends State<AitmatovApp> with WidgetsBindingObserver {
  final _analytics = getIt<AnalyticsService>();
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();

    // Track app open
    _analytics.logAppOpen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background - track session duration
      if (_sessionStart != null) {
        final duration = DateTime.now().difference(_sessionStart!).inSeconds;
        _analytics.logSessionDuration(durationSeconds: duration);
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground
      _sessionStart = DateTime.now();
      _analytics.logAppOpen();
    }
  }
}
```

### 7. User Properties (при регистрации/обновлении профиля)

#### `profile_screen.dart` или `onboarding_screen.dart`
```dart
void _onProfileUpdate() {
  // Set user properties
  _analytics.setUserProperties(
    grade: user.grade, // '5', '6', '7', ..., '11'
    city: user.city, // 'Бишкек', 'Ош', 'Джалал-Абад'
    school: user.school,
    isPremium: user.isPremium, // для будущего
  );
}
```

## 🎯 Приоритеты интеграции

### P0 (Критично — сделать сразу)
1. ✅ Auth events (login, signup, logout) — **ГОТОВО**
2. ⏳ Course events (view, start, complete)
3. ⏳ Lesson events (view, start, complete)
4. ⏳ App lifecycle (app_open, session_duration)

### P1 (Важно — сделать в течение недели)
5. ⏳ Test events (start, complete)
6. ⏳ Screen views (все основные экраны)
7. ⏳ User properties (grade, city, school)

### P2 (Желательно — сделать в течение месяца)
8. ⏳ Messenger events (message_sent, group_join)
9. ⏳ Aitmatov section events
10. ⏳ Monetization events (для будущего paywall)

## 📊 Проверка работы аналитики

### 1. Debug Mode

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.aitmatov.app
adb logcat -s FA
```

**iOS:**
В Xcode: Edit Scheme → Run → Arguments → Add `-FIRAnalyticsDebugEnabled`

### 2. Firebase Console

1. Перейти в Firebase Console → Analytics → DebugView
2. Запустить приложение в debug mode
3. Выполнить действия (login, view course, complete lesson)
4. Проверить, что события появляются в DebugView в реальном времени

### 3. Events в Production

События появляются в Firebase Console → Analytics → Events в течение 24 часов.

## 🔍 Ключевые метрики для отслеживания

После интеграции аналитики отслеживайте:

### Acquisition
- `sign_up` — количество регистраций
- Источники трафика (organic, referral, etc.)

### Activation
- `course_view` → `course_start` → `lesson_complete` (первый урок)
- Time to First Lesson (TTFL)

### Engagement
- DAU / MAU
- `session_duration` — среднее время в приложении
- `lesson_complete` — количество завершённых уроков
- `test_complete` — количество пройденных тестов

### Retention
- D1, D7, D30 Retention
- `app_open` — возвраты в приложение
- `streak_achieved` — дни подряд (после внедрения стриков)

### Monetization (для будущего)
- `paywall_view` — просмотры paywall
- `purchase_start` → `purchase_complete` — конверсия в покупку
- Revenue, ARPU, LTV

## 📝 Чеклист интеграции

- [x] Добавить `firebase_core` и `firebase_analytics` в `pubspec.yaml`
- [x] Создать `AnalyticsService`
- [x] Зарегистрировать `AnalyticsService` в DI
- [x] Инициализировать Firebase в `main.dart`
- [x] Интегрировать в `AuthBloc`
- [ ] Настроить Firebase проект (google-services.json, GoogleService-Info.plist)
- [ ] Интегрировать в Course screens
- [ ] Интегрировать в Lesson screens
- [ ] Интегрировать в Test screens
- [ ] Интегрировать App lifecycle tracking
- [ ] Интегрировать Screen views
- [ ] Протестировать в DebugView
- [ ] Проверить события в Production (через 24 часа)

## 🚀 Следующие шаги

1. Настроить Firebase проект (см. `FIREBASE_SETUP.md`)
2. Интегрировать аналитику в Course/Lesson screens (P0)
3. Добавить App lifecycle tracking (P0)
4. Протестировать в DebugView
5. Перейти к следующей задаче: **Геймификация** (Task #2)

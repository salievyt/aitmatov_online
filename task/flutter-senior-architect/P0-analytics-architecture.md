# Архитектура системы аналитики

**Приоритет:** P0 (Critical)  
**Срок:** 1-2 недели  
**Роль:** Flutter Senior Architect  
**Связанные задачи:** senior-product-manager/P0-analytics-implementation.md

## Обзор
Спроектировать и внедрить масштабируемую систему аналитики для отслеживания поведения пользователей, метрик продукта и принятия решений на основе данных.

## Технический стек

### Рекомендуемые инструменты
1. **Firebase Analytics** (основной):
   - Бесплатно
   - Нативная интеграция с Flutter
   - Автоматические события
   - Audience segmentation
   - Интеграция с Crashlytics

2. **Amplitude** (дополнительный):
   - Бесплатно до 10M событий/месяц
   - Продвинутая аналитика воронок
   - Retention analysis
   - Cohort analysis
   - Behavioral cohorts

### Альтернативы (если нужно)
- Mixpanel (платный, но мощный)
- PostHog (open-source, self-hosted)
- Segment (агрегатор аналитики)

## Архитектура

### Слои системы

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Widgets, Screens, User Actions)       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Analytics Service Layer            │
│  (AnalyticsService, Event Tracking)     │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│      Analytics Provider Layer           │
│  (Firebase, Amplitude, Custom)          │
└─────────────────────────────────────────┘
```

### Компоненты

#### 1. AnalyticsService (Facade)
Единая точка входа для всех аналитических событий.

```dart
abstract class AnalyticsService {
  Future<void> logEvent(AnalyticsEvent event);
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  Future<void> setCurrentScreen(String screenName);
}
```

#### 2. AnalyticsEvent (Value Object)
Типобезопасное представление событий.

```dart
sealed class AnalyticsEvent {
  String get name;
  Map<String, dynamic> get parameters;
}

// Примеры событий
class CourseViewedEvent extends AnalyticsEvent {
  final String courseId;
  final String courseName;
  final String category;
  
  @override
  String get name => 'course_viewed';
  
  @override
  Map<String, dynamic> get parameters => {
    'course_id': courseId,
    'course_name': courseName,
    'category': category,
  };
}

class LessonCompletedEvent extends AnalyticsEvent {
  final String lessonId;
  final String courseId;
  final int durationSeconds;
  
  @override
  String get name => 'lesson_completed';
  
  @override
  Map<String, dynamic> get parameters => {
    'lesson_id': lessonId,
    'course_id': courseId,
    'duration_seconds': durationSeconds,
  };
}
```

#### 3. AnalyticsProvider (Strategy Pattern)
Абстракция для разных провайдеров аналитики.

```dart
abstract class AnalyticsProvider {
  Future<void> logEvent(String name, Map<String, dynamic> parameters);
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
  Future<void> setCurrentScreen(String screenName);
}

class FirebaseAnalyticsProvider implements AnalyticsProvider {
  final FirebaseAnalytics _analytics;
  
  @override
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
  
  // ... остальные методы
}

class AmplitudeAnalyticsProvider implements AnalyticsProvider {
  final Amplitude _amplitude;
  
  @override
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _amplitude.logEvent(name, eventProperties: parameters);
  }
  
  // ... остальные методы
}
```

#### 4. CompositeAnalyticsService
Отправка событий в несколько провайдеров одновременно.

```dart
class CompositeAnalyticsService implements AnalyticsService {
  final List<AnalyticsProvider> _providers;
  
  CompositeAnalyticsService(this._providers);
  
  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    await Future.wait(
      _providers.map((provider) => 
        provider.logEvent(event.name, event.parameters)
      ),
    );
  }
  
  // ... остальные методы
}
```

## Структура файлов

```
lib/
├── core/
│   └── analytics/
│       ├── analytics_service.dart          # Интерфейс
│       ├── composite_analytics_service.dart # Композитная реализация
│       ├── events/
│       │   ├── analytics_event.dart        # Базовый класс
│       │   ├── onboarding_events.dart      # События onboarding
│       │   ├── auth_events.dart            # События аутентификации
│       │   ├── course_events.dart          # События курсов
│       │   ├── engagement_events.dart      # События engagement
│       │   ├── monetization_events.dart    # События монетизации
│       │   └── retention_events.dart       # События retention
│       ├── providers/
│       │   ├── analytics_provider.dart     # Интерфейс провайдера
│       │   ├── firebase_analytics_provider.dart
│       │   ├── amplitude_analytics_provider.dart
│       │   └── debug_analytics_provider.dart # Для разработки
│       └── user_properties.dart            # User properties
├── app/
│   └── di.dart                             # DI setup
```

## Реализация

### 1. Dependency Injection

```dart
@module
abstract class AnalyticsModule {
  @lazySingleton
  FirebaseAnalytics get firebaseAnalytics => FirebaseAnalytics.instance;
  
  @lazySingleton
  Amplitude get amplitude => Amplitude.getInstance();
  
  @lazySingleton
  FirebaseAnalyticsProvider provideFirebaseProvider(
    FirebaseAnalytics analytics,
  ) => FirebaseAnalyticsProvider(analytics);
  
  @lazySingleton
  AmplitudeAnalyticsProvider provideAmplitudeProvider(
    Amplitude amplitude,
  ) => AmplitudeAnalyticsProvider(amplitude);
  
  @lazySingleton
  AnalyticsService provideAnalyticsService(
    FirebaseAnalyticsProvider firebaseProvider,
    AmplitudeAnalyticsProvider amplitudeProvider,
  ) => CompositeAnalyticsService([
    firebaseProvider,
    amplitudeProvider,
  ]);
}
```

### 2. Использование в BLoC

```dart
class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final GetCourseUseCase _getCourse;
  final AnalyticsService _analytics;
  
  CourseBloc(this._getCourse, this._analytics) : super(CourseInitial()) {
    on<LoadCourse>(_onLoadCourse);
    on<StartLesson>(_onStartLesson);
  }
  
  Future<void> _onLoadCourse(LoadCourse event, Emitter emit) async {
    // Логируем просмотр курса
    await _analytics.logEvent(CourseViewedEvent(
      courseId: event.courseId,
      courseName: course.name,
      category: course.category,
    ));
    
    // ... остальная логика
  }
  
  Future<void> _onStartLesson(StartLesson event, Emitter emit) async {
    // Логируем начало урока
    await _analytics.logEvent(LessonStartedEvent(
      lessonId: event.lessonId,
      courseId: state.course.id,
      lessonType: event.lessonType,
    ));
    
    // ... остальная логика
  }
}
```

### 3. Автоматическое отслеживание экранов

```dart
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsService _analytics;
  
  AnalyticsRouteObserver(this._analytics);
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _analytics.setCurrentScreen(route.settings.name ?? 'unknown');
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute) {
      _analytics.setCurrentScreen(previousRoute.settings.name ?? 'unknown');
    }
  }
}

// В router.dart
final analyticsObserver = AnalyticsRouteObserver(getIt<AnalyticsService>());

final router = GoRouter(
  observers: [analyticsObserver],
  routes: [...],
);
```

### 4. User Properties

```dart
class UserProperties {
  static const String userType = 'user_type'; // student/teacher/parent
  static const String gradeLevel = 'grade_level'; // 1-11
  static const String city = 'city';
  static const String subscriptionStatus = 'subscription_status'; // free/trial/paid
  static const String daysSinceInstall = 'days_since_install';
  static const String totalCoursesCompleted = 'total_courses_completed';
  static const String currentStreak = 'current_streak';
  static const String engagementLevel = 'engagement_level'; // low/medium/high
}

// Установка user properties при логине
await _analytics.setUserId(user.id);
await _analytics.setUserProperty(UserProperties.userType, user.type);
await _analytics.setUserProperty(UserProperties.gradeLevel, user.gradeLevel.toString());
await _analytics.setUserProperty(UserProperties.city, user.city);
```

## Тестирование

### 1. Debug Provider для разработки

```dart
class DebugAnalyticsProvider implements AnalyticsProvider {
  final Logger _logger;
  
  DebugAnalyticsProvider(this._logger);
  
  @override
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    _logger.d('📊 Analytics Event: $name');
    _logger.d('   Parameters: $parameters');
  }
  
  @override
  Future<void> setUserId(String userId) async {
    _logger.d('👤 User ID set: $userId');
  }
  
  @override
  Future<void> setUserProperty(String name, String value) async {
    _logger.d('🏷️  User Property: $name = $value');
  }
  
  @override
  Future<void> setCurrentScreen(String screenName) async {
    _logger.d('📱 Screen: $screenName');
  }
}
```

### 2. Unit тесты

```dart
class MockAnalyticsProvider extends Mock implements AnalyticsProvider {}

void main() {
  group('AnalyticsService', () {
    late MockAnalyticsProvider mockProvider;
    late AnalyticsService analyticsService;
    
    setUp(() {
      mockProvider = MockAnalyticsProvider();
      analyticsService = CompositeAnalyticsService([mockProvider]);
    });
    
    test('logEvent calls provider with correct parameters', () async {
      final event = CourseViewedEvent(
        courseId: '123',
        courseName: 'Math',
        category: 'science',
      );
      
      await analyticsService.logEvent(event);
      
      verify(() => mockProvider.logEvent(
        'course_viewed',
        {
          'course_id': '123',
          'course_name': 'Math',
          'category': 'science',
        },
      )).called(1);
    });
  });
}
```

### 3. Интеграционные тесты

```dart
void main() {
  testWidgets('Course screen logs analytics event', (tester) async {
    final mockAnalytics = MockAnalyticsService();
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => CourseBloc(mockGetCourse, mockAnalytics),
          child: CourseScreen(courseId: '123'),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    verify(() => mockAnalytics.logEvent(any<CourseViewedEvent>())).called(1);
  });
}
```

## Производительность

### 1. Батчинг событий
Группировка событий для отправки пакетами (снижает нагрузку).

```dart
class BatchedAnalyticsService implements AnalyticsService {
  final AnalyticsProvider _provider;
  final List<AnalyticsEvent> _eventQueue = [];
  Timer? _flushTimer;
  
  static const _batchSize = 10;
  static const _flushInterval = Duration(seconds: 5);
  
  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    _eventQueue.add(event);
    
    if (_eventQueue.length >= _batchSize) {
      await _flush();
    } else {
      _scheduleFlush();
    }
  }
  
  Future<void> _flush() async {
    if (_eventQueue.isEmpty) return;
    
    final events = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();
    _flushTimer?.cancel();
    
    await Future.wait(
      events.map((event) => 
        _provider.logEvent(event.name, event.parameters)
      ),
    );
  }
  
  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushInterval, _flush);
  }
}
```

### 2. Асинхронная отправка
Не блокировать UI при отправке событий.

```dart
@override
Future<void> logEvent(AnalyticsEvent event) async {
  // Fire and forget
  unawaited(_provider.logEvent(event.name, event.parameters));
}
```

### 3. Кэширование при отсутствии сети

```dart
class CachedAnalyticsService implements AnalyticsService {
  final AnalyticsProvider _provider;
  final LocalStorage _storage;
  final NetworkInfo _networkInfo;
  
  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    if (await _networkInfo.isConnected) {
      await _provider.logEvent(event.name, event.parameters);
    } else {
      // Сохраняем в локальное хранилище
      await _storage.saveEvent(event);
    }
  }
  
  Future<void> flushCachedEvents() async {
    if (!await _networkInfo.isConnected) return;
    
    final cachedEvents = await _storage.getCachedEvents();
    for (final event in cachedEvents) {
      await _provider.logEvent(event.name, event.parameters);
    }
    await _storage.clearCachedEvents();
  }
}
```

## Privacy и GDPR

### 1. Consent Management

```dart
class AnalyticsConsentService {
  final SharedPreferences _prefs;
  
  static const _consentKey = 'analytics_consent';
  
  Future<bool> hasConsent() async {
    return _prefs.getBool(_consentKey) ?? false;
  }
  
  Future<void> setConsent(bool consent) async {
    await _prefs.setBool(_consentKey, consent);
    
    if (consent) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    } else {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    }
  }
}
```

### 2. Анонимизация данных
Не отправлять PII (personally identifiable information).

```dart
// ❌ Плохо
await _analytics.logEvent(UserRegisteredEvent(
  email: 'user@example.com', // PII!
  phone: '+996555123456',     // PII!
));

// ✅ Хорошо
await _analytics.logEvent(UserRegisteredEvent(
  userId: hashUserId(user.id), // Хешированный ID
  registrationMethod: 'email',
));
```

## Мониторинг и алерты

### 1. Crashlytics интеграция
Связать аналитику с крашами.

```dart
FirebaseCrashlytics.instance.setUserIdentifier(userId);
FirebaseCrashlytics.instance.setCustomKey('subscription_status', status);
```

### 2. Алерты на критические метрики
Настроить алерты в Firebase/Amplitude:
- Падение D1 retention ниже 40%
- Падение конверсии ниже 2%
- Рост churn rate выше 15%

## Чек-лист внедрения

### Неделя 1
- [ ] Добавить Firebase Analytics SDK
- [ ] Добавить Amplitude SDK
- [ ] Создать AnalyticsService интерфейс
- [ ] Реализовать FirebaseAnalyticsProvider
- [ ] Реализовать AmplitudeAnalyticsProvider
- [ ] Настроить DI
- [ ] Создать базовые события (onboarding, auth)

### Неделя 2
- [ ] Создать все события (курсы, engagement, монетизация)
- [ ] Внедрить события в BLoCs
- [ ] Настроить автоматическое отслеживание экранов
- [ ] Настроить user properties
- [ ] Добавить DebugAnalyticsProvider
- [ ] Написать unit тесты
- [ ] Провести QA аналитики

## Критерии успеха
- ✅ Все критические события отслеживаются
- ✅ События отправляются в Firebase и Amplitude
- ✅ Debug логи работают в dev режиме
- ✅ Unit тесты покрывают 80%+ кода
- ✅ Нет блокировки UI при отправке событий
- ✅ Соблюдается privacy (нет PII в событиях)

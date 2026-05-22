# Тестирование системы аналитики

**Приоритет:** P0 (Critical)  
**Срок:** 1-2 недели  
**Роль:** Senior QA Engineer  
**Связанные задачи:** flutter-senior-architect/P0-analytics-architecture.md

## Обзор
Тестирование системы аналитики для обеспечения корректного отслеживания событий и метрик.

## Scope тестирования

### 1. Event Tracking

#### Onboarding Events
- [ ] `onboarding_started` логируется при старте onboarding
- [ ] `onboarding_step_completed` логируется с правильными параметрами (step_number, step_name)
- [ ] `onboarding_completed` логируется при завершении
- [ ] `onboarding_skipped` логируется при пропуске

#### Authentication Events
- [ ] `signup_started` логируется
- [ ] `signup_completed` логируется с методом (email/phone)
- [ ] `login_started` логируется
- [ ] `login_completed` логируется с методом
- [ ] `logout` логируется

#### Course Events
- [ ] `course_viewed` логируется с course_id, course_name, category
- [ ] `course_started` логируется
- [ ] `lesson_started` логируется с lesson_type (video/audio/text)
- [ ] `lesson_completed` логируется с duration_seconds
- [ ] `course_completed` логируется с completion_rate
- [ ] `quiz_started` логируется
- [ ] `quiz_completed` логируется с score и passed

#### Engagement Events
- [ ] `daily_streak_continued` логируется с streak_count
- [ ] `daily_streak_broken` логируется с previous_streak
- [ ] `achievement_unlocked` логируется с achievement_id
- [ ] `leaderboard_viewed` логируется
- [ ] `profile_viewed` логируется

#### Monetization Events
- [ ] `paywall_viewed` логируется с source
- [ ] `subscription_started` логируется с plan
- [ ] `subscription_completed` логируется с price и currency
- [ ] `subscription_cancelled` логируется
- [ ] `trial_started` логируется
- [ ] `trial_converted` логируется

### 2. User Properties

- [ ] `user_type` устанавливается (student/teacher/parent)
- [ ] `grade_level` устанавливается (1-11)
- [ ] `city` устанавливается
- [ ] `subscription_status` устанавливается (free/trial/paid)
- [ ] `days_since_install` обновляется
- [ ] `total_courses_completed` обновляется
- [ ] `current_streak` обновляется
- [ ] `engagement_level` устанавливается (low/medium/high)

### 3. Screen Tracking

- [ ] Автоматическое отслеживание экранов работает
- [ ] Screen name корректный для каждого экрана
- [ ] Переходы между экранами логируются

### 4. Integration Testing

#### Firebase Analytics
- [ ] События отправляются в Firebase
- [ ] События видны в Firebase Console (DebugView)
- [ ] User properties устанавливаются в Firebase
- [ ] Audience segmentation работает

#### Amplitude
- [ ] События отправляются в Amplitude
- [ ] События видны в Amplitude (Live Events)
- [ ] User properties устанавливаются в Amplitude
- [ ] Cohort analysis работает

### 5. Performance

- [ ] События не блокируют UI
- [ ] Батчинг событий работает (отправка пакетами)
- [ ] Кэширование событий при отсутствии сети
- [ ] Flush кэшированных событий при восстановлении сети

### 6. Privacy

- [ ] PII (email, phone) НЕ отправляется в аналитику
- [ ] User ID хешируется
- [ ] Consent management работает
- [ ] Аналитика отключается при отказе от consent

## Test Cases

### TC-007: Событие course_viewed логируется корректно

**Preconditions:**
- Пользователь залогинен
- Firebase Analytics в debug режиме

**Steps:**
1. Открыть любой курс
2. Проверить Firebase DebugView

**Expected Result:**
- Событие `course_viewed` залогировано
- Параметры:
  - `course_id`: корректный ID
  - `course_name`: название курса
  - `category`: категория курса
- Timestamp корректный

**Priority:** P0

---

### TC-008: User properties устанавливаются при регистрации

**Preconditions:**
- Новый пользователь

**Steps:**
1. Зарегистрироваться как ученик 7 класса из Бишкека
2. Проверить Firebase Console → User Properties

**Expected Result:**
- `user_type` = "student"
- `grade_level` = "7"
- `city` = "Bishkek"
- `subscription_status` = "free"
- `days_since_install` = "0"

**Priority:** P0

---

### TC-009: События кэшируются при отсутствии сети

**Preconditions:**
- Пользователь залогинен
- Интернет отключён

**Steps:**
1. Завершить урок (офлайн)
2. Проверить локальное хранилище
3. Включить интернет
4. Подождать 5 секунд
5. Проверить Firebase DebugView

**Expected Result:**
- Событие `lesson_completed` сохранено локально
- После восстановления сети событие отправлено в Firebase
- Событие видно в DebugView

**Priority:** P1

---

### TC-010: PII не отправляется в аналитику

**Preconditions:**
- Пользователь зарегистрирован с email user@example.com

**Steps:**
1. Зарегистрироваться
2. Проверить все события в Firebase DebugView
3. Проверить User Properties

**Expected Result:**
- Email НЕ присутствует ни в одном событии
- Email НЕ присутствует в User Properties
- User ID хешированный (не оригинальный)

**Priority:** P0 (Security)

## Automation

### Unit Tests

```dart
void main() {
  group('AnalyticsService', () {
    test('logEvent sends event to all providers', () async {
      // Arrange
      final mockFirebase = MockFirebaseProvider();
      final mockAmplitude = MockAmplitudeProvider();
      final service = CompositeAnalyticsService([mockFirebase, mockAmplitude]);
      
      // Act
      await service.logEvent(CourseViewedEvent(
        courseId: '123',
        courseName: 'Math',
        category: 'science',
      ));
      
      // Assert
      verify(() => mockFirebase.logEvent('course_viewed', any())).called(1);
      verify(() => mockAmplitude.logEvent('course_viewed', any())).called(1);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  testWidgets('Course screen logs analytics event', (tester) async {
    // Arrange
    final mockAnalytics = MockAnalyticsService();
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => CourseBloc(mockGetCourse, mockAnalytics),
          child: CourseScreen(courseId: '123'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Assert
    verify(() => mockAnalytics.logEvent(any<CourseViewedEvent>())).called(1);
  });
}
```

## Manual Testing Checklist

### Firebase Analytics
- [ ] Открыть Firebase Console → DebugView
- [ ] Включить debug режим на устройстве
- [ ] Выполнить user flow (onboarding → курс → урок)
- [ ] Проверить, что все события логируются в реальном времени
- [ ] Проверить параметры событий

### Amplitude
- [ ] Открыть Amplitude → Live Events
- [ ] Выполнить user flow
- [ ] Проверить, что события появляются в Live Events
- [ ] Проверить User Properties
- [ ] Создать простую воронку (onboarding → course → lesson)
- [ ] Проверить, что воронка работает

## Критерии приёмки

- ✅ Все критические события (P0) логируются
- ✅ User properties устанавливаются корректно
- ✅ События видны в Firebase и Amplitude
- ✅ PII не отправляется в аналитику
- ✅ Performance: события не блокируют UI
- ✅ Кэширование при отсутствии сети работает
- ✅ Unit тесты покрывают 80%+ кода
- ✅ Integration тесты пройдены

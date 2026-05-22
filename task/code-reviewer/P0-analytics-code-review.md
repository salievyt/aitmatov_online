# Code Review: Система аналитики

**Приоритет:** P0 (Critical)  
**Срок:** После имплементации  
**Роль:** Code Reviewer  
**Связанные задачи:** flutter-senior-architect/P0-analytics-architecture.md

## Обзор
Code review системы аналитики для обеспечения качества кода, производительности и соблюдения best practices.

## Чек-лист ревью

### 1. Архитектура и дизайн

#### Clean Architecture
- [ ] Чёткое разделение слоёв (Presentation, Domain, Data)
- [ ] Domain layer не зависит от внешних фреймворков
- [ ] Dependency Injection настроен корректно
- [ ] Интерфейсы (abstractions) определены в Domain layer

#### Design Patterns
- [ ] Facade pattern для AnalyticsService
- [ ] Strategy pattern для AnalyticsProvider
- [ ] Composite pattern для множественных провайдеров
- [ ] Value Objects для событий (AnalyticsEvent)

#### SOLID Principles
- [ ] **Single Responsibility:** каждый класс имеет одну ответственность
- [ ] **Open/Closed:** легко добавить новый провайдер без изменения существующего кода
- [ ] **Liskov Substitution:** провайдеры взаимозаменяемы
- [ ] **Interface Segregation:** интерфейсы не перегружены
- [ ] **Dependency Inversion:** зависимости от абстракций, а не конкретных реализаций

### 2. Качество кода

#### Naming Conventions
- [ ] Классы: PascalCase (AnalyticsService)
- [ ] Методы: camelCase (logEvent)
- [ ] Константы: camelCase (XPRewards.lessonCompleted)
- [ ] Приватные поля: _camelCase (_analytics)
- [ ] События: PascalCase + Event суффикс (CourseViewedEvent)

#### Code Style
- [ ] Соответствует Dart style guide
- [ ] Использует trailing commas для форматирования
- [ ] Нет magic numbers (используются именованные константы)
- [ ] Нет дублирования кода (DRY principle)

#### Type Safety
- [ ] Использует строгую типизацию (избегает dynamic)
- [ ] Использует sealed classes для событий (exhaustive pattern matching)
- [ ] Использует enums для фиксированных значений
- [ ] Nullable типы обрабатываются корректно

### 3. Производительность

#### Асинхронность
- [ ] Все I/O операции асинхронные (async/await)
- [ ] Не блокирует UI thread
- [ ] Использует unawaited() для fire-and-forget операций
- [ ] Избегает await в циклах (использует Future.wait)

#### Батчинг и кэширование
- [ ] События группируются для отправки пакетами
- [ ] Кэширование событий при отсутствии сети
- [ ] Flush кэша при восстановлении сети
- [ ] Таймеры очищаются при dispose

#### Memory Management
- [ ] Нет memory leaks (StreamSubscription закрываются)
- [ ] Таймеры отменяются при dispose
- [ ] Большие объекты не хранятся в памяти долго

### 4. Error Handling

#### Exception Handling
- [ ] Все ошибки обрабатываются (try-catch)
- [ ] Используется Either<Failure, Success> для результатов
- [ ] Ошибки логируются (Logger)
- [ ] Ошибки не крашат приложение

#### Failure Types
- [ ] Определены специфичные типы Failure (NetworkFailure, ServerFailure)
- [ ] Failure содержит понятное сообщение для пользователя
- [ ] Failure содержит техническую информацию для логов

### 5. Тестируемость

#### Unit Tests
- [ ] Все use cases покрыты тестами
- [ ] Все repositories покрыты тестами
- [ ] Моки используются для внешних зависимостей
- [ ] Тесты изолированы (не зависят друг от друга)

#### Test Coverage
- [ ] Покрытие кода: 80%+
- [ ] Покрыты edge cases
- [ ] Покрыты error cases
- [ ] Покрыты happy paths

#### Testability
- [ ] Зависимости инжектятся (не создаются внутри класса)
- [ ] Методы не слишком большие (легко тестировать)
- [ ] Нет прямых вызовов статических методов (mockable)

### 6. Security и Privacy

#### PII Protection
- [ ] Email НЕ отправляется в аналитику
- [ ] Phone НЕ отправляется в аналитику
- [ ] User ID хешируется перед отправкой
- [ ] Нет sensitive данных в event parameters

#### Consent Management
- [ ] Проверка consent перед отправкой событий
- [ ] Возможность отключить аналитику
- [ ] Соблюдение GDPR/локальных законов

### 7. Логирование и отладка

#### Debug Mode
- [ ] DebugAnalyticsProvider для разработки
- [ ] Логи событий в debug режиме
- [ ] Логи ошибок с stack trace
- [ ] Возможность включить verbose logging

#### Production Logging
- [ ] Минимальное логирование в production
- [ ] Критические ошибки логируются в Crashlytics
- [ ] Нет sensitive данных в логах

### 8. Документация

#### Code Documentation
- [ ] Публичные API задокументированы (dartdoc)
- [ ] Сложная логика имеет комментарии
- [ ] TODO/FIXME помечены и отслеживаются
- [ ] README.md описывает архитектуру

#### Event Taxonomy
- [ ] Документ с описанием всех событий
- [ ] Описание параметров каждого события
- [ ] Примеры использования
- [ ] Changelog событий (версионирование)

## Специфичные проверки

### AnalyticsService

```dart
// ✅ Хорошо: типобезопасное событие
await _analytics.logEvent(CourseViewedEvent(
  courseId: course.id,
  courseName: course.name,
  category: course.category,
));

// ❌ Плохо: строковые параметры (подвержено ошибкам)
await _analytics.logEvent('course_viewed', {
  'course_id': course.id,
  'course_name': course.name,
});
```

### Error Handling

```dart
// ✅ Хорошо: обработка ошибок
Future<void> logEvent(AnalyticsEvent event) async {
  try {
    await _provider.logEvent(event.name, event.parameters);
  } catch (e, stackTrace) {
    _logger.e('Failed to log event', error: e, stackTrace: stackTrace);
    // Не крашим приложение из-за аналитики
  }
}

// ❌ Плохо: необработанные ошибки
Future<void> logEvent(AnalyticsEvent event) async {
  await _provider.logEvent(event.name, event.parameters);
  // Если ошибка - приложение крашится
}
```

### Асинхронность

```dart
// ✅ Хорошо: fire-and-forget для аналитики
@override
Future<void> logEvent(AnalyticsEvent event) async {
  unawaited(_provider.logEvent(event.name, event.parameters));
}

// ❌ Плохо: блокирует UI
@override
Future<void> logEvent(AnalyticsEvent event) async {
  await _provider.logEvent(event.name, event.parameters);
  // UI ждёт отправки события
}
```

### PII Protection

```dart
// ✅ Хорошо: хешированный ID
await _analytics.setUserId(hashUserId(user.id));

// ❌ Плохо: оригинальный email
await _analytics.setUserId(user.email); // PII!
```

## Потенциальные проблемы

### 1. Memory Leaks

```dart
// ❌ Плохо: Timer не отменяется
class BatchedAnalyticsService {
  Timer? _flushTimer;
  
  void scheduleFlush() {
    _flushTimer = Timer(Duration(seconds: 5), _flush);
  }
  // dispose() не реализован - memory leak!
}

// ✅ Хорошо: Timer отменяется
class BatchedAnalyticsService {
  Timer? _flushTimer;
  
  void scheduleFlush() {
    _flushTimer = Timer(Duration(seconds: 5), _flush);
  }
  
  void dispose() {
    _flushTimer?.cancel();
  }
}
```

### 2. Race Conditions

```dart
// ❌ Плохо: race condition при flush
Future<void> _flush() async {
  final events = _eventQueue; // Ссылка на оригинальный список
  _eventQueue.clear();
  
  // Если новые события добавляются во время отправки - потеряются
  await _sendEvents(events);
}

// ✅ Хорошо: копия списка
Future<void> _flush() async {
  final events = List<AnalyticsEvent>.from(_eventQueue);
  _eventQueue.clear();
  
  await _sendEvents(events);
}
```

### 3. Неправильное использование await

```dart
// ❌ Плохо: последовательная отправка
for (final provider in _providers) {
  await provider.logEvent(name, parameters);
}

// ✅ Хорошо: параллельная отправка
await Future.wait(
  _providers.map((p) => p.logEvent(name, parameters)),
);
```

## Критерии приёмки

### Must Have (блокирует merge)
- ✅ Все критические проверки пройдены
- ✅ Нет PII в событиях
- ✅ Нет memory leaks
- ✅ Нет блокировки UI
- ✅ Error handling реализован
- ✅ Unit тесты написаны и проходят

### Should Have (требует исправления)
- ✅ Code coverage 80%+
- ✅ Документация написана
- ✅ Нет code smells (SonarQube)
- ✅ Соответствует style guide

### Nice to Have (рекомендации)
- Integration тесты
- Performance тесты
- Примеры использования

## Инструменты

### Static Analysis
```bash
# Dart analyzer
flutter analyze

# Custom lint rules
flutter pub run custom_lint
```

### Code Coverage
```bash
# Генерация coverage
flutter test --coverage

# Просмотр coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Code Metrics
```bash
# Dart Code Metrics
flutter pub run dart_code_metrics:metrics analyze lib

# Complexity
flutter pub run dart_code_metrics:metrics check-unnecessary-nullable lib
```

## Комментарии в PR

### Шаблон комментария

**Критичный:**
```
🚨 [BLOCKER] PII в аналитике

В строке 45 отправляется email пользователя:
`await _analytics.setUserId(user.email);`

Это нарушает privacy policy. Используйте хешированный ID:
`await _analytics.setUserId(hashUserId(user.id));`
```

**Важный:**
```
⚠️ [IMPORTANT] Memory leak

Timer в строке 78 не отменяется при dispose.
Добавьте метод dispose() и отмените timer.
```

**Рекомендация:**
```
💡 [SUGGESTION] Улучшение производительности

Рассмотрите использование Future.wait вместо await в цикле (строка 92).
Это ускорит отправку событий в несколько провайдеров.
```

## Итоговый вердикт

### ✅ Approve
- Все критические проверки пройдены
- Нет блокирующих проблем
- Code quality высокое

### 🔄 Request Changes
- Есть критические проблемы (PII, memory leaks, security)
- Требуется исправление перед merge

### 💬 Comment
- Есть рекомендации, но не блокирует merge
- Можно исправить в следующем PR

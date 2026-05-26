# Code Review: Система монетизации

**Приоритет:** P0 (Critical)  
**Срок:** После имплементации  
**Роль:** Code Reviewer  
**Связанные задачи:** flutter-senior-architect/P0-payment-architecture.md

## Обзор
Code review системы подписок и платежей с особым вниманием к безопасности, надёжности и обработке edge cases.

## Критические проверки безопасности

### 1. Payment Data Security

#### ❌ НИКОГДА не делать:
```dart
// ❌ Хранение платёжных данных в приложении
class PaymentData {
  final String cardNumber;
  final String cvv;
  final String expiryDate;
}

// ❌ Логирование платёжных данных
_logger.d('Card number: ${payment.cardNumber}');

// ❌ Отправка платёжных данных напрямую
await _dio.post('/payment', data: {
  'card_number': cardNumber,
  'cvv': cvv,
});
```

#### ✅ Правильно:
```dart
// ✅ Использование токенов от платёжной системы
final paymentToken = await _stripe.createToken(cardData);
await _dio.post('/payment', data: {
  'payment_token': paymentToken,
});

// ✅ Логирование только безопасных данных
_logger.d('Payment initiated: amount=$amount, currency=$currency');
```

### 2. Subscription Validation

#### ❌ Небезопасно:
```dart
// ❌ Доверие только клиентской проверке
bool hasAccess(Feature feature) {
  final subscription = _localStorage.getSubscription();
  return subscription.tier == SubscriptionTier.premium;
}
```

#### ✅ Безопасно:
```dart
// ✅ Валидация на backend при каждом запросе
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Subscription-Token'] = _getSubscriptionToken();
    handler.next(options);
  }
}

// Backend проверяет токен и возвращает 403 если подписка неактивна
```

### 3. Token Storage

#### ❌ Небезопасно:
```dart
// ❌ Хранение токенов в SharedPreferences
await _prefs.setString('subscription_token', token);
```

#### ✅ Безопасно:
```dart
// ✅ Использование FlutterSecureStorage
await _secureStorage.write(key: 'subscription_token', value: token);
```

## Чек-лист ревью

### 1. Архитектура

#### Domain Models
- [ ] Subscription model содержит все необходимые поля
- [ ] Используется freezed для immutability
- [ ] Enums для статусов (SubscriptionStatus, PaymentMethod)
- [ ] Валидация данных в конструкторах

#### Repository Pattern
- [ ] Интерфейсы определены в Domain layer
- [ ] Реализации в Data layer
- [ ] Используется Either<Failure, Success>
- [ ] Все методы асинхронные

#### Use Cases
- [ ] Каждый use case имеет одну ответственность
- [ ] Логирование аналитики в use cases
- [ ] Error handling в use cases
- [ ] Валидация входных данных

### 2. Payment Integration

#### MegaPay Integration
- [ ] API ключи не хардкодятся (используются env variables)
- [ ] Используется HTTPS
- [ ] Timeout настроен (30 секунд)
- [ ] Retry механизм для transient errors
- [ ] Webhook signature валидируется

#### Stripe Integration (если есть)
- [ ] Publishable key используется на клиенте
- [ ] Secret key НИКОГДА не используется на клиенте
- [ ] PaymentIntent создаётся на backend
- [ ] 3D Secure поддерживается

#### WebView для платежей
- [ ] JavaScript включён только для платёжных страниц
- [ ] Deep links обрабатываются (success/cancel)
- [ ] Timeout для WebView (5 минут)
- [ ] Loading indicator показывается

### 3. Subscription Management

#### Lifecycle
- [ ] Trial период корректно обрабатывается
- [ ] Конверсия trial → paid автоматическая
- [ ] Истечение подписки обрабатывается
- [ ] Отмена подписки сохраняет доступ до конца периода
- [ ] Восстановление покупки работает

#### Синхронизация
- [ ] Статус синхронизируется при запуске приложения
- [ ] Периодическая синхронизация (каждый час)
- [ ] Синхронизация при возврате в приложение (AppLifecycleState)
- [ ] Кэширование статуса локально

#### Access Control
- [ ] Проверка подписки перед доступом к Premium контенту
- [ ] Fallback на Free tier при ошибке проверки
- [ ] Graceful degradation при отсутствии сети

### 4. Error Handling

#### Payment Errors
- [ ] Недостаточно средств: понятное сообщение
- [ ] Отклонённая карта: предложение другого метода
- [ ] Технический сбой: retry механизм
- [ ] Timeout: уведомление пользователю

#### Network Errors
- [ ] Retry с exponential backoff
- [ ] Максимум 3 попытки
- [ ] Fallback на кэшированные данные
- [ ] Уведомление пользователю

#### Edge Cases
- [ ] Подписка истекла во время использования
- [ ] Пользователь отменил платёж в WebView
- [ ] Backend вернул неожиданный статус
- [ ] Конфликт подписок (две активные)

### 5. UI/UX

#### Paywall Screens
- [ ] Тексты без ошибок
- [ ] Цены корректные (299 сом)
- [ ] Кнопки имеют правильные размеры (min 48x48)
- [ ] Loading states реализованы
- [ ] Error states реализованы
- [ ] Success states реализованы

#### Subscription Settings
- [ ] Текущий план отображается
- [ ] Дата следующего платежа отображается
- [ ] История платежей доступна
- [ ] Кнопка отмены подписки работает

#### Accessibility
- [ ] Semantic labels для screen readers
- [ ] Достаточный контраст текста
- [ ] Кнопки достаточно большие

### 6. Тестирование

#### Unit Tests
- [ ] Use cases покрыты тестами
- [ ] Repositories покрыты тестами
- [ ] Edge cases покрыты
- [ ] Error cases покрыты

#### Integration Tests
- [ ] Subscription flow протестирован
- [ ] Payment flow протестирован (sandbox)
- [ ] Access control протестирован

#### Mock Data
- [ ] Моки для платёжных систем
- [ ] Моки для backend API
- [ ] Тестовые карты для Stripe

### 7. Производительность

#### Response Times
- [ ] Проверка статуса подписки: <100ms
- [ ] Инициация платежа: <2 секунды
- [ ] Подтверждение платежа: <5 секунд

#### Caching
- [ ] Статус подписки кэшируется
- [ ] Cache invalidation при изменении статуса
- [ ] TTL для кэша (1 час)

#### Memory Management
- [ ] WebView очищается после платежа
- [ ] Нет memory leaks в BLoCs
- [ ] Dispose методы реализованы

## Специфичные проверки

### Subscription Repository

```dart
// ✅ Хорошо: валидация на backend
@override
Future<Either<Failure, Subscription>> getCurrentSubscription() async {
  try {
    final response = await _dio.get('/subscriptions/current');
    final subscription = Subscription.fromJson(response.data);
    
    // Кэшируем локально
    await _secureStorage.saveSubscription(subscription);
    
    return Right(subscription);
  } on DioException catch (e) {
    // Fallback на кэшированные данные
    final cached = await _secureStorage.getSubscription();
    if (cached != null) {
      return Right(cached);
    }
    return Left(NetworkFailure(e.message));
  }
}

// ❌ Плохо: только локальная проверка
@override
Future<Either<Failure, Subscription>> getCurrentSubscription() async {
  final cached = await _localStorage.getSubscription();
  return Right(cached); // Можно подделать!
}
```

### Payment Flow

```dart
// ✅ Хорошо: безопасный payment flow
Future<Either<Failure, PaymentResult>> processPayment({
  required SubscriptionTier tier,
  required PaymentMethod method,
}) async {
  try {
    // 1. Создаём payment session на backend
    final session = await _createPaymentSession(tier, method);
    
    // 2. Открываем WebView с платёжной страницей
    final result = await _openPaymentWebView(session.paymentUrl);
    
    // 3. Подтверждаем платёж на backend
    if (result.status == PaymentStatus.success) {
      await _confirmPayment(session.id, result.transactionId);
    }
    
    return Right(result);
  } catch (e) {
    return Left(PaymentFailure(e.toString()));
  }
}

// ❌ Плохо: платёжные данные на клиенте
Future<Either<Failure, PaymentResult>> processPayment({
  required String cardNumber,
  required String cvv,
}) async {
  // Никогда не обрабатывайте платёжные данные на клиенте!
  await _dio.post('/payment', data: {
    'card_number': cardNumber, // ❌
    'cvv': cvv, // ❌
  });
}
```

### Access Control

```dart
// ✅ Хорошо: проверка с fallback
Future<bool> hasAccessToFeature(Feature feature) async {
  try {
    // Проверяем на backend
    final response = await _dio.get('/access/check', queryParameters: {
      'feature': feature.id,
    });
    return response.data['has_access'];
  } catch (e) {
    // Fallback на локальную проверку (с кэшированным статусом)
    final subscription = await _getLocalSubscription();
    return _checkLocalAccess(subscription, feature);
  }
}

// ❌ Плохо: только локальная проверка
bool hasAccessToFeature(Feature feature) {
  final subscription = _localStorage.getSubscription();
  return subscription.tier == SubscriptionTier.premium;
}
```

## Потенциальные уязвимости

### 1. Subscription Bypass

```dart
// ❌ УЯЗВИМОСТЬ: можно подделать статус
class SubscriptionRepositoryImpl {
  Future<Subscription> getCurrentSubscription() async {
    // Читаем из SharedPreferences - можно изменить вручную!
    final json = _prefs.getString('subscription');
    return Subscription.fromJson(jsonDecode(json));
  }
}

// ✅ ИСПРАВЛЕНИЕ: валидация на backend
class SubscriptionRepositoryImpl {
  Future<Subscription> getCurrentSubscription() async {
    // Запрашиваем с backend с токеном аутентификации
    final response = await _dio.get('/subscriptions/current');
    return Subscription.fromJson(response.data);
  }
}
```

### 2. Payment Token Exposure

```dart
// ❌ УЯЗВИМОСТЬ: токен в логах
_logger.d('Payment token: $paymentToken');

// ✅ ИСПРАВЛЕНИЕ: не логировать токены
_logger.d('Payment initiated: amount=$amount');
```

### 3. Race Condition в подписке

```dart
// ❌ ПРОБЛЕМА: race condition
Future<void> subscribe() async {
  final payment = await _processPayment();
  if (payment.success) {
    await _activateSubscription(); // Может быть вызвано дважды
  }
}

// ✅ ИСПРАВЛЕНИЕ: idempotency key
Future<void> subscribe() async {
  final idempotencyKey = Uuid().v4();
  final payment = await _processPayment(idempotencyKey);
  if (payment.success) {
    await _activateSubscription(idempotencyKey);
  }
}
```

## Критерии приёмки

### 🚨 Blocker (блокирует merge)
- ✅ Платёжные данные НЕ хранятся на клиенте
- ✅ Платёжные данные НЕ логируются
- ✅ Токены хранятся в FlutterSecureStorage
- ✅ Валидация подписки на backend
- ✅ HTTPS используется для всех запросов
- ✅ Нет hardcoded API ключей

### ⚠️ Critical (требует исправления)
- ✅ Error handling реализован
- ✅ Retry механизм для transient errors
- ✅ Timeout настроен
- ✅ Access control работает корректно
- ✅ Unit тесты написаны

### 💡 Important (рекомендации)
- Integration тесты
- Performance тесты
- Security audit

## Security Checklist

- [ ] **PCI DSS Compliance**: платёжные данные не обрабатываются на клиенте
- [ ] **Token Security**: токены зашифрованы
- [ ] **API Security**: все запросы через HTTPS
- [ ] **Input Validation**: валидация на клиенте и backend
- [ ] **Rate Limiting**: защита от brute force
- [ ] **Audit Logging**: все платежи логируются на backend
- [ ] **Webhook Validation**: signature проверяется

## Итоговый вердикт

### ✅ Approve
- Все критические проверки пройдены
- Безопасность на высоком уровне
- Нет блокирующих проблем

### 🚨 Request Changes
- Есть критические уязвимости безопасности
- Платёжные данные обрабатываются небезопасно
- Нет валидации на backend

### 💬 Comment
- Есть рекомендации по улучшению
- Не блокирует merge

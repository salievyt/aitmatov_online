# Архитектура системы подписок и платежей

**Приоритет:** P0 (Critical)  
**Срок:** 2-4 недели  
**Роль:** Flutter Senior Architect  
**Связанные задачи:** senior-product-manager/P0-monetization-strategy.md

## Обзор
Спроектировать и внедрить систему подписок (Freemium модель) с интеграцией платёжных систем для Кыргызстана и международных пользователей.

## Требования

### Функциональные
- Freemium модель (Free + Premium tier)
- Подписки: месячная (299 сом) и годовая (2,990 сом)
- 7-дневный trial период
- Интеграция с платёжными системами Кыргызстана (MegaPay, Элсом)
- Интеграция с международными платежами (Stripe)
- Управление подписками (активация, отмена, восстановление)
- Paywall screens в ключевых точках
- Синхронизация статуса подписки между устройствами

### Нефункциональные
- Безопасность платёжных данных (PCI DSS compliance)
- Надёжность (99.9% uptime для проверки подписок)
- Производительность (проверка статуса <100ms)
- Масштабируемость (поддержка 10K+ платящих пользователей)

## Архитектура

### High-level Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                 │
│  (Paywall Screens, Subscription Settings)           │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                   BLoC Layer                        │
│  (SubscriptionBloc, PaymentBloc)                    │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                  Domain Layer                       │
│  (UseCases: Subscribe, CancelSubscription, etc.)    │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│                   Data Layer                        │
│  (SubscriptionRepository, PaymentRepository)        │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌──────────────┐    ┌──────────────────┐
│   Backend    │    │  Payment Gateway │
│     API      │    │  (MegaPay/Stripe)│
└──────────────┘    └──────────────────┘
```

### Компоненты

#### 1. Domain Models

```dart
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    required DateTime startDate,
    DateTime? endDate,
    required bool isTrialActive,
    DateTime? trialEndDate,
    required PaymentMethod paymentMethod,
    required int priceInSom,
    String? transactionId,
  }) = _Subscription;
}

enum SubscriptionTier {
  free,
  premiumMonthly,
  premiumYearly,
}

enum SubscriptionStatus {
  active,
  trialing,
  pastDue,
  canceled,
  expired,
}

enum PaymentMethod {
  megapay,
  elsom,
  stripe,
  schoolSubscription, // B2B2C
}
```

#### 2. Repository Interface

```dart
abstract class SubscriptionRepository {
  /// Получить текущую подписку пользователя
  Future<Either<Failure, Subscription>> getCurrentSubscription();
  
  /// Создать подписку
  Future<Either<Failure, Subscription>> createSubscription({
    required SubscriptionTier tier,
    required PaymentMethod paymentMethod,
    bool startTrial = false,
  });
  
  /// Отменить подписку
  Future<Either<Failure, Unit>> cancelSubscription(String subscriptionId);
  
  /// Восстановить покупку (для iOS/Android)
  Future<Either<Failure, Subscription>> restorePurchase();
  
  /// Проверить статус подписки (синхронизация с backend)
  Future<Either<Failure, Subscription>> syncSubscriptionStatus();
  
  /// Получить доступные планы
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans();
}

abstract class PaymentRepository {
  /// Инициировать платёж
  Future<Either<Failure, PaymentSession>> initiatePayment({
    required SubscriptionTier tier,
    required PaymentMethod method,
  });
  
  /// Подтвердить платёж
  Future<Either<Failure, PaymentResult>> confirmPayment(String sessionId);
  
  /// Получить историю платежей
  Future<Either<Failure, List<Payment>>> getPaymentHistory();
}
```

#### 3. Use Cases

```dart
class SubscribeUseCase {
  final SubscriptionRepository _repository;
  final AnalyticsService _analytics;
  
  Future<Either<Failure, Subscription>> call({
    required SubscriptionTier tier,
    required PaymentMethod paymentMethod,
    bool startTrial = false,
  }) async {
    // Логируем начало подписки
    await _analytics.logEvent(SubscriptionStartedEvent(
      plan: tier.name,
      paymentMethod: paymentMethod.name,
      isTrial: startTrial,
    ));
    
    final result = await _repository.createSubscription(
      tier: tier,
      paymentMethod: paymentMethod,
      startTrial: startTrial,
    );
    
    return result.fold(
      (failure) {
        _analytics.logEvent(SubscriptionFailedEvent(
          plan: tier.name,
          error: failure.message,
        ));
        return Left(failure);
      },
      (subscription) {
        _analytics.logEvent(SubscriptionCompletedEvent(
          plan: tier.name,
          price: subscription.priceInSom,
          currency: 'KGS',
        ));
        return Right(subscription);
      },
    );
  }
}

class CheckSubscriptionAccessUseCase {
  final SubscriptionRepository _repository;
  
  Future<Either<Failure, bool>> call(FeatureAccess feature) async {
    final result = await _repository.getCurrentSubscription();
    
    return result.fold(
      (failure) => Left(failure),
      (subscription) {
        final hasAccess = _checkFeatureAccess(subscription, feature);
        return Right(hasAccess);
      },
    );
  }
  
  bool _checkFeatureAccess(Subscription subscription, FeatureAccess feature) {
    if (subscription.status == SubscriptionStatus.active ||
        subscription.status == SubscriptionStatus.trialing) {
      return feature.requiredTier == SubscriptionTier.free ||
             subscription.tier != SubscriptionTier.free;
    }
    return feature.requiredTier == SubscriptionTier.free;
  }
}
```

#### 4. BLoC

```dart
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetCurrentSubscriptionUseCase _getCurrentSubscription;
  final SubscribeUseCase _subscribe;
  final CancelSubscriptionUseCase _cancelSubscription;
  final RestorePurchaseUseCase _restorePurchase;
  
  SubscriptionBloc(
    this._getCurrentSubscription,
    this._subscribe,
    this._cancelSubscription,
    this._restorePurchase,
  ) : super(SubscriptionInitial()) {
    on<LoadSubscription>(_onLoadSubscription);
    on<Subscribe>(_onSubscribe);
    on<CancelSubscription>(_onCancelSubscription);
    on<RestorePurchase>(_onRestorePurchase);
  }
  
  Future<void> _onLoadSubscription(
    LoadSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    final result = await _getCurrentSubscription();
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionLoaded(subscription)),
    );
  }
  
  Future<void> _onSubscribe(
    Subscribe event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionProcessing());
    
    final result = await _subscribe(
      tier: event.tier,
      paymentMethod: event.paymentMethod,
      startTrial: event.startTrial,
    );
    
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionSuccess(subscription)),
    );
  }
}
```

## Интеграция платёжных систем

### 1. MegaPay (Кыргызстан)

```dart
class MegaPayService {
  final Dio _dio;
  final String _merchantId;
  final String _secretKey;
  
  Future<PaymentSession> createPaymentSession({
    required int amountInSom,
    required String orderId,
    required String description,
  }) async {
    final response = await _dio.post(
      'https://api.megapay.kg/v1/payments',
      data: {
        'merchant_id': _merchantId,
        'amount': amountInSom * 100, // в тыйынах
        'currency': 'KGS',
        'order_id': orderId,
        'description': description,
        'return_url': 'aitmatov://payment/success',
        'cancel_url': 'aitmatov://payment/cancel',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      ),
    );
    
    return PaymentSession.fromJson(response.data);
  }
  
  Future<PaymentResult> checkPaymentStatus(String sessionId) async {
    final response = await _dio.get(
      'https://api.megapay.kg/v1/payments/$sessionId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_secretKey',
        },
      ),
    );
    
    return PaymentResult.fromJson(response.data);
  }
}
```

### 2. Stripe (Международные платежи)

```dart
class StripePaymentService {
  final Stripe _stripe;
  final String _publishableKey;
  
  Future<PaymentSession> createPaymentSession({
    required int amountInCents,
    required String currency,
    required String customerId,
  }) async {
    // Создаём PaymentIntent на backend
    final paymentIntent = await _createPaymentIntent(
      amountInCents: amountInCents,
      currency: currency,
      customerId: customerId,
    );
    
    return PaymentSession(
      id: paymentIntent.id,
      clientSecret: paymentIntent.clientSecret,
      amount: amountInCents,
      currency: currency,
    );
  }
  
  Future<PaymentResult> confirmPayment({
    required String clientSecret,
    required PaymentMethodData paymentMethod,
  }) async {
    final result = await _stripe.confirmPayment(
      paymentIntentClientSecret: clientSecret,
      data: PaymentMethodParams.card(
        paymentMethodData: paymentMethod,
      ),
    );
    
    return PaymentResult(
      status: result.status,
      paymentIntentId: result.id,
    );
  }
}
```

### 3. WebView для платежей

```dart
class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResult) onPaymentComplete;
  
  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Оплата')),
      body: WebViewWidget(
        controller: _controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                if (request.url.startsWith('aitmatov://payment/success')) {
                  _handlePaymentSuccess(request.url);
                  return NavigationDecision.prevent;
                } else if (request.url.startsWith('aitmatov://payment/cancel')) {
                  _handlePaymentCancel();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl)),
      ),
    );
  }
  
  void _handlePaymentSuccess(String url) {
    final uri = Uri.parse(url);
    final transactionId = uri.queryParameters['transaction_id'];
    
    widget.onPaymentComplete(PaymentResult(
      status: PaymentStatus.success,
      transactionId: transactionId,
    ));
    
    Navigator.of(context).pop();
  }
  
  void _handlePaymentCancel() {
    widget.onPaymentComplete(PaymentResult(
      status: PaymentStatus.canceled,
    ));
    
    Navigator.of(context).pop();
  }
}
```

## Paywall Screens

### 1. Paywall после onboarding

```dart
class OnboardingPaywallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Hero section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 80, color: Colors.amber),
                  SizedBox(height: 24),
                  Text(
                    'Получите полный доступ',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Попробуйте Premium бесплатно 7 дней',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            
            // Features list
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _FeatureItem(
                    icon: Icons.school,
                    title: 'Все курсы без ограничений',
                  ),
                  _FeatureItem(
                    icon: Icons.offline_bolt,
                    title: 'Офлайн-доступ к урокам',
                  ),
                  _FeatureItem(
                    icon: Icons.certificate,
                    title: 'Сертификаты о прохождении',
                  ),
                  _FeatureItem(
                    icon: Icons.analytics,
                    title: 'Продвинутая аналитика',
                  ),
                ],
              ),
            ),
            
            // CTA buttons
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _startTrial(context),
                    child: Text('Попробовать бесплатно'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 56),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Продолжить с базовым'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Отмените в любое время',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _startTrial(BuildContext context) {
    context.read<SubscriptionBloc>().add(Subscribe(
      tier: SubscriptionTier.premiumMonthly,
      paymentMethod: PaymentMethod.megapay,
      startTrial: true,
    ));
  }
}
```

### 2. Hard paywall (после бесплатных уроков)

```dart
class CoursePaywallScreen extends StatelessWidget {
  final Course course;
  final int completedLessons;
  final int totalLessons;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Продолжите обучение')),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: completedLessons / totalLessons,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Вы прошли $completedLessons из $totalLessons уроков',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Social proof
          Container(
            padding: EdgeInsets.all(24),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '12,450 учеников уже учатся с Premium',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          
          // Pricing
          Expanded(
            child: _PricingSection(),
          ),
          
          // CTA
          Padding(
            padding: EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () => _subscribe(context),
              child: Text('Получить Premium'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Синхронизация подписки

### 1. Периодическая проверка

```dart
class SubscriptionSyncService {
  final SubscriptionRepository _repository;
  Timer? _syncTimer;
  
  void startPeriodicSync() {
    _syncTimer = Timer.periodic(
      Duration(hours: 1),
      (_) => _syncSubscription(),
    );
  }
  
  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }
  
  Future<void> _syncSubscription() async {
    await _repository.syncSubscriptionStatus();
  }
}
```

### 2. Проверка при запуске приложения

```dart
class AppInitializer {
  final SubscriptionRepository _subscriptionRepository;
  
  Future<void> initialize() async {
    // Синхронизируем статус подписки
    await _subscriptionRepository.syncSubscriptionStatus();
    
    // ... другая инициализация
  }
}
```

## Безопасность

### 1. Валидация подписки на backend

```dart
// НИКОГДА не доверяйте только клиентской проверке!
// Backend должен валидировать подписку при каждом запросе к Premium контенту

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Добавляем токен подписки в заголовки
    options.headers['X-Subscription-Token'] = _getSubscriptionToken();
    handler.next(options);
  }
}
```

### 2. Шифрование данных подписки

```dart
class SecureSubscriptionStorage {
  final FlutterSecureStorage _storage;
  
  Future<void> saveSubscription(Subscription subscription) async {
    final json = jsonEncode(subscription.toJson());
    await _storage.write(key: 'subscription', value: json);
  }
  
  Future<Subscription?> getSubscription() async {
    final json = await _storage.read(key: 'subscription');
    if (json == null) return null;
    return Subscription.fromJson(jsonDecode(json));
  }
}
```

## Тестирование

### 1. Unit тесты

```dart
void main() {
  group('SubscribeUseCase', () {
    late MockSubscriptionRepository mockRepository;
    late MockAnalyticsService mockAnalytics;
    late SubscribeUseCase useCase;
    
    setUp(() {
      mockRepository = MockSubscriptionRepository();
      mockAnalytics = MockAnalyticsService();
      useCase = SubscribeUseCase(mockRepository, mockAnalytics);
    });
    
    test('should create subscription and log analytics', () async {
      when(() => mockRepository.createSubscription(
        tier: any(named: 'tier'),
        paymentMethod: any(named: 'paymentMethod'),
        startTrial: any(named: 'startTrial'),
      )).thenAnswer((_) async => Right(tSubscription));
      
      final result = await useCase(
        tier: SubscriptionTier.premiumMonthly,
        paymentMethod: PaymentMethod.megapay,
        startTrial: true,
      );
      
      expect(result, Right(tSubscription));
      verify(() => mockAnalytics.logEvent(any<SubscriptionStartedEvent>()));
      verify(() => mockAnalytics.logEvent(any<SubscriptionCompletedEvent>()));
    });
  });
}
```

### 2. Integration тесты

```dart
void main() {
  testWidgets('Paywall shows and allows subscription', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => SubscriptionBloc(mockUseCases),
          child: OnboardingPaywallScreen(),
        ),
      ),
    );
    
    expect(find.text('Попробовать бесплатно'), findsOneWidget);
    
    await tester.tap(find.text('Попробовать бесплатно'));
    await tester.pumpAndSettle();
    
    verify(() => mockSubscribeUseCase(
      tier: SubscriptionTier.premiumMonthly,
      paymentMethod: any(named: 'paymentMethod'),
      startTrial: true,
    )).called(1);
  });
}
```

## Чек-лист внедрения

### Неделя 1-2: Backend + Core
- [ ] Спроектировать API для подписок
- [ ] Реализовать domain models
- [ ] Реализовать repository interfaces
- [ ] Реализовать use cases
- [ ] Настроить DI

### Неделя 3: Платёжные системы
- [ ] Интегрировать MegaPay
- [ ] Интегрировать Stripe (опционально)
- [ ] Реализовать WebView для платежей
- [ ] Тестирование платежей (sandbox)

### Неделя 4: UI + Тестирование
- [ ] Реализовать paywall screens
- [ ] Реализовать subscription settings
- [ ] Реализовать синхронизацию подписки
- [ ] Написать unit тесты
- [ ] Написать integration тесты
- [ ] Провести QA

## Критерии успеха
- ✅ Пользователи могут подписаться на Premium
- ✅ Trial период работает корректно
- ✅ Платежи проходят успешно (>95% success rate)
- ✅ Статус подписки синхронизируется между устройствами
- ✅ Paywall показывается в правильных местах
- ✅ Безопасность: валидация на backend, шифрование данных

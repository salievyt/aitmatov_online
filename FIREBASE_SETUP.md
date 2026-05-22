# Firebase Setup для Aitmatov App

## Шаги настройки Firebase

### 1. Создать проект в Firebase Console

1. Перейти на https://console.firebase.google.com/
2. Нажать "Add project" / "Добавить проект"
3. Название проекта: `aitmatov-digital`
4. Включить Google Analytics (рекомендуется)

### 2. Добавить Android приложение

1. В Firebase Console выбрать "Add app" → Android
2. **Android package name:** `com.aitmatov.app` (проверить в `android/app/build.gradle`)
3. Скачать `google-services.json`
4. Поместить файл в: `android/app/google-services.json`
5. Добавить в `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

6. Добавить в `android/app/build.gradle`:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // <- Добавить эту строку
```

### 3. Добавить iOS приложение

1. В Firebase Console выбрать "Add app" → iOS
2. **iOS bundle ID:** `com.aitmatov.app` (проверить в `ios/Runner.xcodeproj/project.pbxproj`)
3. Скачать `GoogleService-Info.plist`
4. Открыть `ios/Runner.xcworkspace` в Xcode
5. Перетащить `GoogleService-Info.plist` в проект Runner (в Xcode)
6. Убедиться, что файл добавлен в Target "Runner"

### 4. Установить зависимости

```bash
flutter pub get
cd ios && pod install && cd ..
```

### 5. Настроить Firebase Analytics

Firebase Analytics уже настроен в коде:
- ✅ `firebase_core` и `firebase_analytics` добавлены в `pubspec.yaml`
- ✅ `Firebase.initializeApp()` вызывается в `main.dart`
- ✅ `AnalyticsService` создан и зарегистрирован в DI

### 6. Проверить работу

Запустить приложение:

```bash
flutter run
```

В Firebase Console → Analytics → Events должны появиться события в течение 24 часов.

Для отладки можно включить debug mode:

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.aitmatov.app
```

**iOS:**
В Xcode: Edit Scheme → Run → Arguments → Add `-FIRAnalyticsDebugEnabled`

### 7. Настроить Firebase Messaging (Push-уведомления)

#### Android

1. В Firebase Console → Project Settings → Cloud Messaging
2. Скопировать Server Key
3. Добавить в `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- ... -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_icon"
        android:resource="@drawable/ic_notification" />
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_color"
        android:resource="@color/colorPrimary" />
</application>
```

#### iOS

1. В Xcode: Runner → Signing & Capabilities → "+ Capability" → Push Notifications
2. Добавить Background Modes → Remote notifications
3. В Firebase Console загрузить APNs Authentication Key

### 8. Интеграция аналитики в код

`AnalyticsService` уже создан. Пример использования:

```dart
// В AuthBloc после успешной регистрации
final analytics = getIt<AnalyticsService>();
await analytics.logSignUp(
  method: 'email',
  role: user.role,
);

// В CourseScreen при открытии курса
await analytics.logCourseView(
  courseId: course.id,
  courseName: course.title,
  subject: course.subject,
);

// В LessonScreen при завершении урока
await analytics.logLessonComplete(
  lessonId: lesson.id,
  courseId: course.id,
  durationSeconds: 300,
);
```

## Ключевые события для отслеживания

### Критические события (уже реализованы в AnalyticsService):

1. **Auth Events:**
   - `sign_up` — регистрация
   - `login` — вход
   - `logout` — выход

2. **Course Events:**
   - `course_view` — просмотр курса
   - `course_start` — начало курса
   - `course_complete` — завершение курса

3. **Lesson Events:**
   - `lesson_view` — просмотр урока
   - `lesson_start` — начало урока
   - `lesson_complete` — завершение урока

4. **Test Events:**
   - `test_start` — начало теста
   - `test_complete` — завершение теста

5. **Messenger Events:**
   - `message_sent` — отправка сообщения
   - `group_join` — присоединение к группе

6. **Aitmatov Section:**
   - `aitmatov_section_view` — просмотр раздела
   - `aitmatov_content_view` — просмотр контента

7. **Retention Events:**
   - `app_open` — открытие приложения
   - `streak_achieved` — достижение streak

8. **Monetization Events (для будущего):**
   - `paywall_view` — просмотр paywall
   - `purchase_start` — начало покупки
   - `purchase_complete` — завершение покупки

## Метрики для отслеживания в Firebase Console

### Acquisition (Привлечение)
- Новые пользователи (New Users)
- Источники трафика (Traffic Sources)
- Установки приложения

### Activation (Активация)
- Завершение onboarding
- Первый просмотр курса
- Первый завершённый урок

### Engagement (Вовлечённость)
- DAU (Daily Active Users)
- Session Duration
- Screen Views
- Events per Session

### Retention (Удержание)
- D1, D7, D30 Retention
- Churn Rate
- Returning Users

### Monetization (для будущего)
- Conversion to Paid
- Revenue
- ARPU
- LTV

## Следующие шаги

1. ✅ Установить зависимости: `flutter pub get`
2. ⏳ Создать проект в Firebase Console
3. ⏳ Добавить `google-services.json` (Android)
4. ⏳ Добавить `GoogleService-Info.plist` (iOS)
5. ⏳ Интегрировать вызовы аналитики в существующие экраны
6. ⏳ Протестировать события в Firebase Debug View
7. ⏳ Настроить дашборд в Firebase Console

## Полезные ссылки

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Analytics Events](https://firebase.google.com/docs/analytics/events)
- [Firebase Analytics Debug View](https://firebase.google.com/docs/analytics/debugview)

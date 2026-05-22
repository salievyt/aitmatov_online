# P0: Внедрение аналитики и метрик

**Приоритет:** P0 (Critical)  
**Срок:** 0-2 недели  
**Роль:** Senior Product Manager  
**Зависимости:** flutter-senior-architect/analytics-architecture.md

## Проблема
Отсутствие аналитики делает невозможным:
- Измерение поведения пользователей
- Принятие решений на основе данных
- Оптимизацию воронки конверсии
- Отслеживание retention метрик

## Цели
1. Внедрить систему аналитики (Firebase Analytics / Amplitude)
2. Настроить отслеживание ключевых событий
3. Создать дашборды для мониторинга метрик
4. Установить baseline метрик для A/B тестирования

## Ключевые события для отслеживания

### Onboarding
- `onboarding_started`
- `onboarding_step_completed` (step_number, step_name)
- `onboarding_completed`
- `onboarding_skipped`

### Аутентификация
- `signup_started`
- `signup_completed` (method: email/phone/social)
- `login_started`
- `login_completed` (method)
- `logout`

### Курсы и обучение
- `course_viewed` (course_id, course_name, category)
- `course_started` (course_id)
- `lesson_started` (lesson_id, course_id, lesson_type: video/audio/text)
- `lesson_completed` (lesson_id, duration_seconds)
- `course_completed` (course_id, completion_rate)
- `quiz_started` (quiz_id, course_id)
- `quiz_completed` (quiz_id, score, passed)

### Engagement
- `daily_streak_continued` (streak_count)
- `daily_streak_broken` (previous_streak)
- `achievement_unlocked` (achievement_id, achievement_name)
- `leaderboard_viewed`
- `profile_viewed` (user_id, is_own_profile)

### Мессенджер
- `chat_opened` (chat_id, chat_type: class/private)
- `message_sent` (chat_id, message_type: text/image/file)
- `message_received` (chat_id)

### Монетизация
- `paywall_viewed` (source: course/feature)
- `subscription_started` (plan: monthly/yearly)
- `subscription_completed` (plan, price, currency)
- `subscription_cancelled`
- `trial_started`
- `trial_converted`

### Родительский контроль
- `parent_dashboard_viewed`
- `child_progress_viewed` (child_id)
- `parent_notification_sent` (notification_type)

### Retention
- `app_opened` (session_number, days_since_install)
- `app_backgrounded` (session_duration_seconds)
- `push_notification_received` (notification_type)
- `push_notification_opened` (notification_type)

## Целевые метрики

### Acquisition
- DAU (Daily Active Users)
- MAU (Monthly Active Users)
- Новые регистрации / день
- Источники трафика

### Activation
- % завершивших onboarding
- Time to first value (время до первого урока)
- % пользователей, начавших первый курс в D0

### Engagement
- Sessions per user per day
- Average session duration
- Courses started per user
- Lessons completed per user
- Messages sent per user

### Retention
- **D1 Retention: 50-60%** (цель)
- **D7 Retention: 30-40%** (цель)
- D30 Retention: 15-20%
- Weekly retention cohorts
- Churn rate

### Monetization
- **Conversion rate: 3-5%** (цель)
- **ARPU: $0.50-1/месяц** (цель)
- Trial to paid conversion
- MRR (Monthly Recurring Revenue)
- **CAC/LTV: 1:3** (цель)

## Инструменты

### Рекомендация: Firebase Analytics + Amplitude
**Firebase Analytics** (бесплатно):
- Базовые события и user properties
- Интеграция с Firebase Crashlytics
- Автоматические события (app_open, screen_view)
- Audience segmentation

**Amplitude** (бесплатно до 10M событий/месяц):
- Продвинутая аналитика воронок
- Retention analysis
- Cohort analysis
- Behavioral cohorts для таргетинга

### Альтернативы
- Mixpanel (дороже, но мощнее)
- PostHog (open-source, self-hosted)

## Дашборды

### Dashboard 1: Product Health
- DAU/MAU/WAU графики
- D1/D7/D30 Retention
- Churn rate
- Session metrics

### Dashboard 2: Acquisition Funnel
- Регистрации по источникам
- Onboarding completion rate
- Time to activation
- Drop-off points

### Dashboard 3: Engagement
- Courses started/completed
- Lessons completed
- Quiz completion rate
- Streak distribution
- Messages sent

### Dashboard 4: Monetization
- Paywall views
- Trial starts
- Conversion rate
- MRR/ARR
- ARPU
- LTV

### Dashboard 5: Retention Cohorts
- Weekly cohort retention table
- Retention curves по сегментам
- Churn reasons

## User Properties для сегментации
- `user_type`: student / teacher / parent
- `grade_level`: 1-11
- `city`: Bishkek / Osh / other
- `subscription_status`: free / trial / paid / churned
- `days_since_install`: 0, 1, 7, 30, 90+
- `total_courses_completed`: 0, 1-5, 6-10, 11+
- `current_streak`: 0, 1-7, 8-30, 31+
- `engagement_level`: low / medium / high (по activity score)

## План внедрения

### Неделя 1: Настройка инфраструктуры
- [ ] Создать Firebase проект
- [ ] Создать Amplitude проект
- [ ] Добавить Firebase SDK в приложение
- [ ] Добавить Amplitude SDK
- [ ] Настроить debug режим для тестирования
- [ ] Создать документацию по событиям (event taxonomy)

### Неделя 2: Имплементация событий
- [ ] Внедрить базовые события (app_open, screen_view)
- [ ] Внедрить события onboarding
- [ ] Внедрить события аутентификации
- [ ] Внедрить события курсов и уроков
- [ ] Внедрить события монетизации
- [ ] Настроить user properties

### Неделя 3: Дашборды и мониторинг
- [ ] Создать дашборды в Firebase
- [ ] Создать дашборды в Amplitude
- [ ] Настроить алерты на критические метрики
- [ ] Провести QA аналитики
- [ ] Задокументировать процесс добавления новых событий

### Неделя 4: Baseline и оптимизация
- [ ] Собрать baseline метрики (2 недели данных)
- [ ] Провести анализ воронок
- [ ] Выявить точки оттока
- [ ] Создать гипотезы для оптимизации
- [ ] Подготовить план A/B тестов

## Критерии успеха
- ✅ Все критические события отслеживаются
- ✅ Дашборды обновляются в реальном времени
- ✅ Retention cohorts видны за последние 4 недели
- ✅ Команда может принимать решения на основе данных
- ✅ Настроены алерты на падение ключевых метрик

## Риски
- **Технический долг**: неправильная имплементация событий потребует миграции данных
- **Privacy**: необходимо соблюдать GDPR/локальные законы о данных
- **Производительность**: избыточные события могут замедлить приложение

## Следующие шаги
После внедрения аналитики:
1. Запустить A/B тесты для оптимизации onboarding
2. Настроить push-уведомления на основе поведенческих когорт
3. Внедрить персонализацию контента на основе engagement level
4. Оптимизировать paywall placement на основе данных конверсии

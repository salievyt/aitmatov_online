# Руководство по переносу дизайна Aitmatov App в Figma

Ссылка на Figma файл: https://www.figma.com/design/VkJFuye87GVQsStVZqQf2O

## 📋 Содержание
1. [Дизайн-токены (Variables)](#дизайн-токены)
2. [Компоненты](#компоненты)
3. [Экраны](#экраны)

---

## 🎨 Дизайн-токены

### 1. Коллекция "Primitives" (базовые цвета)
**Scopes:** Пустой массив (скрыть от пикеров)

| Имя переменной | Значение (RGB) | Hex |
|----------------|----------------|-----|
| `primary/base` | 14, 116, 144 | #0E7490 |
| `secondary/base` | 234, 88, 12 | #EA580C |
| `error/base` | 179, 38, 30 | #B3261E |
| `gray/0` | 255, 255, 255 | #FFFFFF |
| `gray/50` | 249, 250, 251 | #F9FAFB |
| `gray/100` | 243, 244, 246 | #F3F4F6 |
| `gray/200` | 229, 231, 235 | #E5E7EB |
| `gray/300` | 209, 213, 219 | #D1D5DB |
| `gray/400` | 156, 163, 175 | #9CA3AF |
| `gray/500` | 107, 114, 128 | #6B7280 |
| `gray/600` | 75, 85, 99 | #4B5563 |
| `gray/700` | 55, 65, 81 | #374151 |
| `gray/800` | 31, 41, 55 | #1F2937 |
| `gray/900` | 17, 24, 39 | #111827 |
| `gray/1000` | 18, 18, 18 | #121212 |
| `background/light` | 245, 247, 250 | #F5F7FA |
| `background/dark` | 18, 18, 18 | #121212 |
| `surface/dark` | 30, 30, 30 | #1E1E1E |
| `text/light` | 28, 27, 31 | #1C1B1F |
| `text/dark` | 230, 225, 229 | #E6E1E5 |

### 2. Коллекция "Color Light" (светлая тема)
Все переменные ссылаются на Primitives через алиасы.

| Имя переменной | Алиас на Primitives | Scopes |
|----------------|---------------------|--------|
| `color/bg/primary` | `background/light` | Frame fill, Shape fill |
| `color/bg/surface` | `gray/0` | Frame fill, Shape fill |
| `color/bg/secondary` | `gray/50` | Frame fill, Shape fill |
| `color/brand/primary` | `primary/base` | Frame fill, Shape fill, Text fill |
| `color/brand/secondary` | `secondary/base` | Frame fill, Shape fill, Text fill |
| `color/text/primary` | `text/light` | Text fill |
| `color/text/secondary` | `gray/600` | Text fill |
| `color/text/on-primary` | `gray/0` | Text fill |
| `color/border/default` | `gray/200` | Stroke color |
| `color/border/subtle` | `gray/100` | Stroke color |
| `color/error` | `error/base` | Frame fill, Shape fill, Text fill |

### 3. Коллекция "Color Dark" (тёмная тема)

| Имя переменной | Алиас на Primitives | Scopes |
|----------------|---------------------|--------|
| `color/bg/primary` | `background/dark` | Frame fill, Shape fill |
| `color/bg/surface` | `surface/dark` | Frame fill, Shape fill |
| `color/bg/secondary` | `gray/900` | Frame fill, Shape fill |
| `color/brand/primary` | `primary/base` | Frame fill, Shape fill, Text fill |
| `color/brand/secondary` | `secondary/base` | Frame fill, Shape fill, Text fill |
| `color/text/primary` | `text/dark` | Text fill |
| `color/text/secondary` | `gray/400` | Text fill |
| `color/text/on-primary` | `gray/0` | Text fill |
| `color/border/default` | `gray/700` | Stroke color |
| `color/border/subtle` | `gray/800` | Stroke color |
| `color/error` | `error/base` | Frame fill, Shape fill, Text fill |

### 4. Коллекция "Spacing" (сетка 8px)
**Scopes:** Gap, Width & Height, Min Width & Height, Max Width & Height

| Имя переменной | Значение (px) |
|----------------|---------------|
| `spacing/xs` | 4 |
| `spacing/sm` | 8 |
| `spacing/md` | 16 |
| `spacing/lg` | 24 |
| `spacing/xl` | 32 |
| `spacing/xxl` | 40 |
| `spacing/xxxl` | 48 |

### 5. Коллекция "Radius"
**Scopes:** Corner radius

| Имя переменной | Значение (px) |
|----------------|---------------|
| `radius/none` | 0 |
| `radius/sm` | 8 |
| `radius/md` | 12 |
| `radius/lg` | 16 |
| `radius/xl` | 20 |
| `radius/xxl` | 24 |
| `radius/full` | 9999 |

### 6. Text Styles (типографика)

#### Display
- **Display Large**: 32px, Bold (700), Line height 1.3, Letter spacing -0.5
- **Display Medium**: 28px, Bold (700), Line height 1.3, Letter spacing -0.5

#### Headlines
- **Headline Large**: 24px, Bold (700), Line height 1.5, Letter spacing 0
- **Headline Medium**: 20px, SemiBold (600), Line height 1.5, Letter spacing 0
- **Headline Small**: 18px, SemiBold (600), Line height 1.5, Letter spacing 0

#### Titles
- **Title Large**: 18px, SemiBold (600), Line height 1.5, Letter spacing 0
- **Title Medium**: 16px, SemiBold (600), Line height 1.5, Letter spacing 0.5
- **Title Small**: 14px, SemiBold (600), Line height 1.5, Letter spacing 0.5

#### Body
- **Body Large**: 16px, Regular (400), Line height 1.6, Letter spacing 0
- **Body Medium**: 14px, Regular (400), Line height 1.6, Letter spacing 0
- **Body Small**: 12px, Regular (400), Line height 1.6, Letter spacing 0.5

#### Labels
- **Label Large**: 16px, SemiBold (600), Line height 1.5, Letter spacing 0.5
- **Label Medium**: 14px, SemiBold (600), Line height 1.5, Letter spacing 0.5
- **Label Small**: 12px, SemiBold (600), Line height 1.5, Letter spacing 0.5

### 7. Effect Styles (тени)

#### Card Shadow
- **Light**: Color: `color/brand/primary` 8% opacity, Blur: 16, Offset: 0, 4
- **Dark**: Color: Black 30% opacity, Blur: 16, Offset: 0, 4

#### Elevated Shadow
- **Light**: Color: `color/brand/primary` 12% opacity, Blur: 20, Offset: 0, 8
- **Dark**: Color: Black 40% opacity, Blur: 20, Offset: 0, 8

#### Button Shadow
- **Light**: Color: `color/brand/primary` 20% opacity, Blur: 12, Offset: 0, 4
- **Dark**: Color: Black 30% opacity, Blur: 12, Offset: 0, 4

#### Avatar Shadow
- **Light**: Color: `color/brand/primary` 20% opacity, Blur: 16, Spread: 2, Offset: 0, 4
- **Dark**: Color: Black 30% opacity, Blur: 16, Spread: 2, Offset: 0, 4

---

## 🧩 Компоненты

### 1. Button (AnimatedButton)

**Варианты:**
- **Style**: Primary, Outlined
- **State**: Default, Loading, Disabled
- **Size**: Medium (можно добавить Small, Large)

#### Primary Button
- **Fill**: `color/brand/primary`
- **Text**: `color/text/on-primary`, Label Large
- **Padding**: Horizontal 24px, Vertical 16px
- **Corner radius**: `radius/md` (12px)
- **Shadow**: Button Shadow (Light/Dark)
- **Auto-layout**: Horizontal, Gap 8px, Hug contents

#### Outlined Button
- **Fill**: Transparent
- **Border**: 2px, `color/brand/primary`
- **Text**: `color/brand/primary`, Label Large
- **Padding**: Horizontal 24px, Vertical 16px
- **Corner radius**: `radius/md` (12px)
- **No shadow**

#### Loading State
- Показать CircularProgressIndicator (20x20px) вместо текста
- Цвет индикатора: для Primary - `color/text/on-primary`, для Outlined - `color/brand/primary`

### 2. Card (AnimatedCard)

**Варианты:**
- **Elevation**: Default, Elevated
- **Theme**: Light, Dark

#### Default Card
- **Fill**: `color/bg/surface`
- **Padding**: `spacing/md` (16px)
- **Corner radius**: `radius/lg` (16px)
- **Shadow**: Card Shadow
- **Border**: Optional, 1.5px, `color/border/subtle`

#### Elevated Card (hover state)
- **Shadow**: Elevated Shadow
- Остальное как Default

### 3. TextField (ImprovedTextField)

**Состояния:**
- Default
- Focused
- Error
- Disabled

#### Structure
- **Container**: Auto-layout vertical, Gap 8px
- **Label**: Body Medium, `color/text/secondary`
- **Input Field**:
  - Fill: `color/bg/secondary` (Light: gray/50, Dark: gray/900)
  - Padding: Horizontal 16px, Vertical 12px
  - Corner radius: `radius/md` (12px)
  - Text: Body Large, `color/text/primary`
  - Placeholder: Body Large, `color/text/secondary` 60% opacity

#### Focused State
- Border: 2px, `color/brand/primary`

#### Error State
- Border: 2px, `color/error`
- Helper text: Body Small, `color/error`

### 4. Icon Button
- **Size**: 40x40px
- **Fill**: `color/bg/secondary`
- **Icon**: 24x24px, `color/text/primary`
- **Corner radius**: `radius/md` (12px)
- **Hover**: Elevated Shadow

---

## 📱 Экраны

### 1. Login Screen

**Размер фрейма:** 375x812px (iPhone 13 Pro)

#### Структура (сверху вниз):
1. **Logo Container** (64x64px)
   - Fill: Gradient (primary → primary 70% opacity)
   - Corner radius: `radius/lg` (16px)
   - Icon: auto_stories, 32px, white
   - Shadow: Avatar Shadow

2. **Spacing**: `spacing/lg` (24px)

3. **Title**
   - Text: "Добро пожаловать"
   - Style: Display Medium
   - Color: `color/text/primary`

4. **Spacing**: `spacing/sm` (8px)

5. **Subtitle**
   - Text: "Войдите в свой аккаунт для продолжения"
   - Style: Body Large
   - Color: `color/text/secondary`

6. **Spacing**: `spacing/xxxl` (48px)

7. **Email TextField**
   - Label: "Email"
   - Placeholder: "example@mail.com"
   - Prefix icon: email_outlined

8. **Spacing**: `spacing/md` (16px)

9. **Password TextField**
   - Label: "Пароль"
   - Placeholder: "••••••••"
   - Prefix icon: lock_outline
   - Suffix icon: visibility_off (toggle)

10. **Spacing**: `spacing/xl` (32px)

11. **Login Button** (Primary)
    - Text: "Войти"
    - Full width

12. **Spacing**: `spacing/lg` (24px)

13. **Signup Button** (Outlined)
    - Text: "Создать аккаунт"
    - Full width

**Padding контейнера:** 24px со всех сторон

---

### 2. Home Screen

**Размер фрейма:** 375x812px

#### App Bar
- Height: 56px
- Background: `color/bg/primary`
- Title: "Айтматов онлайн", Headline Medium
- Elevation: 0

#### Content (ScrollView)

1. **Welcome Text**
   - Padding: 16px horizontal, 8px top, 16px bottom
   - Text: "Выберите предмет для изучения"
   - Style: Body Large
   - Color: `color/text/secondary`

2. **Featured Card** ("Мир Айтматова")
   - Padding: 16px horizontal, 0 top, 24px bottom
   - Card с gradient fill (secondary 15% → secondary 5%)
   - Border: 1.5px, secondary 20% opacity
   - Corner radius: `radius/lg` (16px)
   - Padding внутри: 20px
   - Layout: Horizontal, Gap 16px
   
   **Содержимое:**
   - **Avatar** (64x64px):
     - Gradient fill: secondary → secondary 70%
     - Icon: auto_stories, 32px, white
     - Shadow: Avatar Shadow
   
   - **Text Column** (Vertical, Gap 4px):
     - Title: "Мир Айтматова", Title Large, Bold
     - Subtitle: "Касандра, экология, память", Body Medium, secondary color
   
   - **Arrow Icon** (16px):
     - Container: 32x32px circle
     - Fill: secondary 10% opacity
     - Icon: arrow_forward_ios, secondary color

3. **Section Header**
   - Padding: 16px horizontal, 0 top, 16px bottom
   - Layout: Horizontal, Space between
   - Left: "Предметы", Headline Medium
   - Right: Badge с количеством (например "6")
     - Padding: 12px horizontal, 6px vertical
     - Fill: primary 10% opacity
     - Text: Label Medium, primary color
     - Corner radius: `radius/md` (12px)

4. **Subjects Grid**
   - Padding: 16px horizontal
   - Grid: 2 columns
   - Gap: 16px horizontal, 16px vertical
   - Aspect ratio: 1.3

#### Subject Card (в сетке)
- Gradient fill: (color 12% → color 4%)
- Border: 1.5px, color 20% opacity
- Corner radius: `radius/lg` (16px)
- Padding: 16px
- Layout: Vertical, Center aligned

**Содержимое:**
- **Icon Container** (56x56px):
  - Gradient fill: color → color 70%
  - Shape: Circle
  - Icon: 28px, white
  - Shadow: Avatar Shadow

- **Spacing**: 12px

- **Subject Name**:
  - Style: Title Medium
  - Color: `color/text/primary`
  - Align: Center
  - Max lines: 2

**Цвета для предметов** (по порядку, циклично):
1. Primary
2. Secondary
3. Tertiary (можно использовать оранжевый #F97316)
4. Purple (#A855F7)
5. Teal (#14B8A6)
6. Pink (#EC4899)

---

### 3. Profile Screen

**Размер фрейма:** 375x812px

#### App Bar
- Height: 56px
- Background: `color/bg/primary`
- Title: "Профиль", Headline Medium
- Elevation: 0

#### Content

1. **Profile Header Card**
   - Margin: 16px
   - Padding: 24px
   - Fill: `color/bg/surface`
   - Corner radius: `radius/lg` (16px)
   - Shadow: Card Shadow
   - Layout: Vertical, Center aligned, Gap 16px
   
   **Содержимое:**
   - **Avatar** (80x80px):
     - Gradient fill: primary → primary 70%
     - Shape: Circle
     - Icon/Initials: 40px, white
     - Shadow: Avatar Shadow
   
   - **Name**: Headline Small, `color/text/primary`
   - **Email**: Body Medium, `color/text/secondary`
   - **Role Badge**:
     - Padding: 8px horizontal, 4px vertical
     - Fill: primary 10% opacity
     - Text: Label Small, primary color
     - Corner radius: `radius/sm` (8px)

2. **Menu Items List**
   - Padding: 0 horizontal, 16px vertical
   - Gap: 8px between items

#### Menu Item
- Height: 56px
- Padding: 16px horizontal
- Layout: Horizontal, Gap 16px, Center aligned
- Hover: Fill `color/bg/secondary`

**Содержимое:**
- **Icon Container** (40x40px):
  - Fill: `color/bg/secondary`
  - Corner radius: `radius/md` (12px)
  - Icon: 24px, `color/text/primary`

- **Text**: Body Large, `color/text/primary`

- **Arrow Icon**: 16px, `color/text/secondary`, Right aligned

**Примеры пунктов меню:**
- Мои оценки (icon: grade)
- Расписание (icon: calendar_today)
- Настройки (icon: settings)
- Выйти (icon: logout, text color: error)

---

### 4. Subject Detail Screen

**Размер фрейма:** 375x812px

#### App Bar
- Height: 56px
- Background: `color/bg/primary`
- Back button: arrow_back icon
- Title: Название предмета, Headline Medium
- Elevation: 0

#### Content

1. **Subject Header**
   - Padding: 24px
   - Fill: Gradient (subject color 15% → subject color 5%)
   - Layout: Horizontal, Gap 16px
   
   **Содержимое:**
   - **Icon Container** (72x72px):
     - Gradient fill: subject color → subject color 70%
     - Shape: Circle
     - Icon: 36px, white
     - Shadow: Avatar Shadow
   
   - **Info Column** (Vertical, Gap 8px):
     - Subject name: Headline Large
     - Lessons count: Body Medium, secondary color
     - Progress bar (optional)

2. **Lessons List**
   - Padding: 16px
   - Gap: 12px between items

#### Lesson Card
- Padding: 16px
- Fill: `color/bg/surface`
- Corner radius: `radius/lg` (16px)
- Shadow: Card Shadow
- Layout: Horizontal, Gap 16px

**Содержимое:**
- **Number Badge** (40x40px):
  - Fill: subject color 10% opacity
  - Text: Headline Small, subject color
  - Shape: Circle

- **Info Column** (Vertical, Gap 4px, Flex 1):
  - Lesson title: Title Medium
  - Duration: Body Small, secondary color

- **Status Icon**: 24px
  - Completed: check_circle, success color
  - In progress: play_circle, primary color
  - Locked: lock, secondary color

---

### 5. Teacher Dashboard Screen

**Размер фрейма:** 375x812px

#### App Bar
- Height: 56px
- Background: `color/bg/primary`
- Title: "Панель учителя", Headline Medium
- Actions: notifications icon
- Elevation: 0

#### Content

1. **Stats Cards Row**
   - Padding: 16px
   - Layout: Horizontal, Gap 12px
   - 2 cards, equal width

#### Stat Card
- Padding: 16px
- Fill: `color/bg/surface`
- Corner radius: `radius/lg` (16px)
- Shadow: Card Shadow
- Layout: Vertical, Gap 8px

**Содержимое:**
- **Icon Container** (40x40px):
  - Fill: primary 10% opacity
  - Corner radius: `radius/md` (12px)
  - Icon: 24px, primary color

- **Value**: Display Medium, `color/text/primary`
- **Label**: Body Small, `color/text/secondary`

**Примеры:**
- Студенты (icon: people)
- Курсы (icon: school)
- Оценки (icon: grade)
- Сообщения (icon: message)

2. **Quick Actions**
   - Padding: 0 horizontal, 16px vertical
   - Title: "Быстрые действия", Title Large
   - Padding bottom: 12px

3. **Action Buttons Grid**
   - Padding: 16px horizontal
   - Grid: 2 columns
   - Gap: 12px

#### Action Button
- Aspect ratio: 1:1
- Fill: Gradient (action color 12% → action color 4%)
- Border: 1.5px, action color 20% opacity
- Corner radius: `radius/lg` (16px)
- Padding: 16px
- Layout: Vertical, Center aligned, Gap 12px

**Содержимое:**
- **Icon Container** (48x48px):
  - Gradient fill: action color → action color 70%
  - Shape: Circle
  - Icon: 24px, white
  - Shadow: Avatar Shadow

- **Label**: Title Small, Center aligned

**Примеры действий:**
- Добавить оценку (icon: add_circle, primary color)
- Создать урок (icon: create, secondary color)
- Отправить сообщение (icon: send, teal color)
- Аналитика (icon: analytics, purple color)

---

## 🎯 Рекомендации по реализации

### Порядок создания:
1. ✅ Создать все коллекции переменных (Primitives, Color Light, Color Dark, Spacing, Radius)
2. ✅ Создать Text Styles
3. ✅ Создать Effect Styles (тени)
4. Создать базовые компоненты (Button, Card, TextField, Icon Button)
5. Создать экраны, используя компоненты и переменные

### Принципы:
- **Всегда используйте переменные** для цветов, отступов и радиусов
- **Auto-layout везде** - не используйте абсолютное позиционирование
- **Компоненты с вариантами** - создавайте варианты для разных состояний
- **Консистентность** - следуйте сетке 8px для всех отступов
- **Тени для иерархии** - используйте разные уровни теней для визуальной глубины

### Анимации (для справки, в Figma не реализуются):
- Микровзаимодействия: 200-300ms, ease-out
- Появление элементов: staggered animation с задержкой 50ms между элементами
- Нажатие кнопки: scale 0.95, 150ms
- Hover карточки: elevation увеличивается, 250ms

---

## 📚 Дополнительные экраны для реализации

После основных экранов можно добавить:
- Signup Screen (регистрация)
- Schedule Screen (расписание)
- Grades Screen (оценки студента)
- Teacher Analytics Screen (аналитика учителя)
- Teacher Messages Screen (сообщения учителя)
- Lesson Detail Screen (детали урока)
- Aitmatov World Screen (мир Айтматова)
- Settings Screen (настройки)
- Onboarding Screen (онбординг)
- Splash Screen (заставка)

Все эти экраны следуют той же дизайн-системе и используют те же компоненты и переменные.

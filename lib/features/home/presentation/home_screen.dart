import 'package:aitmatov_app/core/presentation/widgets/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';
import '../../../core/utils/empty_state_widget.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../domain/entities/subject.dart';
import '../../../domain/repositories/subject_repository.dart';

/// Современный главный экран с улучшенным UX/UI
/// Применяет:
/// - Гештальт-принципы (близость, сходство, визуальная иерархия)
/// - Каскадные анимации появления элементов
/// - Интерактивные карточки с hover эффектами
/// - Правило пика и завершения (запоминающиеся моменты)
/// - Улучшенная навигация и визуальные подсказки
/// - Адаптивная сетка с оптимальными пропорциями
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AsyncController<List<Subject>> _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _controller = AsyncController(loader: () => context.read<SubjectRepository>().getSubjects());
    _controller.load();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async => _controller.load();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSubjects,
        child: ValueListenableBuilder<AsyncState<List<Subject>>>(
          valueListenable: _controller.state,
          builder: (context, state, child) {
            if (state.isLoading) {
              return const Center(child: ImprovedLoadingIndicator());
            }

            if (state.hasError) {
              return _buildErrorState(state.error);
            }

            final subjects = state.data ?? const [];
            if (subjects.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.menu_book,
                title: 'Нет предметов',
                subtitle: 'Пока не добавлено ни одного предмета',
              );
            }

            return CustomScrollView(
              slivers: [
                // Современный App Bar с градиентом
                SliverAppBar(
                  elevation: 0,
                  floating: true,
                  snap: true,
                  expandedHeight: 120,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => showSearch(
                        context: context,
                        delegate: SubjectSearchDelegate(subjects),
                      ),
                      tooltip: 'Поиск предметов',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Айтматов онлайн',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.colorScheme.primary.withOpacity(0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Иконка уведомлений
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined),
                            // Индикатор новых уведомлений
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          // TODO: Navigate to notifications
                        },
                      ),
                    ),
                  ],
                ),

                // Приветственное сообщение с иконкой
                SliverToBoxAdapter(
                  child: FadeInListItem(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.waving_hand,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Выберите предмет для изучения',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Карточка "Мир Айтматова" - пиковый момент
                SliverToBoxAdapter(
                  child: FadeInListItem(
                    index: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: _buildFeaturedCard(theme, isDark),
                    ),
                  ),
                ),

                // Заголовок секции предметов
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeInListItem(
                      index: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Предметы',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Выберите для начала обучения',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.15),
                                  theme.colorScheme.primary.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${subjects.length}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Сетка предметов с анимациями
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subject = subjects[index];
                        return FadeInListItem(
                          index: index + 3,
                          child: _buildSubjectCard(theme, subject, index, isDark),
                        );
                      },
                      childCount: subjects.length,
                    ),
                  ),
                ),

                // Нижний отступ
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(ThemeData theme, bool isDark) {
    return AnimatedCard(
      onTap: () => context.push('/aitmatov'),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.secondary.withOpacity(0.2),
          theme.colorScheme.secondary.withOpacity(0.08),
        ],
      ),
      border: Border.all(
        color: theme.colorScheme.secondary.withOpacity(0.3),
        width: 2,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Значок "Рекомендуем"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Рекомендуем',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: AppShadows.avatar(theme.colorScheme.secondary, isDark: isDark),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мир Айтматова',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Касандра, экология, память',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопка действия
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Начать изучение',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme, Subject subject, int index, bool isDark) {
    final color = _getColorForIndex(theme, index);

    return AnimatedCard(
      onTap: () => context.push('/subjects/${subject.slug}'),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ],
      ),
      border: Border.all(
        color: color.withOpacity(0.25),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка предмета
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              boxShadow: AppShadows.avatar(color, isDark: isDark),
            ),
            child: Icon(
              _iconFromName(subject.icon),
              size: 30,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Название предмета
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Индикатор прогресса или статус
              Row(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Начать',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Что-то пошло не так',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Ошибка загрузки',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedButton(
              onPressed: _loadSubjects,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('Попробовать снова'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(ThemeData theme, int index) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'book':
        return Icons.book;
      case 'nature':
        return Icons.nature;
      case 'language':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}

/// Делегат поиска предметов
class SubjectSearchDelegate extends SearchDelegate<Subject?> {
  final List<Subject> subjects;

  SubjectSearchDelegate(this.subjects);

  @override
  String get searchFieldLabel => 'Поиск предметов';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
        tooltip: 'Очистить',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Назад',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final results = subjects
        .where((s) => s.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Введите название предмета',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final subject = results[index];
        final color = _getColorForIndex(theme, index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedCard(
            onTap: () {
              close(context, subject);
              context.push('/subject/${subject.id}');
            },
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.7)],
                    ),
                  ),
                  child: Icon(
                    _iconFromName(subject.iconName),
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    subject.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorForIndex(ThemeData theme, int index) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'book':
        return Icons.book;
      case 'nature':
        return Icons.nature;
      case 'language':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}

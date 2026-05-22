import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Современная панель администратора с улучшенным UX/UI
/// Применяет:
/// - Визуальная иерархия с градиентами и статистикой
/// - Быстрые действия с иконками и цветовым кодированием
/// - Каскадные анимации появления
/// - Информативные карточки с метриками
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final me = await context.read<AuthRepository>().getCurrentUser(forceRefresh: true);
    me.fold((_) {}, (u) => _user = u);
    if (!mounted) return;
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: ImprovedLoadingIndicator()),
      );
    }

    if (_user == null || !_user!.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Доступ только для администратора',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Современный App Bar с градиентом
          SliverAppBar(
            elevation: 0,
            floating: true,
            snap: true,
            expandedHeight: 140,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Панель администратора',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Добро пожаловать, ${_user!.firstName}!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
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
                      theme.colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Статистика
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: FadeInListItem(
                index: 0,
                child: _buildStatsSection(theme, isDark),
              ),
            ),
          ),

          // Быстрые действия
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FadeInListItem(
                index: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Управление системой',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Сетка действий
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                FadeInListItem(
                  index: 2,
                  child: _buildActionCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.analytics_outlined,
                    title: 'Аналитика',
                    subtitle: 'Метрики платформы',
                    color: Colors.purple,
                    onTap: () => context.push('/admin/analytics'),
                  ),
                ),
                FadeInListItem(
                  index: 3,
                  child: _buildActionCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.manage_accounts_outlined,
                    title: 'Пользователи',
                    subtitle: 'Управление ролями',
                    color: theme.colorScheme.primary,
                    onTap: () => context.push('/admin/users'),
                  ),
                ),
                FadeInListItem(
                  index: 4,
                  child: _buildActionCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.calendar_month_outlined,
                    title: 'Расписание',
                    subtitle: 'Редактирование',
                    color: Colors.orange,
                    onTap: () => context.push('/admin/schedule'),
                  ),
                ),
                FadeInListItem(
                  index: 5,
                  child: _buildActionCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.support_agent_outlined,
                    title: 'Учителя',
                    subtitle: 'Быстрый доступ',
                    color: Colors.green,
                    onTap: () => context.push('/admin/users?role=teacher'),
                  ),
                ),
              ]),
            ),
          ),

          // Дополнительные опции
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: FadeInListItem(
                index: 6,
                child: Text(
                  'Дополнительно',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),

          // Список дополнительных опций
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInListItem(
                  index: 7,
                  child: _buildListOption(
                    theme: theme,
                    icon: Icons.feedback_outlined,
                    title: 'Обратная связь',
                    subtitle: 'Сообщения пользователей',
                    onTap: () => context.push('/admin/feedback'),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInListItem(
                  index: 8,
                  child: _buildListOption(
                    theme: theme,
                    icon: Icons.history_edu_outlined,
                    title: 'Логи системы',
                    subtitle: 'Действия пользователей',
                    onTap: () => context.push('/admin/logs'),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, bool isDark) {
    // TODO: Заменить на реальные данные из API
    // Временно скрыто до готовности backend
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.amber.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.construction,
            size: 32,
            color: Colors.amber,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Статистика в разработке',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Скоро здесь появится реальная статистика по пользователям и учителям',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return AnimatedCard(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 56,
            height: 56,
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
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListOption({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

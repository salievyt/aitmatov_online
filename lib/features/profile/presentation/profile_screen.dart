import 'package:aitmatov_app/core/constans/app_colors.dart';
import 'package:aitmatov_app/core/constans/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/presentation/widgets/animated_button.dart';
import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';
import '../../../core/presentation/widgets/improved_text_field.dart';
import '../../../core/constans/app_spacing.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';

/// Современный экран профиля с улучшенным UX/UI
/// Применяет:
/// - Правило пика и завершения (запоминающиеся моменты)
/// - Визуальная иерархия с градиентами и тенями
/// - Микровзаимодействия для всех элементов
/// - Каскадные анимации появления
/// - Информативные карточки статистики
/// - Улучшенная навигация по разделам
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  late final AsyncController<User> _controller;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller = AsyncController(
        loader: () =>
            context.read<AuthRepository>().getCurrentUser(forceRefresh: true));
    _controller.load().then((_) {
      if (!mounted) return;
      _user = _controller.state.value.data;
      _animationController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    await _controller.load();
    if (!mounted) return;
    _user = _controller.state.value.data;
    _animationController.forward(from: 0);
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Выход из аккаунта',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Вы уверены, что хотите выйти?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                      backgroundColor: Colors.red.shade600,
                      child: const Text('Выйти'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _editProfile() async {
    if (_user == null) return;
    final theme = Theme.of(context);
    final nicknameController = TextEditingController(text: _user!.username ?? '');
    final avatarController = TextEditingController(text: _user!.avatarUrl ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Редактировать профиль',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              ImprovedTextField(
                controller: nicknameController,
                labelText: 'Никнейм',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              ImprovedTextField(
                controller: avatarController,
                labelText: 'URL аватара',
                prefixIcon: Icons.image_outlined,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      isOutlined: true,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () async {
                        final result = await context
                            .read<AuthRepository>()
                            .updateMyProfile(
                              username: nicknameController.text.trim(),
                              avatar: avatarController.text.trim(),
                            );
                        if (!context.mounted) return;
                        result.fold(
                          (f) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(f.message),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          (u) {
                            setState(() => _user = u);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Профиль обновлен'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: ValueListenableBuilder<AsyncState<User>>(
          valueListenable: _controller.state,
          builder: (context, state, child) {
            if (state.isLoading) {
              return const Center(child: ImprovedLoadingIndicator());
            }

            final user = state.data;
            if (user == null) {
              return _buildErrorState(
                  'Не удалось загрузить данные пользователя');
            }

            _user ??= user;

            return RefreshIndicator(
              onRefresh: _loadUser,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    title: Text(
                      'Профиль',
                      style: theme.textTheme.headlineMedium,
                    ),
                    centerTitle: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          FadeInListItem(
                            index: 0,
                            child: _buildProfileHeader(theme, isDark, user),
                          ),
                          const SizedBox(height: 24),
                          FadeInListItem(
                            index: 1,
                            child: _buildInfoCard(theme, isDark, user),
                          ),
                          const SizedBox(height: 24),
                          FadeInListItem(
                            index: 2,
                            child: _buildRoleFeaturesCard(theme, user, isDark),
                          ),
                          const SizedBox(height: 24),
                          if (user.isStudent) ...[
                            FadeInListItem(
                              index: 3,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.grade_outlined,
                                label: 'Мои оценки',
                                onTap: () => context.push('/student/grades'),
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInListItem(
                              index: 4,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.poll_outlined,
                                label: 'Опросы',
                                onTap: () => context.push('/surveys'),
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInListItem(
                              index: 5,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.support_agent_outlined,
                                label: 'Обращения',
                                onTap: () => context.push('/feedback/request'),
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (user.isTeacher) ...[
                            FadeInListItem(
                              index: 3,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.dashboard_outlined,
                                label: 'Кабинет преподавателя',
                                onTap: () => context.push('/teacher'),
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInListItem(
                              index: 4,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.fact_check_outlined,
                                label: 'Оценки учеников',
                                onTap: () => context.push('/teacher/grades'),
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (user.isAdmin) ...[
                            FadeInListItem(
                              index: 6,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.analytics_outlined,
                                label: 'Анализ платформы',
                                onTap: () => context.push('/admin/analytics'),
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInListItem(
                              index: 7,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.feedback_outlined,
                                label: 'Обратная связь',
                                onTap: () => context.push('/admin/feedback'),
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FadeInListItem(
                              index: 8,
                              child: _buildActionButton(
                                theme: theme,
                                isDark: isDark,
                                icon: Icons.history_edu_outlined,
                                label: 'Логи API',
                                onTap: () => context.push('/admin/logs'),
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          FadeInListItem(
                            index: 9,
                            child: _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.logout_rounded,
                              label: 'Выйти из аккаунта',
                              onTap: _showLogoutDialog,
                              color: Colors.red.shade400,
                              isDanger: true,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark, User user) {
    return AnimatedCard(
      onTap: _editProfile,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withOpacity(0.2),
          theme.colorScheme.secondary.withOpacity(0.1),
        ],
      ),
      border: Border.all(
        color: theme.colorScheme.primary.withOpacity(0.3),
        width: 2,
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          // Аватар с улучшенной тенью
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                      ? Text(
                          user.firstName.isNotEmpty ? user.firstName[0] : '?',
                          style: const TextStyle(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              // Индикатор онлайн статуса
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Имя пользователя
          Text(
            user.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Username
          Text(
            user.displayName,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Email/Phone
          Text(
            user.email ?? user.phone ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          // Кнопка редактирования
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Редактировать профиль',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoCard(ThemeData theme, bool isDark, User user) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ??
            (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Column(
          children: [
            _buildInfoRow(
              theme: theme,
              icon: Icons.verified_user_outlined,
              iconColor: theme.colorScheme.primary,
              title: 'Роль в системе',
              subtitle: '${user.roleLabel} ',
              // (${user.role})
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                // child: Text(
                //   'Нельзя изменить',
                //   style: theme.textTheme.labelSmall?.copyWith(
                //     color: theme.colorScheme.onSurface.withOpacity(0.6),
                //   ),
                // ),
              ),
            ),
            if (user.classLevel != null)
              Divider(
                  height: 1,
                  indent: 56,
                  color: theme.dividerColor.withOpacity(0.5)),
            if (user.classLevel != null)
              _buildInfoRow(
                theme: theme,
                icon: Icons.class_outlined,
                iconColor: Colors.orange,
                title: 'Класс',
                subtitle: '${user.classLevel} класс',
              ),
            if (user.school != null && user.school!.isNotEmpty)
              Divider(
                  height: 1,
                  indent: 56,
                  color: theme.dividerColor.withOpacity(0.5)),
            if (user.school != null && user.school!.isNotEmpty)
              _buildInfoRow(
                theme: theme,
                icon: Icons.location_city_outlined,
                iconColor: Colors.teal,
                title: 'Школа',
                subtitle: user.school!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withOpacity(0.2),
                  iconColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildRoleFeaturesCard(ThemeData theme, User user, bool isDark) {
    final items = <String>[
      if (user.isStudent)
        'Доступ к курсам, урокам, самопроверке и отметке прогресса.',
      if (user.isStudent)
        'Рекомендуемый режим: изучение по шагам и переход к следующему уроку.',
      if (user.isTeacher)
        'Управление учебным процессом и методические материалы платформы.',
      if (user.isTeacher)
        'Мониторинг прогресса учеников по курсам (по роли учителя).',
      if (user.isAdmin)
        'Администрирование платформы: пользователи, контент и доступы.',
      if (user.isAdmin)
        'Контроль качества и модерация образовательного контента.',
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary.withOpacity(0.12),
            theme.colorScheme.secondary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.06),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Режим ${user.roleLabel.toLowerCase()}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isDanger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDanger ? Colors.red.withOpacity(0.05) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color:
              isDanger ? Colors.red.withOpacity(0.15) : color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDanger
                          ? Colors.red.shade600
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red[400] : Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Что-то пошло не так',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Ошибка загрузки',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUser,
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

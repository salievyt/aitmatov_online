import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/constans/app_colors.dart';
import '../../../core/constans/app_sizes.dart';
import '../../../core/constans/app_spacing.dart';
import '../../../core/constans/app_typography.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';

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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius)),
        elevation: AppSizes.elevationDialog,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.dialogWhite,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.dialogPaddingDefault),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.iconContainerSize,
                  height: AppSizes.iconContainerSize,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: AppSizes.iconXL,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),
                Text(
                  'Выход из аккаунта',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.itemSpacing),
                Text(
                  'Вы уверены, что хотите выйти?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: AppSpacing.dialogPaddingDefault),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonPaddingVertical),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.buttonRadius)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: AppTypography.buttonTextSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.itemSpacing),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonPaddingVertical),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.buttonRadius)),
                          elevation: AppSizes.elevationCard,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        child: const Text(
                          'Выйти',
                          style: TextStyle(
                            fontSize: AppTypography.buttonTextSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    if (_user == null) return;
    final nicknameController =
        TextEditingController(text: _user!.username ?? '');
    final avatarController =
        TextEditingController(text: _user!.avatarUrl ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius)),
        elevation: AppSizes.elevationDialog,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.dialogRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.dialogWhite, Colors.grey.shade50],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.dialogPaddingDefault),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Редактировать профиль',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Никнейм',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.itemSpacing),
                TextField(
                  controller: avatarController,
                  decoration: InputDecoration(
                    labelText: 'URL аватара',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.dialogPaddingDefault),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonPaddingVertical),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.buttonRadius)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: AppTypography.buttonTextSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.itemSpacing),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonPaddingVertical),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.buttonRadius)),
                          elevation: AppSizes.elevationCard,
                        ),
                        onPressed: () async {
                          final result = await context
                              .read<AuthRepository>()
                              .updateMyProfile(
                                username: nicknameController.text.trim(),
                                avatar: avatarController.text.trim(),
                              );
                          if (!mounted) return;
                          result.fold(
                            (f) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(f.message))),
                            (u) {
                              setState(() => _user = u);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            fontSize: AppTypography.buttonTextSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
              return const Center(child: CircularProgressIndicator());
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        children: [
                          _buildProfileHeader(theme, isDark, user),
                          const SizedBox(height: AppSpacing.sectionSpacing),
                          _buildInfoCard(theme, isDark, user),
                          const SizedBox(height: AppSpacing.sectionSpacing),
                          _buildRoleFeaturesCard(theme, user, isDark),
                          const SizedBox(height: AppSpacing.sectionSpacing),
                          if (user.isStudent) ...[
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.grade_outlined,
                              label: 'Мои оценки',
                              onTap: () => context.push('/student/grades'),
                              color: Colors.green,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.poll_outlined,
                              label: 'Опросы',
                              onTap: () => context.push('/surveys'),
                              color: Colors.blue,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.support_agent_outlined,
                              label: 'Обращения',
                              onTap: () => context.push('/feedback/request'),
                              color: Colors.teal,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                          ],
                          if (user.isTeacher) ...[
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.dashboard_outlined,
                              label: 'Открыть кабинет преподавателя',
                              onTap: () => context.push('/teacher'),
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.fact_check_outlined,
                              label: 'Оценки учеников',
                              onTap: () => context.push('/teacher/grades'),
                              color: Colors.orange,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.poll_outlined,
                              label: 'Опросы',
                              onTap: () => context.push('/surveys'),
                              color: Colors.blue,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.support_agent_outlined,
                              label: 'Обращения',
                              onTap: () => context.push('/feedback/request'),
                              color: Colors.teal,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                          ],
                          if (user.isAdmin) ...[
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.admin_panel_settings_outlined,
                              label: 'Открыть панель администратора',
                              onTap: () => context.push('/admin'),
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.analytics_outlined,
                              label: 'Анализ платформы',
                              onTap: () => context.push('/admin/analytics'),
                              color: Colors.indigo,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.feedback_outlined,
                              label: 'Обратная связь',
                              onTap: () => context.push('/admin/feedback'),
                              color: Colors.teal,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                            _buildActionButton(
                              theme: theme,
                              isDark: isDark,
                              icon: Icons.history_edu_outlined,
                              label: 'Логи API',
                              onTap: () => context.push('/admin/logs'),
                              color: Colors.brown,
                            ),
                            const SizedBox(height: AppSpacing.itemSpacing),
                          ],
                          // if (user.isAdmin) ...[
                          //   _buildActionButton(
                          //     theme: theme,
                          //     isDark: isDark,
                          //     icon: Icons.api_outlined,
                          //     label: 'API Logs (Debug)',
                          //     onTap: ChuckerFlutter.showChuckerScreen,
                          //     color: Colors.teal,
                          //   ),
                          //   const SizedBox(height: AppSpacing.itemSpacing),
                          // ],
                          _buildActionButton(
                            theme: theme,
                            isDark: isDark,
                            icon: Icons.logout_rounded,
                            label: 'Выйти из аккаунта',
                            onTap: _showLogoutDialog,
                            color: Colors.red.shade400,
                            isDanger: true,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: InkWell(
          onTap: _editProfile,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage:
                        user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                        ? Text(
                            user.firstName.isNotEmpty ? user.firstName[0] : '?',
                            style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: AppTypography.fontSizeXLarge,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email ?? user.phone ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Редактировать',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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

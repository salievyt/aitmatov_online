import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final result = await context.read<AuthRepository>().getCurrentUser(forceRefresh: true);
    result.fold(
      (failure) => setState(() => _isLoading = false),
      (user) => setState(() {
        _user = user;
        _isLoading = false;
      }),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    if (_user == null) return;
    final nicknameController = TextEditingController(text: _user!.username ?? '');
    final avatarController = TextEditingController(text: _user!.avatarUrl ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'Никнейм')),
            const SizedBox(height: 8),
            TextField(controller: avatarController, decoration: const InputDecoration(labelText: 'URL аватара')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final result = await context.read<AuthRepository>().updateMyProfile(
                    username: nicknameController.text.trim(),
                    avatar: avatarController.text.trim(),
                  );
              if (!mounted) return;
              result.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                (u) {
                  setState(() => _user = u);
                  Navigator.pop(context);
                },
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? _buildErrorState("Не удалось загрузить данные пользователя")
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                _user!.firstName.isNotEmpty ? _user!.firstName[0] : '?',
                                style: const TextStyle(fontSize: 32, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _user!.fullName,
                              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20),
                            ),
                            Text(_user!.displayName),
                            const SizedBox(height: 4),
                            Text(
                              _user!.email ?? _user!.phone ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Изменить никнейм и аватар'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.verified_user_outlined),
                              title: const Text('Роль в системе'),
                              subtitle: Text('${_user!.roleLabel} (${_user!.role})'),
                              trailing: const Chip(label: Text('Нельзя изменить')),
                            ),
                            const Divider(height: 1),
                            if (_user!.classLevel != null)
                              ListTile(
                                leading: const Icon(Icons.class_outlined),
                                title: const Text('Класс'),
                                subtitle: Text('${_user!.classLevel} класс'),
                              ),
                            if (_user!.school != null && _user!.school!.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.location_city_outlined),
                                title: const Text('Школа'),
                                subtitle: Text(_user!.school!),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRoleFeaturesCard(theme, _user!),
                      const SizedBox(height: 12),
                      if (_user!.isTeacher)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context.push('/teacher'),
                            icon: const Icon(Icons.dashboard_outlined),
                            label: const Text('Открыть кабинет преподавателя'),
                          ),
                        ),
                      if (_user!.isAdmin)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context.push('/admin'),
                            icon: const Icon(Icons.admin_panel_settings_outlined),
                            label: const Text('Открыть панель администратора'),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout),
                          label: const Text('Выйти из аккаунта'),
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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




  Widget _buildRoleFeaturesCard(ThemeData theme, User user) {
    final items = <String>[
      if (user.isStudent) 'Доступ к курсам, урокам, самопроверке и отметке прогресса.',
      if (user.isStudent) 'Рекомендуемый режим: изучение по шагам и переход к следующему уроку.',
      if (user.isTeacher) 'Управление учебным процессом и методические материалы платформы.',
      if (user.isTeacher) 'Мониторинг прогресса учеников по курсам (по роли учителя).',
      if (user.isAdmin) 'Администрирование платформы: пользователи, контент и доступы.',
      if (user.isAdmin) 'Контроль качества и модерация образовательного контента.',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Режим ${user.roleLabel.toLowerCase()}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle_outline, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

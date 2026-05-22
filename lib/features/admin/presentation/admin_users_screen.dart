import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';
import '../../../core/presentation/widgets/improved_text_field.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_management_repository.dart';

/// Современный экран управления пользователями
/// Применяет:
/// - Поиск и фильтрация в реальном времени
/// - Визуальная иерархия с цветовым кодированием ролей
/// - Каскадные анимации появления
/// - Улучшенные диалоги редактирования
class AdminUsersScreen extends StatefulWidget {
  final String? roleFilter;
  const AdminUsersScreen({super.key, this.roleFilter});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedRoleFilter;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedRoleFilter = widget.roleFilter;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchController.addListener(_filterUsers);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _roleLabel(String role) {
    switch (role.trim().toLowerCase()) {
      case 'student':
        return 'Ученик';
      case 'teacher':
        return 'Учитель';
      case 'admin':
        return 'Администратор';
      default:
        return role;
    }
  }

  Color _roleColor(String role, ThemeData theme) {
    switch (role.trim().toLowerCase()) {
      case 'student':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'admin':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _roleIcon(String role) {
    switch (role.trim().toLowerCase()) {
      case 'student':
        return Icons.school;
      case 'teacher':
        return Icons.person;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person_outline;
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final result = await context
        .read<UserManagementRepository>()
        .getUsers(role: _selectedRoleFilter);
    result.fold((_) {}, (users) {
      _users = users;
      _filteredUsers = users;
    });
    setState(() => _isLoading = false);
    _animationController.forward();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final nameMatch = user.fullName.toLowerCase().contains(query);
        final emailMatch = (user.email ?? '').toLowerCase().contains(query);
        final phoneMatch = (user.phone ?? '').toLowerCase().contains(query);
        return nameMatch || emailMatch || phoneMatch;
      }).toList();
    });
  }

  Future<void> _editUser(User user) async {
    String role = user.role;
    bool isActive = true;
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Редактирование',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user.fullName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Выбор роли
                  Text(
                    'Роль пользователя',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 20),
                              SizedBox(width: 12),
                              Text('Ученик'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'teacher',
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 20),
                              SizedBox(width: 12),
                              Text('Учитель'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 20),
                              SizedBox(width: 12),
                              Text('Администратор'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setStateDialog(() => role = v ?? 'student'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Статус активности
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: SwitchListTile(
                      value: isActive,
                      title: Text(
                        'Аккаунт активен',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isActive
                            ? 'Пользователь может войти'
                            : 'Доступ заблокирован',
                        style: theme.textTheme.bodySmall,
                      ),
                      onChanged: (v) => setStateDialog(() => isActive = v),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопки действий
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final repository =
                                context.read<UserManagementRepository>();
                            await repository.updateUser(user.id, {
                              'role': role,
                              'is_active': isActive,
                            });
                            if (!mounted) return;
                            navigator.pop();
                            _loadUsers();
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Изменения сохранены'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Современный App Bar
          SliverAppBar(
            elevation: 0,
            floating: true,
            snap: true,
            expandedHeight: 120,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Управление пользователями',
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
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Поиск и фильтры
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                children: [
                  // Поле поиска
                  FadeInListItem(
                    index: 0,
                    child: ImprovedTextField(
                      controller: _searchController,
                      labelText: 'Поиск пользователей',
                      hintText: 'Имя, email или телефон',
                      prefixIcon: Icons.search,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterUsers();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Фильтр по ролям
                  FadeInListItem(
                    index: 1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            theme: theme,
                            label: 'Все',
                            isSelected: _selectedRoleFilter == null,
                            onTap: () {
                              setState(() => _selectedRoleFilter = null);
                              _loadUsers();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            theme: theme,
                            label: 'Ученики',
                            icon: Icons.school,
                            color: Colors.blue,
                            isSelected: _selectedRoleFilter == 'student',
                            onTap: () {
                              setState(() => _selectedRoleFilter = 'student');
                              _loadUsers();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            theme: theme,
                            label: 'Учителя',
                            icon: Icons.person,
                            color: Colors.green,
                            isSelected: _selectedRoleFilter == 'teacher',
                            onTap: () {
                              setState(() => _selectedRoleFilter = 'teacher');
                              _loadUsers();
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            theme: theme,
                            label: 'Админы',
                            icon: Icons.admin_panel_settings,
                            color: Colors.red,
                            isSelected: _selectedRoleFilter == 'admin',
                            onTap: () {
                              setState(() => _selectedRoleFilter = 'admin');
                              _loadUsers();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Счетчик результатов
          if (!_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FadeInListItem(
                  index: 2,
                  child: Text(
                    'Найдено: ${_filteredUsers.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // Список пользователей
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: ImprovedLoadingIndicator()),
            )
          else if (_filteredUsers.isEmpty)
            SliverFillRemaining(
              child: Center(
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
                      'Пользователи не найдены',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = _filteredUsers[index];
                    return FadeInListItem(
                      index: index + 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserCard(theme, user),
                      ),
                    );
                  },
                  childCount: _filteredUsers.length,
                ),
              ),
            ),

          // Нижний отступ
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    chipColor.withOpacity(0.2),
                    chipColor.withOpacity(0.1),
                  ],
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? chipColor.withOpacity(0.5)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(ThemeData theme, User user) {
    final roleColor = _roleColor(user.role, theme);

    return AnimatedCard(
      onTap: () => _editUser(user),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Аватар с иконкой роли
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  roleColor,
                  roleColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _roleIcon(user.role),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Информация о пользователе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? user.phone ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: roleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Кнопка редактирования
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

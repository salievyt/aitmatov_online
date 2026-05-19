import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../admin/presentation/admin_analytics_screen.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../admin/presentation/admin_schedule_screen.dart';
import '../../admin/presentation/admin_users_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../home/presentation/schedule_screen.dart';
import '../../messenger/presentation/messenger_groups_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../teacher/presentation/teacher_analytics_screen.dart';
import '../../teacher/presentation/teacher_courses_screen.dart';
import '../../teacher/presentation/teacher_dashboard_screen.dart';
import '../../teacher/presentation/teacher_messages_screen.dart';

class RoleNavigationScreen extends StatefulWidget {
  final String role;

  const RoleNavigationScreen({super.key, required this.role});

  @override
  State<RoleNavigationScreen> createState() => _RoleNavigationScreenState();
}

class _RoleNavigationScreenState extends State<RoleNavigationScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late List<_RoleTab> _tabs;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabs = _tabsForRole(widget.role);
    _currentIndex = 0;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _tabs.length,
                (index) => _buildNavItem(
                  theme,
                  _tabs[index],
                  index,
                  _currentIndex == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    ThemeData theme,
    _RoleTab tab,
    int index,
    bool isSelected,
  ) {
    // final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.05),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation
              ScaleTransition(
                scale: isSelected
                    ? Tween<double>(begin: 1.0, end: 1.1).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.elasticOut,
                        ),
                      )
                    : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Icon(
                    tab.icon,
                    color: isSelected ? Colors.white : theme.colorScheme.outline,
                    size: isSelected ? 24 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Label
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 300),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: isSelected
                      ? theme.textTheme.labelSmall!.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        )
                      : theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_RoleTab> _tabsForRole(String role) {
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole == 'teacher') {
      return const [
        _RoleTab(
          icon: Icons.dashboard_outlined,
          label: 'Главная',
          screen: TeacherDashboardScreen(),
        ),
        _RoleTab(
          icon: Icons.menu_book_outlined,
          label: 'Курсы',
          screen: TeacherCoursesScreen(),
        ),
        _RoleTab(
          icon: Icons.forum_outlined,
          label: 'Сообщения',
          screen: TeacherMessagesScreen(),
        ),
        _RoleTab(
          icon: Icons.insights_outlined,
          label: 'Аналитика',
          screen: TeacherAnalyticsScreen(),
        ),
        _RoleTab(
          icon: Icons.person_outline,
          label: 'Профиль',
          screen: ProfileScreen(),
        ),
      ];
    }

    if (normalizedRole == 'admin') {
      return const [
        _RoleTab(
          icon: Icons.dashboard_outlined,
          label: 'Главная',
          screen: AdminDashboardScreen(),
        ),
        _RoleTab(
          icon: Icons.group_outlined,
          label: 'Пользователи',
          screen: AdminUsersScreen(),
        ),
        _RoleTab(
          icon: Icons.calendar_today_outlined,
          label: 'Расписание',
          screen: AdminScheduleScreen(),
        ),
        _RoleTab(
          icon: Icons.analytics_outlined,
          label: 'Аналитика',
          screen: AdminAnalyticsScreen(),
        ),
        _RoleTab(
          icon: Icons.person_outline,
          label: 'Профиль',
          screen: ProfileScreen(),
        ),
      ];
    }

    // Student role (default)
    return const [
      _RoleTab(
        icon: Icons.home_outlined,
        label: 'Главная',
        screen: HomeScreen(),
      ),
      _RoleTab(
        icon: Icons.calendar_today_outlined,
        label: 'Расписание',
        screen: ScheduleScreen(),
      ),
      _RoleTab(
        icon: Icons.forum_outlined,
        label: 'Чаты',
        screen: MessengerGroupsScreen(),
      ),
      _RoleTab(
        icon: Icons.person_outline,
        label: 'Профиль',
        screen: ProfileScreen(),
      ),
    ];
  }
}

class _RoleTab {
  final IconData icon;
  final String label;
  final Widget screen;

  const _RoleTab({required this.icon, required this.label, required this.screen});
}

Future<String> roleHomePathForCurrentUser(BuildContext context) async {
  final result = await context.read<AuthRepository>().getCurrentUser(forceRefresh: true);
  User? user;
  result.fold((_) => user = null, (value) => user = value);

  if (user == null) return '/student';
  if (user!.isAdmin) return '/admin';
  if (user!.isTeacher) return '/teacher';
  return '/student';
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await context.read<AuthRepository>().getCurrentUser(forceRefresh: true);
    me.fold((_) {}, (u) => _currentUser = u);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return const Scaffold(body: Center(child: Text('Доступ только для администратора')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Панель администратора')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Entry(icon: Icons.analytics_outlined, title: 'Аналитика платформы', subtitle: 'Регистрации, роли, онлайн, сводные метрики', onTap: () => context.push('/admin/analytics')),
          _Entry(icon: Icons.feedback_outlined, title: 'Обратная связь', subtitle: 'Сообщения пользователей и их рейтинг', onTap: () => context.push('/admin/feedback')),
          _Entry(icon: Icons.history_edu_outlined, title: 'Логи системы', subtitle: 'Действия пользователей через /api/logs', onTap: () => context.push('/admin/logs')),
          _Entry(icon: Icons.manage_accounts_outlined, title: 'Управление пользователями', subtitle: 'Пользователи, роли, блокировка/разблокировка', onTap: () => context.push('/admin/users')),
          _Entry(icon: Icons.support_agent_outlined, title: 'Управление учителями', subtitle: 'Быстрый контроль учителей и их доступа', onTap: () => context.push('/admin/users?role=teacher')),
          _Entry(icon: Icons.calendar_month_outlined, title: 'Редактирование расписания', subtitle: 'Создание, изменение и удаление занятий по дням недели', onTap: () => context.push('/admin/schedule')),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _Entry({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap),
    );
  }
}

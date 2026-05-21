import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await context.read<AuthRepository>().getCurrentUser(forceRefresh: true);
    me.fold((_) {}, (u) => _user = u);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null || !_user!.isTeacher) return const Scaffold(body: Center(child: Text('Доступ только для преподавателя')));

    return Scaffold(
      appBar: AppBar(title: const Text('Кабинет преподавателя')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Entry(icon: Icons.menu_book_outlined, title: 'Мои курсы и уроки', subtitle: 'Только ваши темы и уроки', onTap: () => context.push('/teacher/courses')),
          _Entry(icon: Icons.fact_check_outlined, title: 'Оценки учеников', subtitle: 'Список учеников и выставление оценок', onTap: () => context.push('/teacher/grades')),
          _Entry(icon: Icons.analytics_outlined, title: 'Аналитика класса', subtitle: 'Прогресс и завершения по вашим курсам', onTap: () => context.push('/teacher/analytics')),
          _Entry(icon: Icons.poll_outlined, title: 'Опросы', subtitle: 'Опросы, объявленные администрацией', onTap: () => context.push('/surveys')),
          _Entry(icon: Icons.support_agent_outlined, title: 'Обращения', subtitle: 'Отправить обращение в администрацию', onTap: () => context.push('/feedback/request')),
          _Entry(icon: Icons.mic_outlined, title: 'Голосовые сообщения', subtitle: 'Коммуникация с учениками', onTap: () => context.push('/teacher/messages')),
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

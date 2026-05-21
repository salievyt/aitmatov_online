import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/entities/admin_models.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/repositories/user_management_repository.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  PlatformAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userRepo = context.read<UserManagementRepository>();
    final adminRepo = context.read<AdminRepository>();
    setState(() => _isLoading = true);
    final result = await userRepo.getUsers();
    final analyticsResult = await adminRepo.getPlatformAnalytics();
    result.fold((_) {}, (data) => _users = data);
    analyticsResult.fold((_) {}, (data) => _analytics = data);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final teachers = _users.where((e) => e.isTeacher).length;
    final students = _users.where((e) => e.isStudent).length;
    final admins = _users.where((e) => e.isAdmin).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика платформы')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Tile(label: 'Всего зарегистрировано', value: _users.length.toString(), icon: Icons.people),
                _Tile(label: 'Учителя', value: teachers.toString(), icon: Icons.school),
                _Tile(label: 'Студенты', value: students.toString(), icon: Icons.person),
                _Tile(label: 'Администраторы', value: admins.toString(), icon: Icons.admin_panel_settings),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.online_prediction_outlined),
                    title: Text('Онлайн сейчас'),
                    subtitle: Text('Подключи backend endpoint presence/online для точного онлайна.'),
                  ),
                ),
                if (_analytics != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.insights_outlined),
                      title: const Text('API аналитика'),
                      subtitle: Text('overview: ${_analytics!.overview}\nusers: ${_analytics!.users}\nengagement: ${_analytics!.engagement}'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Tile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

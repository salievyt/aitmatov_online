import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/admin_models.dart';
import '../../../domain/repositories/admin_repository.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  bool _loading = true;
  List<AuditLogItem> _logs = const [];
  String _action = '';

  String _actionLabel(String action) {
    switch (action) {
      case 'login':
        return 'Вход в аккаунт';
      case 'signup':
        return 'Регистрация';
      case 'course_published':
        return 'Публикация курса';
      case 'lesson_published':
        return 'Публикация урока';
      case 'other':
        return 'Другое действие';
      default:
        return action;
    }
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await context.read<AdminRepository>().getLogs(action: _action.isEmpty ? null : _action);
    result.fold((_) {}, (data) => _logs = data);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Логи системы')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            initialValue: _action,
            items: const [
              DropdownMenuItem(value: '', child: Text('Все действия')),
              DropdownMenuItem(value: 'login', child: Text('Вход в аккаунт')),
              DropdownMenuItem(value: 'signup', child: Text('Регистрация')),
              DropdownMenuItem(value: 'course_published', child: Text('Публикация курса')),
              DropdownMenuItem(value: 'lesson_published', child: Text('Публикация урока')),
              DropdownMenuItem(value: 'other', child: Text('Другое действие')),
            ],
            onChanged: (v) { _action = v ?? ''; _load(); },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, i) {
                    final log = _logs[i];
                    return Card(
                      child: ListTile(
                        title: Text('${_actionLabel(log.action)} • ${log.user}'),
                        subtitle: Text('Объект: ${log.targetName}\nДата: ${log.createdAt ?? ''}'),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

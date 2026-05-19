import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_management_repository.dart';

class AdminUsersScreen extends StatefulWidget {
  final String? roleFilter;
  const AdminUsersScreen({super.key, this.roleFilter});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final result = await context.read<UserManagementRepository>().getUsers(role: widget.roleFilter);
    result.fold((_) {}, (users) => _users = users);
    setState(() => _isLoading = false);
  }

  Future<void> _editUser(User user) async {
    String role = user.role;
    bool isActive = true;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text('Пользователь: ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('student')),
                  DropdownMenuItem(value: 'teacher', child: Text('teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                ],
                onChanged: (v) => setStateDialog(() => role = v ?? 'student'),
              ),
              SwitchListTile(
                value: isActive,
                title: const Text('is_active'),
                onChanged: (v) => setStateDialog(() => isActive = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final repository = context.read<UserManagementRepository>();
                await repository.updateUser(user.id, {'role': role, 'is_active': isActive});
                if (!mounted) return;
                navigator.pop();
                _loadUsers();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Управление пользователями')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  child: ListTile(
                    title: Text(user.fullName),
                    subtitle: Text('${user.email ?? user.phone ?? ''} | ${user.role}'),
                    trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _editUser(user)),
                  ),
                );
              },
            ),
    );
  }
}

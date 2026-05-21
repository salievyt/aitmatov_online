import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/admin_models.dart';
import '../../../domain/repositories/admin_repository.dart';

class UserSurveysScreen extends StatefulWidget {
  const UserSurveysScreen({super.key});

  @override
  State<UserSurveysScreen> createState() => _UserSurveysScreenState();
}

class _UserSurveysScreenState extends State<UserSurveysScreen> {
  bool _loading = true;
  List<SurveyItem> _surveys = const [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await context.read<AdminRepository>().getSurveys();
    result.fold((_) {}, (data) => _surveys = data.where((e) => e.isPublished).toList());
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _submit(int id) async {
    final result = await context.read<AdminRepository>().submitSurvey(id);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ответ отправлен'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Опросы')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(child: Text('Нет активных опросов'))
              : ListView.builder(
                  itemCount: _surveys.length,
                  itemBuilder: (context, i) {
                    final s = _surveys[i];
                    return Card(
                      child: ListTile(
                        title: Text(s.title),
                        subtitle: Text(s.description ?? 'Без описания'),
                        trailing: FilledButton(
                          onPressed: () => _submit(s.id),
                          child: const Text('Ответить'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

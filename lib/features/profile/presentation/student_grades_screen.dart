import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/quarter_grade.dart';
import '../../../domain/repositories/progress_repository.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  bool _loading = true;
  String? _error;
  List<QuarterGrade> _grades = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await context.read<ProgressRepository>().getQuarterGrades();
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (items) => setState(() => _grades = items),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои оценки')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _grades.isEmpty
                  ? const Center(child: Text('Оценок пока нет'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _grades.length,
                        itemBuilder: (context, index) {
                          final grade = _grades[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(grade.courseTitle),
                              subtitle: Text('Четверть: ${grade.quarter}${(grade.notes ?? '').isNotEmpty ? '\n${grade.notes}' : ''}'),
                              trailing: CircleAvatar(
                                child: Text('${grade.grade}'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

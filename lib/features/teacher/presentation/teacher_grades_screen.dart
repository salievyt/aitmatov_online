import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/progress_repository.dart';
import '../../../domain/repositories/user_management_repository.dart';

class TeacherGradesScreen extends StatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  State<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends State<TeacherGradesScreen> {
  bool _loading = true;
  String? _error;
  List<User> _students = const [];
  List<Course> _courses = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userRepo = context.read<UserManagementRepository>();
    final courseRepo = context.read<CourseRepository>();

    setState(() {
      _loading = true;
      _error = null;
    });

    final studentsResult = await userRepo.getUsers(role: 'student');
    final coursesResult = await courseRepo.getCourses();

    String? error;
    List<User> students = const [];
    List<Course> courses = const [];

    studentsResult.fold((f) => error = f.message, (data) => students = data);
    coursesResult.fold((f) => error ??= f.message, (data) => courses = data);

    if (!mounted) return;
    setState(() {
      _students = students;
      _courses = courses;
      _error = error;
      _loading = false;
    });
  }

  Future<void> _openSetGradeDialog(User student) async {
    if (_courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет доступных курсов для оценки')));
      return;
    }

    int? selectedCourseId = _courses.first.id;
    int selectedQuarter = 1;
    int selectedGrade = 5;
    final notesController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Оценка: ${student.fullName}'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedCourseId,
                  decoration: const InputDecoration(labelText: 'Курс'),
                  items: _courses
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.title)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedCourseId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedQuarter,
                  decoration: const InputDecoration(labelText: 'Четверть'),
                  items: const [1, 2, 3, 4]
                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedQuarter = v ?? 1),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedGrade,
                  decoration: const InputDecoration(labelText: 'Оценка'),
                  items: const [1, 2, 3, 4, 5]
                      .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedGrade = v ?? 5),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Комментарий (необязательно)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить')),
        ],
      ),
    );

    if (saved != true || selectedCourseId == null || !mounted) return;

    final result = await context.read<ProgressRepository>().createQuarterGrade(
          userId: student.id,
          courseId: selectedCourseId!,
          quarter: selectedQuarter,
          grade: selectedGrade,
          notes: notesController.text,
        );

    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оценка сохранена'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оценки учеников')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _students.isEmpty
                  ? const Center(child: Text('Список учеников пуст'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(student.fullName),
                              subtitle: Text(student.school ?? 'Без школы'),
                              trailing: const Icon(Icons.edit_outlined),
                              onTap: () => _openSetGradeDialog(student),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

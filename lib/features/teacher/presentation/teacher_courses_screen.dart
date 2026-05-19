import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/course_repository.dart';

class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final authRepository = context.read<AuthRepository>();
    final courseRepository = context.read<CourseRepository>();
    final me = await authRepository.getCurrentUser(forceRefresh: true);
    User? current;
    me.fold((_) {}, (u) => current = u);
    if (current == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await courseRepository.getCourses();
    result.fold((_) {}, (courses) {
      _courses = courses.where((c) => c.teacherId == current!.id).toList();
    });
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои курсы и уроки')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return Card(
                  child: ListTile(
                    title: Text(course.title),
                    subtitle: Text('teacher_id=${course.teacherId ?? '-'}'),
                    trailing: FilledButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Подключи create/update/delete endpoints уроков для полного CRUD.'))),
                      child: const Text('Уроки'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/progress_repository.dart';
import '../../../domain/repositories/user_management_repository.dart';

/// Современный экран оценок с улучшенным UX/UI
class TeacherGradesScreen extends StatefulWidget {
  const TeacherGradesScreen({super.key});

  @override
  State<TeacherGradesScreen> createState() => _TeacherGradesScreenState();
}

class _TeacherGradesScreenState extends State<TeacherGradesScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  List<User> _students = const [];
  List<Course> _courses = const [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    _animationController.forward();
  }

  Future<void> _openSetGradeDialog(User student) async {
    if (_courses.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Нет доступных курсов для оценки'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    int? selectedCourseId = _courses.first.id;
    int selectedQuarter = 1;
    int selectedGrade = 5;
    final notesController = TextEditingController();

    final theme = Theme.of(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.grade,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Выставить оценку'),
                  Text(
                    student.fullName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'Курс',
                    prefixIcon: const Icon(Icons.menu_book_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _courses
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.title),
                          ))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => selectedCourseId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedQuarter,
                  decoration: InputDecoration(
                    labelText: 'Четверть',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [1, 2, 3, 4]
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text('$q четверть'),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setStateDialog(() => selectedQuarter = v ?? 1),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedGrade,
                  decoration: InputDecoration(
                    labelText: 'Оценка',
                    prefixIcon: const Icon(Icons.star_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [1, 2, 3, 4, 5]
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Row(
                              children: [
                                Text('$g'),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: _getGradeColor(g),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setStateDialog(() => selectedGrade = v ?? 5),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Комментарий',
                    hintText: 'Необязательно',
                    prefixIcon: const Icon(Icons.note_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Сохранить'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (saved != true || selectedCourseId == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<ProgressRepository>().createQuarterGrade(
          userId: student.id,
          courseId: selectedCourseId!,
          quarter: selectedQuarter,
          grade: selectedGrade,
          notes: notesController.text,
        );

    if (!mounted) return;
    result.fold(
      (f) => messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(f.message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      (_) => messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Оценка успешно сохранена'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static Color _getGradeColor(int grade) {
    switch (grade) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: ImprovedLoadingIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Современный App Bar
          SliverAppBar(
            elevation: 0,
            floating: true,
            snap: true,
            expandedHeight: 120,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Оценки учеников',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_students.length} ${_getStudentWord(_students.length)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      Colors.green.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Список студентов
          _students.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет учеников',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Список учеников пуст',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = _students[index];
                        return FadeInListItem(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildStudentCard(
                              theme: theme,
                              isDark: isDark,
                              student: student,
                            ),
                          ),
                        );
                      },
                      childCount: _students.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStudentCard({
    required ThemeData theme,
    required bool isDark,
    required User student,
  }) {
    const color = Colors.green;

    return AnimatedCard(
      onTap: () => _openSetGradeDialog(student),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ],
      ),
      border: Border.all(
        color: color.withOpacity(0.3),
        width: 1.5,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              boxShadow: AppShadows.avatar(color, isDark: isDark),
            ),
            child: const Icon(
              Icons.person,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.school ?? 'Без школы',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _getStudentWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'ученик';
    if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'ученика';
    }
    return 'учеников';
  }
}

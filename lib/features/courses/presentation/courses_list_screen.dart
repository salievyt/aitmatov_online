import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/empty_state_widget.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/repositories/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesListScreen extends StatefulWidget {
  final int? aitmatovThemeId;
  final int? subjectId;
  final bool? isAitmatov;

  const CoursesListScreen({
    super.key,
    this.aitmatovThemeId,
    this.subjectId,
    this.isAitmatov,
  });

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await context.read<CourseRepository>().getCourses(
      aitmatovThemeId: widget.aitmatovThemeId,
      subjectId: widget.subjectId,
      isAitmatov: widget.isAitmatov,
    );
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (courses) => setState(() => _courses = courses),
    );
    setState(() => _isLoading = false);
  }

  String _getScreenTitle() {
    if (widget.aitmatovThemeId != null) {
      return 'Курсы по теме Айтматова';
    } else if (widget.subjectId != null) {
      return 'Курсы по предмету';
    } else if (widget.isAitmatov == true) {
      return 'Курсы Айтматова';
    }
    return 'Все курсы';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCourses,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Ошибка загрузки',
                    subtitle: _error!,
                    buttonText: 'Повторить',
                    onPressed: _loadCourses,
                  )
                : _courses.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.menu_book,
                        title: 'Нет курсов',
                        subtitle: 'Курсы по выбранным критериям не найдены',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => context.push('/courses/${course.id}'),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (course.image != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            course.image!,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      Text(
                                        course.title,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (course.description != null && course.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          course.description!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.subject, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(course.subject.name, style: theme.textTheme.labelSmall),
                                          const SizedBox(width: 12),
                                          Icon(Icons.menu_book, size: 16, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text('${course.lessons.length} уроков', style: theme.textTheme.labelSmall),
                                          if (course.classLevel != null) ...[
                                            const SizedBox(width: 12),
                                            Icon(Icons.school, size: 16, color: theme.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text('${course.classLevel} класс', style: theme.textTheme.labelSmall),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
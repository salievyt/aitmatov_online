import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/controllers/async_controller.dart';
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
  late final AsyncController<List<Course>> _controller;

  @override
  void initState() {
    super.initState();
    _controller = AsyncController(
      loader: () => context.read<CourseRepository>().getCourses(
            aitmatovThemeId: widget.aitmatovThemeId,
            subjectId: widget.subjectId,
            isAitmatov: widget.isAitmatov,
          ),
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async => _controller.load();

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
        child: ValueListenableBuilder<AsyncState<List<Course>>>(
          valueListenable: _controller.state,
          builder: (context, state, child) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Ошибка загрузки',
                subtitle: state.error ?? 'Ошибка загрузки',
                buttonText: 'Повторить',
                onPressed: _loadCourses,
              );
            }

            final courses = state.data ?? const [];
            if (courses.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.menu_book,
                title: 'Нет курсов',
                subtitle: 'Курсы по выбранным критериям не найдены',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
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
            );
          },
        ),
      ),
    );
  }
}

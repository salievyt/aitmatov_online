import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/utils/empty_state_widget.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/repositories/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseScreen extends StatefulWidget {
  final int courseId;

  const CourseScreen({super.key, required this.courseId});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late final AsyncController<Course> _courseController;
  late final AsyncController<List<Lesson>> _lessonsController;

  @override
  void initState() {
    super.initState();
    _courseController = AsyncController(loader: () => context.read<CourseRepository>().getCourseById(widget.courseId));
    _lessonsController = AsyncController(loader: () => context.read<CourseRepository>().getLessons(widget.courseId));
    _courseController.load();
    _lessonsController.load();
  }

  @override
  void dispose() {
    _courseController.dispose();
    _lessonsController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    await Future.wait([_courseController.load(), _lessonsController.load()]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<AsyncState<Course>>(
      valueListenable: _courseController.state,
      builder: (context, courseState, child) {
        return ValueListenableBuilder<AsyncState<List<Lesson>>>(
          valueListenable: _lessonsController.state,
          builder: (context, lessonsState, child) {
            if (courseState.isLoading || lessonsState.isLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (courseState.hasError || lessonsState.hasError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Курс')),
                body: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Ошибка загрузки',
                  subtitle: courseState.error ?? lessonsState.error ?? 'Ошибка загрузки',
                  buttonText: 'Повторить',
                  onPressed: _loadCourse,
                ),
              );
            }

            final course = courseState.data;
            final lessons = lessonsState.data ?? const [];
            if (course == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Курс')),
                body: const EmptyStateWidget(
                  icon: Icons.book_outlined,
                  title: 'Курс не найден',
                  subtitle: 'Курс с таким ID не существует',
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(course.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: CustomScrollView(
                slivers: [
                        SliverToBoxAdapter(
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
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  course.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (course.description != null)
                                  Text(
                                    course.description!,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.subject, size: 20, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(course.subject.name),
                                    const SizedBox(width: 16),
                                    if (course.classLevel != null) ...[
                                      Icon(Icons.school, size: 20, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text('${course.classLevel} класс'),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Уроки (${lessons.length})',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final lesson = lessons[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    child: ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getContentTypeIcon(lesson.contentType),
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(lesson.title),
                                      subtitle: Text('Урок ${lesson.order}'),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () => context.push('/courses/${widget.courseId}/lessons/${lesson.id}'),
                                    ),
                                  ),
                                );
                              },
                              childCount: lessons.length,
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.audiotrack;
      case 'text':
      default:
        return Icons.article;
    }
  }
}

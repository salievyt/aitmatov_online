import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  Course? _course;
  List<Lesson> _lessons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final courseResult = await context.read<CourseRepository>().getCourseById(widget.courseId);
    final lessonsResult = await context.read<CourseRepository>().getLessons(widget.courseId);

    courseResult.fold(
      (failure) => setState(() => _error = failure.message),
      (course) => setState(() => _course = course),
    );

    lessonsResult.fold(
      (failure) => setState(() => _error = failure.message),
      (lessons) => setState(() => _lessons = lessons),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_course?.title ?? 'Курс'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Ошибка загрузки',
                  subtitle: _error!,
                  buttonText: 'Повторить',
                  onPressed: _loadCourse,
                )
              : _course == null
                  ? const EmptyStateWidget(
                      icon: Icons.book_outlined,
                      title: 'Курс не найден',
                      subtitle: 'Курс с таким ID не существует',
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_course!.image != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _course!.image!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  _course!.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (_course!.description != null)
                                  Text(
                                    _course!.description!,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.subject, size: 20, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(_course!.subject.name),
                                    const SizedBox(width: 16),
                                    if (_course!.classLevel != null) ...[
                                      Icon(Icons.school, size: 20, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text('${_course!.classLevel} класс'),
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
                              'Уроки (${_lessons.length})',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final lesson = _lessons[index];
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
                              childCount: _lessons.length,
                            ),
                          ),
                        ),
                      ],
                    ),
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
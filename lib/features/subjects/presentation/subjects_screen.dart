import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/empty_state_widget.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/repositories/course_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubjectsScreen extends StatefulWidget {
  final String slug;

  const SubjectsScreen({super.key, required this.slug});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
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
    final result = await context.read<CourseRepository>().getCourses();
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (courses) => setState(() => _courses =
          courses.where((c) => c.subject.slug == widget.slug).toList()),
    );
    setState(() => _isLoading = false);
  }

  void _showCourseFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Фильтр курсов',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('По названию'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('По дате'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.slug.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCourseFilter,
          ),
        ],
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
                    ? EmptyStateWidget(
                        icon: Icons.menu_book,
                        title: 'Нет курсов',
                        subtitle: 'Для этого предмета пока нет курсов',
                        buttonText: 'Обновить',
                        onPressed: _loadCourses,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
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
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Text(
                                      course.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    if (course.description != null &&
                                        course.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        course.description!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withOpacity(0.6)),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.menu_book,
                                            size: 16,
                                            color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text('${course.lessons.length} уроков',
                                            style: theme.textTheme.labelSmall),
                                      ],
                                    ),
                                  ],
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

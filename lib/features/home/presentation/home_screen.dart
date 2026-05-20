import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/empty_state_widget.dart';
import '../../../domain/entities/subject.dart';
import '../../../domain/repositories/subject_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Subject> _subjects = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _loadSubjects();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await context.read<SubjectRepository>().getSubjects();
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (subjects) => setState(() => _subjects = subjects),
    );
    setState(() => _isLoading = false);
  }

  

  void _showFilterBottomSheet() {
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
                Text('Фильтр', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text('По классу'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.book),
                  title: const Text('По предмету'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_stories),
                  title: const Text('Темы Айтматова'),
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSubjects,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorState()
                : _subjects.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.menu_book,
                        title: 'Нет предметов',
                        subtitle: 'Пока не добавлено ни одного предмета',
                      )
                    : CustomScrollView(
                        slivers: [
                          // Modern App Bar
                          SliverAppBar(
                            elevation: 0,
                            floating: true,
                            snap: true,
                            backgroundColor: theme.scaffoldBackgroundColor,
                            flexibleSpace: FlexibleSpaceBar(
                              title: Text(
                                'Айтматов онлайн',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              centerTitle: false,
                              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                            ),
                            // actions: [
                            //   _buildActionButton(
                            //     icon: Icons.filter_list,
                            //     onPressed: _showFilterBottomSheet,
                            //   ),
                            //   _buildActionButton(
                            //     icon: Icons.calendar_today_outlined,
                            //     onPressed: () => context.push('/schedule'),
                            //   ),
                            //   _buildActionButton(
                            //     icon: Icons.forum_outlined,
                            //     onPressed: () => context.push('/messenger'),
                            //   ),
                            //   _buildActionButton(
                            //     icon: Icons.person_outline,
                            //     onPressed: () => context.push('/profile'),
                            //   ),
                            // ],
                          ),
                          // Featured Card - Aitmatov World
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: _buildFeaturedCard(theme, isDark),
                            ),
                          ),
                          // Subjects Section Title
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Предметы',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${_subjects.length} шт',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Subjects Grid
                          SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.3,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final subject = _subjects[index];
                                  return _buildSubjectCard(
                                    theme,
                                    subject,
                                    index,
                                  );
                                },
                                childCount: _subjects.length,
                              ),
                            ),
                          ),
                          // Bottom padding
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, size: 22),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildFeaturedCard(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/aitmatov'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.secondary.withOpacity(0.15),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: theme.colorScheme.secondary.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/aitmatov'),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.secondary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Мир Айтматова',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Касандра, экология, память',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red[400] : Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Что-то пошло не так',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Ошибка загрузки',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSubjects,
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme, Subject subject, int index) {
    final color = _getColorForIndex(theme, index);

    return GestureDetector(
      onTap: () => context.push('/subjects/${subject.slug}'),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/subjects/${subject.slug}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                    ),
                    child: Icon(
                      _iconFromName(subject.icon),
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subject.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(ThemeData theme, int index) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'calculate':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'history':
        return Icons.history_edu;
      case 'book':
        return Icons.book;
      case 'nature':
        return Icons.nature;
      case 'language':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}
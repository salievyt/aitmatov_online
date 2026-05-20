import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/controllers/async_controller.dart';
import '../../../core/utils/empty_state_widget.dart';
import '../../../domain/entities/aitmatov_theme.dart';
import '../../../domain/repositories/aitmatov_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AitmatovScreen extends StatefulWidget {
  const AitmatovScreen({super.key});

  @override
  State<AitmatovScreen> createState() => _AitmatovScreenState();
}

class _AitmatovScreenState extends State<AitmatovScreen> {
  late final AsyncController<List<AitmatovTheme>> _controller;

  @override
  void initState() {
    super.initState();
    _controller = AsyncController(loader: () => context.read<AitmatovRepository>().getAitmatovThemes());
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadThemes() async => _controller.load();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мир Айтматова'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ValueListenableBuilder<AsyncState<List<AitmatovTheme>>>(
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
              onPressed: _loadThemes,
            );
          }

          final themes = state.data ?? const [];
          if (themes.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.auto_stories,
              title: 'Нет тем',
              subtitle: 'Темы Айтматова пока не добавлены',
            );
          }

          return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Чингиз Айтматов — голос кыргызской души, писатель-миротворец, чьи произведения затрагивают вечные темы: любовь, природу, войну и человечность.',
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final themeItem = themes[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => context.push('/courses?aitmatov_theme=${themeItem.id}'),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: _getThemeColor(themeItem.icon).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(_getThemeIcon(themeItem.icon), color: _getThemeColor(themeItem.icon), size: 28),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(themeItem.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                                  const SizedBox(height: 4),
                                                  Text(themeItem.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_ios, size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: themes.length,
                            ),
                          ),
                        ),
              ],
            );
          },
        ),
    );
  }

  IconData _getThemeIcon(String? iconName) {
    switch (iconName) {
      case 'done':
        return Icons.done_outlined;
      case 'forest':
        return Icons.forest_outlined;
      case 'military_tech':
        return Icons.military_tech_outlined;
      default:
        return Icons.auto_stories;
    }
  }

  Color _getThemeColor(String? iconName) {
    switch (iconName) {
      case 'done':
        return const Color(0xFFD4A373);
      case 'forest':
        return const Color(0xFF81B29A);
      case 'military_tech':
        return const Color(0xFFE07A5F);
      default:
        return const Color(0xFF6B73FF);
    }
  }
}

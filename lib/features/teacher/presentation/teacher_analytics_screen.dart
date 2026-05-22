import 'package:flutter/material.dart';

import '../../../core/presentation/widgets/animated_card.dart';
import '../../../core/presentation/widgets/animated_widgets.dart';

/// Современный экран аналитики класса с улучшенным UX/UI
class TeacherAnalyticsScreen extends StatefulWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  State<TeacherAnalyticsScreen> createState() =>
      _TeacherAnalyticsScreenState();
}

class _TeacherAnalyticsScreenState extends State<TeacherAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    'Аналитика класса',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Прогресс и статистика',
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
                      Colors.purple.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Статистические карточки
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeInListItem(
                  index: 0,
                  child: _buildAnalyticsCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.bar_chart,
                    title: 'Завершение уроков',
                    subtitle: 'Подключи teacher analytics endpoint',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInListItem(
                  index: 1,
                  child: _buildAnalyticsCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.timeline,
                    title: 'Динамика успеваемости',
                    subtitle: 'Подключи teacher analytics endpoint',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInListItem(
                  index: 2,
                  child: _buildAnalyticsCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.trending_up,
                    title: 'Средний балл',
                    subtitle: 'Статистика по оценкам',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInListItem(
                  index: 3,
                  child: _buildAnalyticsCard(
                    theme: theme,
                    isDark: isDark,
                    icon: Icons.access_time,
                    title: 'Активность учеников',
                    subtitle: 'Время в системе',
                    color: Colors.orange,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return AnimatedCard(
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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.3 : 0.4),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
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
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

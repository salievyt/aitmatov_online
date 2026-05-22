import 'package:flutter/material.dart';

import '../../../domain/constants/achievements.dart';
import '../../../domain/entities/gamification.dart';

/// Экран с достижениями пользователя
class AchievementsScreen extends StatelessWidget {
  final GamificationProgress progress;

  const AchievementsScreen({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allAchievements = Achievements.all;
    final unlockedIds = progress.unlockedAchievements.map((a) => a.id).toSet();

    // Группировка по категориям
    final byCategory = <AchievementCategory, List<Achievement>>{};
    for (final achievement in allAchievements) {
      byCategory.putIfAbsent(achievement.category, () => []).add(achievement);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${unlockedIds.length}/${allAchievements.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Прогресс
          _buildProgressCard(context, unlockedIds.length, allAchievements.length),
          const SizedBox(height: 24),
          // Достижения по категориям
          ...byCategory.entries.map((entry) {
            return _buildCategorySection(
              context,
              entry.key,
              entry.value,
              unlockedIds,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int unlocked, int total) {
    final theme = Theme.of(context);
    final progress = unlocked / total;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Прогресс достижений',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlocked из $total разблокировано',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    AchievementCategory category,
    List<Achievement> achievements,
    Set<String> unlockedIds,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _getCategoryName(category),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...achievements.map((achievement) {
          final isUnlocked = unlockedIds.contains(achievement.id);
          return _AchievementTile(
            achievement: achievement,
            isUnlocked: isUnlocked,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learning:
        return '📚 Обучение';
      case AchievementCategory.streak:
        return '🔥 Стрики';
      case AchievementCategory.social:
        return '👥 Социальные';
      case AchievementCategory.aitmatov:
        return '📖 Айтматов';
      case AchievementCategory.special:
        return '✨ Специальные';
    }
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarityColor = _getRarityColor(achievement.rarity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isUnlocked ? 2 : 0,
      color: isUnlocked ? null : theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnlocked
            ? BorderSide(color: rarityColor.withOpacity(0.5), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked
                ? rarityColor.withOpacity(0.2)
                : theme.colorScheme.surfaceVariant,
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 24,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUnlocked
                    ? theme.colorScheme.onSurface.withOpacity(0.7)
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${achievement.xpReward} XP',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.amber.shade700 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isUnlocked
            ? Icon(Icons.check_circle, color: rarityColor)
            : Icon(Icons.lock_outline, color: Colors.grey.shade400),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.amber;
    }
  }
}

/// Экран лидерборда
class LeaderboardScreen extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final LeaderboardType type;

  const LeaderboardScreen({
    super.key,
    required this.entries,
    this.type = LeaderboardType.global,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Показать фильтры (global, class, school, friends)
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Рейтинг пока пуст',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Начни учиться, чтобы попасть в топ!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _LeaderboardTile(
                  entry: entry,
                  showMedal: index < 3,
                );
              },
            ),
    );
  }

  String _getTitle() {
    switch (type) {
      case LeaderboardType.global:
        return 'Глобальный рейтинг';
      case LeaderboardType.classRoom:
        return 'Рейтинг класса';
      case LeaderboardType.school:
        return 'Рейтинг школы';
      case LeaderboardType.friends:
        return 'Рейтинг друзей';
    }
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool showMedal;

  const _LeaderboardTile({
    required this.entry,
    required this.showMedal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medal = _getMedal(entry.rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: entry.isCurrentUser ? 4 : 1,
      color: entry.isCurrentUser
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: entry.isCurrentUser
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Позиция или медаль
            if (showMedal && medal != null)
              Text(medal, style: const TextStyle(fontSize: 32))
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceVariant,
                ),
                child: Center(
                  child: Text(
                    '#${entry.rank}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // Аватар
            CircleAvatar(
              radius: 20,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.userName[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.userName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (entry.isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Вы',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              'Уровень ${entry.level}',
              style: theme.textTheme.bodySmall,
            ),
            if (entry.grade != null) ...[
              const Text(' • '),
              Text(
                '${entry.grade} класс',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalXp}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'XP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }
}

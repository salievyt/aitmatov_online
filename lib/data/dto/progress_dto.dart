import 'lesson_dto.dart';
import '../../domain/entities/progress_item.dart';

class ProgressDto {
  final int id;
  final LessonDto? lesson;
  final bool completed;
  final int? score;
  final String? notes;
  final DateTime updatedAt;

  ProgressDto({
    required this.id,
    this.lesson,
    required this.completed,
    this.score,
    this.notes,
    required this.updatedAt,
  });

  factory ProgressDto.fromJson(Map<String, dynamic> json) {
    return ProgressDto(
      id: json['id'] as int,
      lesson: json['lesson'] != null
          ? LessonDto.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
      completed: json['completed'] as bool,
      score: json['score'] as int?,
      notes: json['notes'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ProgressItem toEntity() => ProgressItem(
        id: id,
        lessonId: lesson?.id ?? 0,
        completed: completed,
        score: score,
        notes: notes,
        updatedAt: updatedAt,
      );
}

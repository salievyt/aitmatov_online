import 'package:equatable/equatable.dart';

class ProgressItem extends Equatable {
  final int id;
  final int lessonId;
  final bool completed;
  final int? score;
  final String? notes;
  final DateTime updatedAt;

  const ProgressItem({
    required this.id,
    required this.lessonId,
    required this.completed,
    this.score,
    this.notes,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, lessonId, completed, score, notes, updatedAt];
}

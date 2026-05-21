import 'package:equatable/equatable.dart';

class QuarterGrade extends Equatable {
  final int id;
  final int userId;
  final int courseId;
  final String courseTitle;
  final int quarter;
  final int grade;
  final String? notes;

  const QuarterGrade({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.quarter,
    required this.grade,
    this.notes,
  });

  @override
  List<Object?> get props => [id, userId, courseId, courseTitle, quarter, grade, notes];
}

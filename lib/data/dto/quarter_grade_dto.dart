import '../../domain/entities/quarter_grade.dart';

class QuarterGradeDto {
  final int id;
  final int userId;
  final int courseId;
  final String courseTitle;
  final int quarter;
  final int grade;
  final String? notes;

  QuarterGradeDto({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.quarter,
    required this.grade,
    this.notes,
  });

  factory QuarterGradeDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final course = json['course'];

    return QuarterGradeDto(
      id: json['id'] as int,
      userId: user is Map<String, dynamic> ? (user['id'] as int? ?? 0) : (user as int? ?? 0),
      courseId: course is Map<String, dynamic> ? (course['id'] as int? ?? 0) : (course as int? ?? 0),
      courseTitle: course is Map<String, dynamic> ? ((course['title'] as String?) ?? 'Без названия') : 'Без названия',
      quarter: json['quarter'] as int? ?? 1,
      grade: json['grade'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }

  QuarterGrade toEntity() => QuarterGrade(
        id: id,
        userId: userId,
        courseId: courseId,
        courseTitle: courseTitle,
        quarter: quarter,
        grade: grade,
        notes: notes,
      );
}

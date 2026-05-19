import 'lesson_dto.dart';
import 'subject_dto.dart';
import '../../domain/entities/course.dart';

class CourseDto {
  final int id;
  final String title;
  final String? description;
  final SubjectDto subject;
  final bool isAitmatov;
  final int? classLevel;
  final String? image;
  final int? teacherId;
  final List<LessonDto> lessons;

  CourseDto({
    required this.id,
    required this.title,
    this.description,
    required this.subject,
    required this.isAitmatov,
    this.classLevel,
    this.image,
    this.teacherId,
    this.lessons = const [],
  });

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    return CourseDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: SubjectDto.fromJson(json['subject'] as Map<String, dynamic>),
      isAitmatov: json['is_aitmatov'] as bool,
      classLevel: json['class_level'] as int?,
      image: json['image'] as String?,
      teacherId: json['teacher'] as int?,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => LessonDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Course toEntity() => Course(
        id: id,
        title: title,
        description: description,
        subject: subject.toEntity(),
        isAitmatov: isAitmatov,
        classLevel: classLevel,
        image: image,
        teacherId: teacherId,
        lessons: lessons.map((e) => e.toEntity()).toList(),
      );
}

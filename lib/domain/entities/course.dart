import 'package:aitmatov_app/domain/entities/lesson.dart';
import 'package:aitmatov_app/domain/entities/subject.dart';
import 'package:equatable/equatable.dart';


class Course extends Equatable {
  final int id;
  final String title;
  final String? description;
  final Subject subject;
  final bool isAitmatov;
  final int? classLevel;
  final String? image;
  final int? teacherId;
  final List<Lesson> lessons;

  const Course({
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

  @override
  List<Object?> get props => [id, title, description, subject, isAitmatov, classLevel, image, teacherId, lessons];
}

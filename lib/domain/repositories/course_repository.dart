import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/course.dart';
import '../entities/lesson.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getCourses({
    int? subjectId,
    bool? isAitmatov,
    int? aitmatovThemeId,
    int? classLevel,
  });
  Future<Either<Failure, Course>> getCourseById(int id);
  Future<Either<Failure, List<Lesson>>> getLessons(int courseId);
}

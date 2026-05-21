import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/progress_item.dart';
import '../entities/quarter_grade.dart';

abstract class ProgressRepository {
  Future<Either<Failure, List<ProgressItem>>> getProgress();
  Future<Either<Failure, ProgressItem>> updateProgress({
    required int lessonId,
    required bool completed,
    int? score,
    String? notes,
  });
  Future<Either<Failure, List<QuarterGrade>>> getQuarterGrades({int? userId});
  Future<Either<Failure, QuarterGrade>> createQuarterGrade({
    required int userId,
    required int courseId,
    required int quarter,
    required int grade,
    String? notes,
  });
}

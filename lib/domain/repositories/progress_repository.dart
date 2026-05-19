import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/progress_item.dart';

abstract class ProgressRepository {
  Future<Either<Failure, List<ProgressItem>>> getProgress();
  Future<Either<Failure, ProgressItem>> updateProgress({
    required int lessonId,
    required bool completed,
    int? score,
    String? notes,
  });
}

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/daily_schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<DailySchedule>>> getSchedules({int? day});
  Future<Either<Failure, DailySchedule>> createSchedule(Map<String, dynamic> data);
  Future<Either<Failure, DailySchedule>> updateSchedule(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteSchedule(int id);
}

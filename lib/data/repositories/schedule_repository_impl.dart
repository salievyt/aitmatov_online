import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/daily_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../dto/daily_schedule_dto.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ScheduleRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<DailySchedule>>> getSchedules({int? day}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/schedule/', queryParameters: {if (day != null) 'day': day});
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      return Right(results.map((e) => DailyScheduleDto.fromJson(e as Map<String, dynamic>).toEntity()).toList());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DailySchedule>> createSchedule(Map<String, dynamic> data) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.post('/schedule/', data: data);
      return Right(DailyScheduleDto.fromJson(response.data as Map<String, dynamic>).toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DailySchedule>> updateSchedule(int id, Map<String, dynamic> data) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.patch('/schedule/$id/', data: data);
      return Right(DailyScheduleDto.fromJson(response.data as Map<String, dynamic>).toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(int id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.delete('/schedule/$id/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

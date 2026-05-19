import 'package:aitmatov_app/core/errors/failures.dart';
import 'package:aitmatov_app/core/network/network_info.dart';
import 'package:aitmatov_app/data/dto/progress_dto.dart';
import 'package:aitmatov_app/domain/entities/progress_item.dart';
import 'package:aitmatov_app/domain/repositories/progress_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ProgressRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<ProgressItem>>> getProgress() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.get('/progress/');
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      final items = results
          .map((e) => ProgressDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProgressItem>> updateProgress({
    required int lessonId,
    required bool completed,
    int? score,
    String? notes,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.post('/progress/', data: {
        'lesson': lessonId,
        'completed': completed,
        if (score != null) 'score': score,
        if (notes != null) 'notes': notes,
      });
      final item = ProgressDto.fromJson(response.data as Map<String, dynamic>).toEntity();
      return Right(item);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

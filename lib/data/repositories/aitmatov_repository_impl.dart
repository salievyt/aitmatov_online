import 'package:aitmatov_app/core/errors/failures.dart';
import 'package:aitmatov_app/core/network/network_info.dart';
import 'package:aitmatov_app/data/dto/aitmatov_theme_dto.dart';
import 'package:aitmatov_app/domain/entities/aitmatov_theme.dart';
import 'package:aitmatov_app/domain/repositories/aitmatov_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AitmatovRepositoryImpl implements AitmatovRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AitmatovRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<AitmatovTheme>>> getAitmatovThemes() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.get('/aitmatov/themes/');
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      final themes = results
          .map((e) => AitmatovThemeDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return Right(themes);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
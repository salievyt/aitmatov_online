import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../dto/subject_dto.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  SubjectRepositoryImpl(this._dio, this._networkInfo);
  
  @override
  Future<Either<Failure, List<Subject>>> getSubjects() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.get('/subjects/');
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      final subjects = results
          .map((e) => SubjectDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return Right(subjects);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

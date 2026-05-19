import 'package:aitmatov_app/core/errors/failures.dart';
import 'package:aitmatov_app/core/network/network_info.dart';
import 'package:aitmatov_app/data/dto/course_dto.dart';
import 'package:aitmatov_app/data/dto/lesson_dto.dart';
import 'package:aitmatov_app/domain/entities/course.dart';
import 'package:aitmatov_app/domain/entities/lesson.dart';
import 'package:aitmatov_app/domain/repositories/course_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';


class CourseRepositoryImpl implements CourseRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  CourseRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<Course>>> getCourses({
    int? subjectId,
    bool? isAitmatov,
    int? aitmatovThemeId,
    int? classLevel,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final query = <String, dynamic>{};
      if (subjectId != null) query['subject'] = subjectId;
      if (isAitmatov != null) query['is_aitmatov'] = isAitmatov;
      if (aitmatovThemeId != null) query['aitmatov_theme'] = aitmatovThemeId;
      if (classLevel != null) query['class_level'] = classLevel;

      final response = await _dio.get('/courses/', queryParameters: query);
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      final courses = results
          .map((e) => CourseDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return Right(courses);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(int id) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.get('/courses/$id/');
      final course = CourseDto.fromJson(response.data as Map<String, dynamic>).toEntity();
      return Right(course);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Lesson>>> getLessons(int courseId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.get('/courses/$courseId/lessons/');
      final results = (response.data['results'] ?? response.data) as List<dynamic>;
      final lessons = results
          .map((e) => LessonDto.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      return Right(lessons);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

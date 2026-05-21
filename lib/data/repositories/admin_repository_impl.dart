import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/admin_models.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  AdminRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, PlatformAnalytics>> getPlatformAnalytics() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final overviewRes = await _dio.get('/analytics/overview/');
      final usersRes = await _dio.get('/analytics/users/');
      final engagementRes = await _dio.get('/analytics/engagement/');
      return Right(PlatformAnalytics(
        overview: _asMap(overviewRes.data),
        users: _asMap(usersRes.data),
        engagement: _asMap(engagementRes.data),
      ));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FeedbackSubmissionItem>>> getFeedbackSubmissions() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/feedback/submissions/');
      final body = _asMap(response.data);
      final results = (body['results'] ?? const <dynamic>[]) as List<dynamic>;
      final items = results.map((e) => _feedbackFromJson(e as Map<String, dynamic>)).toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FeedbackSubmissionItem>> createFeedbackSubmission({required String subject, required String message, String feedbackType = 'general', int? rating, String? contactEmail, bool isAnonymous = false}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.post('/feedback/submissions/', data: {
        'subject': subject,
        'message': message,
        'feedback_type': feedbackType,
        if (rating != null) 'rating': rating,
        if (contactEmail != null && contactEmail.isNotEmpty) 'contact_email': contactEmail,
        'is_anonymous': isAnonymous,
      });
      return Right(_feedbackFromJson(_asMap(response.data)));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AuditLogItem>>> getLogs({String? action, String? search}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final query = <String, dynamic>{};
      if (action != null && action.isNotEmpty) query['action'] = action;
      if (search != null && search.isNotEmpty) query['search'] = search;
      final response = await _dio.get('/logs/', queryParameters: query.isEmpty ? null : query);
      final body = _asMap(response.data);
      final results = (body['results'] ?? const <dynamic>[]) as List<dynamic>;
      final items = results.map((e) => _logFromJson(e as Map<String, dynamic>)).toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SurveyItem>>> getSurveys() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/feedback/surveys/');
      final body = _asMap(response.data);
      final results = (body['results'] ?? const <dynamic>[]) as List<dynamic>;
      final items = results.map((e) {
        final j = e as Map<String, dynamic>;
        return SurveyItem(
          id: j['id'] as int? ?? 0,
          title: (j['title'] as String?) ?? 'Опрос',
          status: (j['status'] as String?) ?? 'draft',
          description: j['description'] as String?,
        );
      }).toList();
      return Right(items);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitSurvey(int surveyId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.post('/feedback/surveys/$surveyId/submit/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Map<String, dynamic> _asMap(dynamic raw) => raw is Map<String, dynamic> ? raw : <String, dynamic>{};

  FeedbackSubmissionItem _feedbackFromJson(Map<String, dynamic> json) {
    return FeedbackSubmissionItem(
      id: json['id'] as int? ?? 0,
      subject: (json['subject'] as String?) ?? 'Без темы',
      message: (json['message'] as String?) ?? '',
      feedbackType: (json['feedback_type'] as String?) ?? 'general',
      status: (json['status'] as String?) ?? 'new',
      rating: json['rating'] as int?,
      contactEmail: json['contact_email'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  AuditLogItem _logFromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      id: json['id'] as int? ?? 0,
      user: (json['user'] as String?) ?? 'unknown',
      action: (json['action'] as String?) ?? 'other',
      targetType: json['target_type'] as String?,
      targetId: json['target_id'] as int?,
      targetName: (json['target_name'] as String?) ?? '-',
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

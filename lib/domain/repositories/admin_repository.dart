import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/admin_models.dart';

abstract class AdminRepository {
  Future<Either<Failure, PlatformAnalytics>> getPlatformAnalytics();
  Future<Either<Failure, List<FeedbackSubmissionItem>>> getFeedbackSubmissions();
  Future<Either<Failure, FeedbackSubmissionItem>> createFeedbackSubmission({
    required String subject,
    required String message,
    String feedbackType,
    int? rating,
    String? contactEmail,
    bool isAnonymous,
  });
  Future<Either<Failure, List<AuditLogItem>>> getLogs({String? action, String? search});
  Future<Either<Failure, List<SurveyItem>>> getSurveys();
  Future<Either<Failure, void>> submitSurvey(int surveyId);
}

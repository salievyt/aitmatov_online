import 'package:equatable/equatable.dart';

class PlatformAnalytics extends Equatable {
  final Map<String, dynamic> overview;
  final Map<String, dynamic> users;
  final Map<String, dynamic> engagement;

  const PlatformAnalytics({required this.overview, required this.users, required this.engagement});

  @override
  List<Object?> get props => [overview, users, engagement];
}

class FeedbackSubmissionItem extends Equatable {
  final int id;
  final String subject;
  final String message;
  final String feedbackType;
  final String status;
  final int? rating;
  final String? contactEmail;
  final DateTime? createdAt;

  const FeedbackSubmissionItem({
    required this.id,
    required this.subject,
    required this.message,
    required this.feedbackType,
    required this.status,
    this.rating,
    this.contactEmail,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, subject, message, feedbackType, status, rating, contactEmail, createdAt];
}

class AuditLogItem extends Equatable {
  final int id;
  final String user;
  final String action;
  final String? targetType;
  final int? targetId;
  final String targetName;
  final String? ipAddress;
  final DateTime? createdAt;

  const AuditLogItem({
    required this.id,
    required this.user,
    required this.action,
    this.targetType,
    this.targetId,
    required this.targetName,
    this.ipAddress,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, user, action, targetType, targetId, targetName, ipAddress, createdAt];
}

class SurveyItem extends Equatable {
  final int id;
  final String title;
  final String status;
  final String? description;

  const SurveyItem({required this.id, required this.title, required this.status, this.description});

  bool get isPublished => status == 'published';

  @override
  List<Object?> get props => [id, title, status, description];
}

import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final int id;
  final String title;
  final int order;
  final String contentType;
  final String? videoUrl;
  final String? audioUrl;
  final String? textBody;
  final bool quizEnabled;
  final bool isActive;

  const Lesson({
    required this.id,
    required this.title,
    required this.order,
    required this.contentType,
    this.videoUrl,
    this.audioUrl,
    this.textBody,
    required this.quizEnabled,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, title, order, contentType, videoUrl, audioUrl, textBody, quizEnabled, isActive];
}

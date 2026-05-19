import '../../domain/entities/lesson.dart';

class LessonDto {
  final int id;
  final String title;
  final int order;
  final String contentType;
  final String? videoUrl;
  final String? audioUrl;
  final String? textBody;
  final bool quizEnabled;
  final bool isActive;

  LessonDto({
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

  factory LessonDto.fromJson(Map<String, dynamic> json) {
    return LessonDto(
      id: json['id'] as int,
      title: json['title'] as String,
      order: json['order'] as int,
      contentType: json['content_type'] as String,
      videoUrl: json['video_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      textBody: json['text_body'] as String?,
      quizEnabled: json['quiz_enabled'] as bool,
      isActive: json['is_active'] as bool,
    );
  }

  Lesson toEntity() => Lesson(
        id: id,
        title: title,
        order: order,
        contentType: contentType,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        textBody: textBody,
        quizEnabled: quizEnabled,
        isActive: isActive,
      );
}

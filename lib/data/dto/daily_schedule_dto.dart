import '../../domain/entities/daily_schedule.dart';

class DailyScheduleDto {
  final int id;
  final int day;
  final String dayDisplay;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final int? subject;
  final int? teacher;
  final bool isActive;

  const DailyScheduleDto({
    required this.id,
    required this.day,
    required this.dayDisplay,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.teacher,
    required this.isActive,
  });

  factory DailyScheduleDto.fromJson(Map<String, dynamic> json) {
    return DailyScheduleDto(
      id: json['id'] as int,
      day: json['day'] as int,
      dayDisplay: (json['day_display'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      startTime: (json['start_time'] ?? '') as String,
      endTime: (json['end_time'] ?? '') as String,
      subject: json['subject'] as int?,
      teacher: json['teacher'] as int?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  DailySchedule toEntity() => DailySchedule(
        id: id,
        day: day,
        dayDisplay: dayDisplay,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        teacher: teacher,
        isActive: isActive,
      );
}

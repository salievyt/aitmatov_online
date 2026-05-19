import 'package:equatable/equatable.dart';

class DailySchedule extends Equatable {
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

  const DailySchedule({
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

  @override
  List<Object?> get props => [
        id,
        day,
        dayDisplay,
        title,
        description,
        startTime,
        endTime,
        subject,
        teacher,
        isActive,
      ];
}

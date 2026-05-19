part of 'teacher_bloc.dart';

abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}
class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final User user;
  final List<Course> courses;

  const TeacherLoaded({required this.user, required this.courses});

  @override
  List<Object?> get props => [user, courses];
}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError(this.message);

  @override
  List<Object?> get props => [message];
}

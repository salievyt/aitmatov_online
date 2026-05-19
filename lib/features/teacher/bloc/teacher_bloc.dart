import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/course_repository.dart';

part 'teacher_event.dart';
part 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final AuthRepository _authRepository;
  final CourseRepository _courseRepository;

  TeacherBloc(this._authRepository, this._courseRepository) : super(TeacherInitial()) {
    on<TeacherLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(TeacherLoadRequested event, Emitter<TeacherState> emit) async {
    emit(TeacherLoading());
    final me = await _authRepository.getCurrentUser(forceRefresh: true);
    await me.fold(
      (failure) async => emit(TeacherError(failure.message)),
      (user) async {
        if (user == null || !user.isTeacher) {
          emit(const TeacherError('Доступ только для преподавателя'));
          return;
        }
        final courses = await _courseRepository.getCourses();
        courses.fold(
          (failure) => emit(TeacherError(failure.message)),
          (data) => emit(TeacherLoaded(user: user, courses: data.where((c) => c.teacherId == user.id).toList())),
        );
      },
    );
  }
}

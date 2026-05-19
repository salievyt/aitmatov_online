import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_management_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AuthRepository _authRepository;
  final UserManagementRepository _userRepository;

  AdminBloc(this._authRepository, this._userRepository) : super(AdminInitial()) {
    on<AdminLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(AdminLoadRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    final me = await _authRepository.getCurrentUser(forceRefresh: true);
    await me.fold(
      (failure) async => emit(AdminError(failure.message)),
      (user) async {
        if (user == null || !user.isAdmin) {
          emit(const AdminError('Доступ только для администратора'));
          return;
        }
        final users = await _userRepository.getUsers(role: event.roleFilter);
        users.fold(
          (failure) => emit(AdminError(failure.message)),
          (data) => emit(AdminLoaded(user: user, users: data)),
        );
      },
    );
  }
}

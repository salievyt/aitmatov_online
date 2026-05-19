part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final User user;
  final List<User> users;

  const AdminLoaded({required this.user, required this.users});

  @override
  List<Object?> get props => [user, users];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

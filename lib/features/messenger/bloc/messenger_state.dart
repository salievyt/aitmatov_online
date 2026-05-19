part of 'messenger_bloc.dart';

abstract class MessengerState extends Equatable {
  const MessengerState();

  @override
  List<Object?> get props => [];
}

class MessengerInitial extends MessengerState {}

class MessengerLoading extends MessengerState {}

class MessengerLoaded extends MessengerState {
  final List<ChatGroup> groups;

  const MessengerLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class MessengerError extends MessengerState {
  final String message;

  const MessengerError(this.message);

  @override
  List<Object?> get props => [message];
}

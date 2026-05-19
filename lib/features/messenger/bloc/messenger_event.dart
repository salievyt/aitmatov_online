part of 'messenger_bloc.dart';

abstract class MessengerEvent extends Equatable {
  const MessengerEvent();

  @override
  List<Object?> get props => [];
}

class MessengerLoadRequested extends MessengerEvent {}

class MessengerCreateGroupRequested extends MessengerEvent {
  final String title;
  final List<ChatMember> members;

  const MessengerCreateGroupRequested({required this.title, required this.members});

  @override
  List<Object?> get props => [title, members];
}

class MessengerSendMessageRequested extends MessengerEvent {
  final String groupId;
  final ChatMessage message;

  const MessengerSendMessageRequested({required this.groupId, required this.message});

  @override
  List<Object?> get props => [groupId, message];
}

class MessengerSetLeaderRequested extends MessengerEvent {
  final String groupId;
  final int userId;

  const MessengerSetLeaderRequested({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

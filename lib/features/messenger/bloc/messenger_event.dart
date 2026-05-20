part of 'messenger_bloc.dart';

abstract class MessengerEvent extends Equatable {
  const MessengerEvent();

  @override
  List<Object?> get props => [];
}

// ─── Groups ───

class LoadGroupsRequested extends MessengerEvent {}

class CreateGroupRequested extends MessengerEvent {
  final String title;
  final List<ChatMember> members;

  const CreateGroupRequested({required this.title, required this.members});

  @override
  List<Object?> get props => [title, members];
}

class LoadGroupMessagesRequested extends MessengerEvent {
  final String groupId;

  const LoadGroupMessagesRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class SendGroupMessageRequested extends MessengerEvent {
  final String groupId;
  final ChatMessage message;

  const SendGroupMessageRequested({required this.groupId, required this.message});

  @override
  List<Object?> get props => [groupId, message];
}

class SetLeaderRequested extends MessengerEvent {
  final String groupId;
  final int userId;

  const SetLeaderRequested({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

// ─── Channels ───

class LoadChannelsRequested extends MessengerEvent {}

class CreateChannelRequested extends MessengerEvent {
  final String name;
  final String? description;

  const CreateChannelRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class LoadChannelMessagesRequested extends MessengerEvent {
  final String channelId;

  const LoadChannelMessagesRequested({required this.channelId});

  @override
  List<Object?> get props => [channelId];
}

class SendChannelMessageRequested extends MessengerEvent {
  final String channelId;
  final ChannelMessage message;

  const SendChannelMessageRequested({required this.channelId, required this.message});

  @override
  List<Object?> get props => [channelId, message];
}

class DeleteChannelRequested extends MessengerEvent {
  final String channelId;

  const DeleteChannelRequested({required this.channelId});

  @override
  List<Object?> get props => [channelId];
}

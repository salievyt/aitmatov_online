part of 'messenger_bloc.dart';

abstract class MessengerState extends Equatable {
  const MessengerState();

  @override
  List<Object?> get props => [];
}

class MessengerInitial extends MessengerState {}

class MessengerLoading extends MessengerState {}

class MessengerGroupsLoaded extends MessengerState {
  final List<ChatGroup> groups;

  const MessengerGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class MessengerChannelsLoaded extends MessengerState {
  final List<Channel> channels;

  const MessengerChannelsLoaded(this.channels);

  @override
  List<Object?> get props => [channels];
}

class MessengerGroupChatLoaded extends MessengerState {
  final ChatGroup group;
  final List<ChatMessage> messages;
  final int currentUserId;

  const MessengerGroupChatLoaded(this.group, this.messages, {required this.currentUserId});

  @override
  List<Object?> get props => [group, messages, currentUserId];
}

class MessengerChannelChatLoaded extends MessengerState {
  final Channel channel;
  final List<ChannelMessage> messages;
  final int currentUserId;

  const MessengerChannelChatLoaded(this.channel, this.messages, {required this.currentUserId});

  @override
  List<Object?> get props => [channel, messages, currentUserId];
}

class MessengerActionSuccess extends MessengerState {
  final String message;

  const MessengerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MessengerError extends MessengerState {
  final String message;

  const MessengerError(this.message);

  @override
  List<Object?> get props => [message];
}

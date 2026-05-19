import 'package:equatable/equatable.dart';

enum MessageType { text, sticker, voice, video, circle }

class ChatMember extends Equatable {
  final int userId;
  final String name;
  final bool isLeader;

  const ChatMember({required this.userId, required this.name, this.isLeader = false});

  ChatMember copyWith({bool? isLeader}) => ChatMember(userId: userId, name: name, isLeader: isLeader ?? this.isLeader);

  @override
  List<Object?> get props => [userId, name, isLeader];
}

class ChatMessage extends Equatable {
  final String id;
  final int senderId;
  final String senderName;
  final MessageType type;
  final String payload;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, type, payload, createdAt];
}

class ChatGroup extends Equatable {
  final String id;
  final String title;
  final List<ChatMember> members;
  final List<ChatMessage> messages;

  const ChatGroup({required this.id, required this.title, this.members = const [], this.messages = const []});

  ChatGroup copyWith({List<ChatMember>? members, List<ChatMessage>? messages}) {
    return ChatGroup(id: id, title: title, members: members ?? this.members, messages: messages ?? this.messages);
  }

  @override
  List<Object?> get props => [id, title, members, messages];
}

import 'package:equatable/equatable.dart';

import '../user.dart';

enum MessageType { text, sticker, voice, video }

class ChatMember extends Equatable {
  final int userId;
  final String name;
  final String? avatarUrl;
  final bool isLeader;

  const ChatMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.isLeader = false,
  });

  ChatMember copyWith({bool? isLeader}) => ChatMember(
        userId: userId,
        name: name,
        avatarUrl: avatarUrl,
        isLeader: isLeader ?? this.isLeader,
      );

  @override
  List<Object?> get props => [userId, name, avatarUrl, isLeader];
}

class ChatMessage extends Equatable {
  final String id;
  final int senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final MessageType type;
  final String text;
  final String? stickerCode;
  final String? attachmentUrl;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.type,
    this.text = '',
    this.stickerCode,
    this.attachmentUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderAvatarUrl,
        type,
        text,
        stickerCode,
        attachmentUrl,
        createdAt,
      ];
}

class ChatGroup extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isPrivate;
  final User? createdBy;
  final User? admin;
  final int? leaderId;
  final int membersCount;
  final List<ChatMember> members;
  final List<ChatMessage> messages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatGroup({
    required this.id,
    required this.title,
    this.description,
    this.isPrivate = false,
    this.createdBy,
    this.admin,
    this.leaderId,
    this.membersCount = 0,
    this.members = const [],
    this.messages = const [],
    this.createdAt,
    this.updatedAt,
  });

  ChatGroup copyWith({
    String? title,
    String? description,
    bool? isPrivate,
    User? createdBy,
    User? admin,
    int? leaderId,
    int? membersCount,
    List<ChatMember>? members,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatGroup(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isPrivate: isPrivate ?? this.isPrivate,
      createdBy: createdBy ?? this.createdBy,
      admin: admin ?? this.admin,
      leaderId: leaderId ?? this.leaderId,
      membersCount: membersCount ?? this.membersCount,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isPrivate,
        createdBy,
        admin,
        leaderId,
        membersCount,
        members,
        messages,
        createdAt,
        updatedAt,
      ];
}

class Channel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final User? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Channel({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  Channel copyWith({
    String? name,
    String? description,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Channel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdBy, createdAt, updatedAt];
}

class ChannelMessage extends Equatable {
  final String id;
  final String channelId;
  final User? author;
  final int authorId;
  final MessageType type;
  final String text;
  final String? stickerCode;
  final String? attachmentUrl;
  final DateTime createdAt;

  const ChannelMessage({
    required this.id,
    required this.channelId,
    this.author,
    required this.authorId,
    required this.type,
    this.text = '',
    this.stickerCode,
    this.attachmentUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        channelId,
        author,
        authorId,
        type,
        text,
        stickerCode,
        attachmentUrl,
        createdAt,
      ];
}

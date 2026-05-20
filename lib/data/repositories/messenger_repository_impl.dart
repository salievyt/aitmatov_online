import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/messenger/chat_models.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/messenger_repository.dart';

class MessengerRepositoryImpl implements MessengerRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  MessengerRepositoryImpl(this._dio, this._networkInfo);

  // ─── Groups ───

  @override
  Future<Either<Failure, List<ChatGroup>>> getGroups() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/groups/');
      final data = response.data;
      final List<dynamic> results;
      if (data is Map<String, dynamic>) {
        results = (data['results'] ?? <dynamic>[]) as List<dynamic>;
      } else if (data is List<dynamic>) {
        results = data;
      } else {
        results = [];
      }
      final groups = results.map((e) => _parseChatGroup(e as Map<String, dynamic>)).toList();
      return Right(groups);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> getGroupDetail(String groupId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/groups/$groupId/');
      return Right(_parseChatGroupDetail(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> createGroup(String title, List<ChatMember> members) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.post('/messenger/groups/', data: {
        'name': title,
        'member_ids': members.map((e) => e.userId).toList(),
      });
      return Right(_parseChatGroup(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getGroupMessages(String groupId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/groups/$groupId/messages/');
      final data = response.data;
      final List<dynamic> results;
      if (data is Map<String, dynamic>) {
        results = (data['results'] ?? <dynamic>[]) as List<dynamic>;
      } else if (data is List<dynamic>) {
        results = data;
      } else {
        results = [];
      }
      final messages = results.map((e) => _parseChatMessage(e as Map<String, dynamic>)).toList();
      return Right(messages);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendGroupMessage(String groupId, ChatMessage message) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.post('/messenger/groups/$groupId/messages/', data: {
        'message_type': _toApiMessageType(message.type),
        'text': message.type == MessageType.text ? message.text : null,
        'sticker_code': message.type == MessageType.sticker ? message.stickerCode : null,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setLeader(String groupId, int userId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.patch('/messenger/groups/$groupId/assign-leader/', data: {'user_id': userId});
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ─── Channels ───

  @override
  Future<Either<Failure, List<Channel>>> getChannels() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/channels/');
      final data = response.data;
      final List<dynamic> results;
      if (data is Map<String, dynamic>) {
        results = (data['results'] ?? <dynamic>[]) as List<dynamic>;
      } else if (data is List<dynamic>) {
        results = data;
      } else {
        results = [];
      }
      final channels = results.map((e) => _parseChannel(e as Map<String, dynamic>)).toList();
      return Right(channels);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Channel>> getChannelDetail(String channelId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/channels/$channelId/');
      return Right(_parseChannel(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Channel>> createChannel(String name, String? description) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.post('/messenger/channels/', data: {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      });
      return Right(_parseChannel(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateChannel(String channelId, String name, String? description) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.put('/messenger/channels/$channelId/', data: {
        'name': name,
        if (description != null) 'description': description,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteChannel(String channelId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.delete('/messenger/channels/$channelId/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChannelMessage>>> getChannelMessages(String channelId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/channels/$channelId/messages/');
      final data = response.data;
      final List<dynamic> results;
      if (data is Map<String, dynamic>) {
        results = (data['results'] ?? <dynamic>[]) as List<dynamic>;
      } else if (data is List<dynamic>) {
        results = data;
      } else {
        results = [];
      }
      final messages = results.map((e) => _parseChannelMessage(e as Map<String, dynamic>)).toList();
      return Right(messages);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendChannelMessage(String channelId, ChannelMessage message) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.post('/messenger/channels/$channelId/messages/', data: {
        'message_type': _toApiMessageType(message.type),
        'text': message.type == MessageType.text ? message.text : null,
        'sticker_code': message.type == MessageType.sticker ? message.stickerCode : null,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // ─── Parsers ───

  ChatGroup _parseChatGroup(Map<String, dynamic> item) {
    return ChatGroup(
      id: (item['id'] as int).toString(),
      title: item['name'] as String? ?? '',
      description: item['description'] as String?,
      isPrivate: item['is_private'] as bool? ?? false,
      createdBy: _parseUserOrNull(item['created_by']),
      admin: _parseUserOrNull(item['admin']),
      leaderId: item['leader_id'] as int?,
      membersCount: item['members_count'] as int? ?? 0,
      createdAt: _parseDateTime(item['created_at']),
      updatedAt: _parseDateTime(item['updated_at']),
    );
  }

  ChatGroup _parseChatGroupDetail(Map<String, dynamic> item) {
    final membersJson = (item['members'] as List<dynamic>? ?? []);
    final members = membersJson.map((m) {
      final membership = m as Map<String, dynamic>;
      final user = membership['user'] as Map<String, dynamic>?;
      return ChatMember(
        userId: user?['id'] as int? ?? 0,
        name: _userDisplayName(user),
        avatarUrl: user?['avatar_url'] as String?,
        isLeader: membership['is_leader'] as bool? ?? false,
      );
    }).toList();

    return _parseChatGroup(item).copyWith(members: members);
  }

  ChatMessage _parseChatMessage(Map<String, dynamic> m) {
    final author = m['author'] as Map<String, dynamic>?;
    final type = _fromApiMessageType((m['message_type'] ?? 'text') as String);
    final text = (m['text'] as String?) ?? '';
    final stickerCode = m['sticker_code'] as String?;
    final attachmentUrl = (m['attachment_url'] as String?) ?? (m['attachment'] as String?);

    return ChatMessage(
      id: (m['id'] as int).toString(),
      senderId: (m['author_id'] ?? 0) as int,
      senderName: _userDisplayName(author),
      senderAvatarUrl: author?['avatar_url'] as String?,
      type: type,
      text: text,
      stickerCode: stickerCode,
      attachmentUrl: attachmentUrl,
      createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
    );
  }

  Channel _parseChannel(Map<String, dynamic> item) {
    return Channel(
      id: (item['id'] as int).toString(),
      name: item['name'] as String? ?? '',
      description: item['description'] as String?,
      createdBy: _parseUserOrNull(item['created_by']),
      createdAt: _parseDateTime(item['created_at']),
      updatedAt: _parseDateTime(item['updated_at']),
    );
  }

  ChannelMessage _parseChannelMessage(Map<String, dynamic> m) {
    final author = m['author'] as Map<String, dynamic>?;
    final type = _fromApiMessageType((m['message_type'] ?? 'text') as String);

    return ChannelMessage(
      id: (m['id'] as int).toString(),
      channelId: (m['channel'] as int).toString(),
      author: _parseUserOrNull(author),
      authorId: (m['author_id'] ?? 0) as int,
      type: type,
      text: (m['text'] as String?) ?? '',
      stickerCode: m['sticker_code'] as String?,
      attachmentUrl: (m['attachment_url'] as String?) ?? (m['attachment'] as String?),
      createdAt: _parseDateTime(m['created_at']) ?? DateTime.now(),
    );
  }

  User? _parseUserOrNull(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;
    return User(
      id: data['id'] as int? ?? 0,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      username: data['username'] as String?,
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      avatarUrl: (data['avatar_url'] ?? data['avatar']) as String?,
      role: ((data['role'] ?? 'student') as String).trim().toLowerCase(),
      classLevel: data['class_level'] as int?,
      school: data['school'] as String?,
    );
  }

  String _userDisplayName(Map<String, dynamic>? user) {
    if (user == null) return 'Неизвестно';
    final nick = user['username'] as String?;
    final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    return (nick != null && nick.isNotEmpty) ? '@$nick' : (fullName.isEmpty ? 'Пользователь' : fullName);
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _toApiMessageType(MessageType type) {
    switch (type) {
      case MessageType.sticker:
        return 'sticker';
      case MessageType.voice:
        return 'voice';
      case MessageType.video:
        return 'video';
      case MessageType.text:
        return 'text';
    }
  }

  MessageType _fromApiMessageType(String type) {
    switch (type) {
      case 'sticker':
        return MessageType.sticker;
      case 'voice':
        return MessageType.voice;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }
}

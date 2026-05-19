import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/messenger/chat_models.dart';
import '../../domain/repositories/messenger_repository.dart';

class MessengerRepositoryImpl implements MessengerRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  MessengerRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<ChatGroup>>> getGroups() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/messenger/groups/');
      final body = response.data as Map<String, dynamic>;
      final results = (body['results'] ?? <dynamic>[]) as List<dynamic>;
      final groups = results.map((e) {
        final item = e as Map<String, dynamic>;
        return ChatGroup(
          id: (item['id'] as int).toString(),
          title: item['name'] as String,
        );
      }).toList();
      return Right(groups);
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
      final item = response.data as Map<String, dynamic>;
      return Right(ChatGroup(id: (item['id'] as int).toString(), title: item['name'] as String));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> addMessage(String groupId, ChatMessage message) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.post('/messenger/groups/$groupId/messages/', data: {
        'message_type': _toApiMessageType(message.type),
        'text': message.type == MessageType.text ? message.payload : null,
        'sticker_code': message.type == MessageType.sticker ? message.payload : null,
      });
      return _getGroupDetail(groupId);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ChatGroup>> setLeader(String groupId, int userId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await _dio.patch('/messenger/groups/$groupId/assign-leader/', data: {'user_id': userId});
      return _getGroupDetail(groupId);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Future<Either<Failure, ChatGroup>> _getGroupDetail(String groupId) async {
    final response = await _dio.get('/messenger/groups/$groupId/');
    final item = response.data as Map<String, dynamic>;
    final membersJson = (item['members'] as List<dynamic>? ?? []);
    final members = membersJson.map((m) {
      final membership = m as Map<String, dynamic>;
      final user = membership['user'] as Map<String, dynamic>;
      final nick = user['username'] as String?;
      final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
      return ChatMember(
        userId: user['id'] as int,
        name: (nick != null && nick.isNotEmpty) ? '@$nick' : fullName,
        isLeader: membership['is_leader'] as bool? ?? false,
      );
    }).toList();

    final messagesResp = await _dio.get('/messenger/groups/$groupId/messages/');
    final msgBody = messagesResp.data as Map<String, dynamic>;
    final msgResults = (msgBody['results'] ?? <dynamic>[]) as List<dynamic>;
    final messages = msgResults.map((x) {
      final m = x as Map<String, dynamic>;
      final author = m['author'] as Map<String, dynamic>?;
      final nick = author?['username'] as String?;
      final fullName = '${author?['first_name'] ?? ''} ${author?['last_name'] ?? ''}'.trim();
      final type = _fromApiMessageType((m['message_type'] ?? 'text') as String);
      final payload = (m['text'] as String?) ?? (m['sticker_code'] as String?) ?? (m['attachment_url'] as String?) ?? '';
      return ChatMessage(
        id: (m['id'] as int).toString(),
        senderId: (m['author_id'] ?? 0) as int,
        senderName: (nick != null && nick.isNotEmpty) ? '@$nick' : fullName,
        type: type,
        payload: payload,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
      );
    }).toList();

    return Right(ChatGroup(id: (item['id'] as int).toString(), title: item['name'] as String, members: members, messages: messages));
  }

  String _toApiMessageType(MessageType type) {
    switch (type) {
      case MessageType.sticker:
        return 'sticker';
      case MessageType.voice:
        return 'voice';
      case MessageType.video:
      case MessageType.circle:
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

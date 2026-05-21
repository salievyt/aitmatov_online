import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/local/local_storage.dart';
import '../../domain/entities/messenger/chat_models.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/messenger_repository.dart';

class MessengerRepositoryImpl implements MessengerRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  final LocalStorage _localStorage;

  final Map<String, WebSocket> _groupSockets = {};
  final Map<String, StreamController<ChatMessage>> _groupControllers = {};
  final Map<String, WebSocket> _channelSockets = {};
  final Map<String, StreamController<ChannelMessage>> _channelControllers = {};

  MessengerRepositoryImpl(this._dio, this._networkInfo, this._localStorage);

  @override
  Future<Either<Failure, List<ChatGroup>>> getGroups() async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/groups/'); final data = response.data; final List<dynamic> results = data is Map<String, dynamic> ? ((data['results'] ?? <dynamic>[]) as List<dynamic>) : (data is List<dynamic> ? data : []); return Right(results.map((e) => _parseChatGroup(e as Map<String, dynamic>)).toList()); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, ChatGroup>> getGroupDetail(String groupId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/groups/$groupId/'); return Right(_parseChatGroupDetail(response.data as Map<String, dynamic>)); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, ChatGroup>> createGroup(String title, List<ChatMember> members) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.post('/messenger/groups/', data: {'name': title, 'member_ids': members.map((e) => e.userId).toList()}); return Right(_parseChatGroup(response.data as Map<String, dynamic>)); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, List<ChatMessage>>> getGroupMessages(String groupId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/groups/$groupId/messages/'); final data = response.data; final List<dynamic> results = data is Map<String, dynamic> ? ((data['results'] ?? <dynamic>[]) as List<dynamic>) : (data is List<dynamic> ? data : []); return Right(results.map((e) => _parseChatMessage(e as Map<String, dynamic>)).toList()); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, void>> sendGroupMessage(String groupId, ChatMessage message) async {
    final socket = _groupSockets[groupId];
    if (socket != null) {
      socket.add(jsonEncode(_buildMessagePayload(type: message.type, text: message.text, stickerCode: message.stickerCode)));
      return const Right(null);
    }
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try { await _dio.post('/messenger/groups/$groupId/messages/', data: _buildMessagePayload(type: message.type, text: message.text, stickerCode: message.stickerCode)); return const Right(null);} on DioException catch (e) { return Left(NetworkFailure(_extractDioMessage(e))); } catch (_) { return const Left(ServerFailure()); }
  }

  @override
  Future<Either<Failure, void>> setLeader(String groupId, int userId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { await _dio.patch('/messenger/groups/$groupId/assign-leader/', data: {'user_id': userId}); return const Right(null);} on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, List<ChatMember>>> getGroupMembers(String groupId) async {
    final detail = await getGroupDetail(groupId);
    return detail.fold((l) => Left(l), (r) => Right(r.members));
  }

  @override
  Stream<ChatMessage> connectGroupStream(String groupId) {
    if (_groupControllers[groupId] != null) return _groupControllers[groupId]!.stream;
    final controller = StreamController<ChatMessage>.broadcast();
    _groupControllers[groupId] = controller;
    _connectGroupSocket(groupId, controller);
    return controller.stream;
  }

  Future<void> _connectGroupSocket(String groupId, StreamController<ChatMessage> controller) async {
    try {
      final uri = _wsUriWithAuth('/ws/messenger/groups/$groupId/');
      final socket = await WebSocket.connect(uri.toString());
      _groupSockets[groupId] = socket;
      socket.listen((event) {
        final payload = _decodeEvent(event);
        if (payload != null) controller.add(_parseChatMessage(payload));
      }, onDone: () {
        _groupSockets.remove(groupId);
        _reconnectGroupSocket(groupId, controller);
      }, onError: (_) {
        _groupSockets.remove(groupId);
        _reconnectGroupSocket(groupId, controller);
      });
    } catch (_) {}
  }

  void _reconnectGroupSocket(String groupId, StreamController<ChatMessage> controller) {
    Future.delayed(const Duration(seconds: 3), () {
      if (_groupControllers[groupId] == controller) {
        _connectGroupSocket(groupId, controller);
      }
    });
  }

  @override
  Future<void> disconnectGroupStream(String groupId) async {
    await _groupSockets[groupId]?.close();
    _groupSockets.remove(groupId);
    await _groupControllers[groupId]?.close();
    _groupControllers.remove(groupId);
  }

  @override
  Future<Either<Failure, List<Channel>>> getChannels() async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/channels/'); final data = response.data; final List<dynamic> results = data is Map<String, dynamic> ? ((data['results'] ?? <dynamic>[]) as List<dynamic>) : (data is List<dynamic> ? data : []); return Right(results.map((e) => _parseChannel(e as Map<String, dynamic>)).toList()); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, Channel>> getChannelDetail(String channelId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/channels/$channelId/'); return Right(_parseChannel(response.data as Map<String, dynamic>)); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, Channel>> createChannel(String name, String? description) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.post('/messenger/channels/', data: {'name': name, if (description != null && description.isNotEmpty) 'description': description}); return Right(_parseChannel(response.data as Map<String, dynamic>)); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, void>> updateChannel(String channelId, String name, String? description) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { await _dio.put('/messenger/channels/$channelId/', data: {'name': name, if (description != null) 'description': description}); return const Right(null);} on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, void>> deleteChannel(String channelId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { await _dio.delete('/messenger/channels/$channelId/'); return const Right(null);} on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, List<ChannelMessage>>> getChannelMessages(String channelId) async { if (!await _networkInfo.isConnected) return const Left(NetworkFailure()); try { final response = await _dio.get('/messenger/channels/$channelId/messages/'); final data = response.data; final List<dynamic> results = data is Map<String, dynamic> ? ((data['results'] ?? <dynamic>[]) as List<dynamic>) : (data is List<dynamic> ? data : []); return Right(results.map((e) => _parseChannelMessage(e as Map<String, dynamic>)).toList()); } on DioException catch (e) { return Left(NetworkFailure(e.message ?? 'Ошибка сети')); } catch (_) { return const Left(ServerFailure()); } }

  @override
  Future<Either<Failure, void>> sendChannelMessage(String channelId, ChannelMessage message) async {
    final socket = _channelSockets[channelId];
    if (socket != null) {
      socket.add(jsonEncode(_buildMessagePayload(type: message.type, text: message.text, stickerCode: message.stickerCode)));
      return const Right(null);
    }
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try { await _dio.post('/messenger/channels/$channelId/messages/', data: _buildMessagePayload(type: message.type, text: message.text, stickerCode: message.stickerCode)); return const Right(null);} on DioException catch (e) { return Left(NetworkFailure(_extractDioMessage(e))); } catch (_) { return const Left(ServerFailure()); }
  }

  @override
  Future<Either<Failure, List<ChatMember>>> getChannelMembers(String channelId) async {
    final response = await _dio.get('/messenger/channels/$channelId/');
    final creator = _parseUserOrNull((response.data as Map<String, dynamic>)['created_by']);
    if (creator == null) return const Right([]);
    return Right([ChatMember(userId: creator.id, name: creator.fullName, avatarUrl: creator.avatarUrl)]);
  }

  @override
  Stream<ChannelMessage> connectChannelStream(String channelId) {
    if (_channelControllers[channelId] != null) return _channelControllers[channelId]!.stream;
    final controller = StreamController<ChannelMessage>.broadcast();
    _channelControllers[channelId] = controller;
    _connectChannelSocket(channelId, controller);
    return controller.stream;
  }

  Future<void> _connectChannelSocket(String channelId, StreamController<ChannelMessage> controller) async {
    try {
      final uri = _wsUriWithAuth('/ws/messenger/channels/$channelId/');
      final socket = await WebSocket.connect(uri.toString());
      _channelSockets[channelId] = socket;
      socket.listen((event) {
        final payload = _decodeEvent(event);
        if (payload != null) controller.add(_parseChannelMessage(payload));
      }, onDone: () {
        _channelSockets.remove(channelId);
        _reconnectChannelSocket(channelId, controller);
      }, onError: (_) {
        _channelSockets.remove(channelId);
        _reconnectChannelSocket(channelId, controller);
      });
    } catch (_) {}
  }

  void _reconnectChannelSocket(String channelId, StreamController<ChannelMessage> controller) {
    Future.delayed(const Duration(seconds: 3), () {
      if (_channelControllers[channelId] == controller) {
        _connectChannelSocket(channelId, controller);
      }
    });
  }

  @override
  Future<void> disconnectChannelStream(String channelId) async {
    await _channelSockets[channelId]?.close();
    _channelSockets.remove(channelId);
    await _channelControllers[channelId]?.close();
    _channelControllers.remove(channelId);
  }

  Uri _wsUri(String path) {
    final base = Uri.parse(_dio.options.baseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return Uri(scheme: scheme, host: base.host, port: base.hasPort ? base.port : null, path: '${base.path}$path'.replaceAll('//', '/'));
  }

  Uri _wsUriWithAuth(String path) {
    final base = Uri.parse(_dio.options.baseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final token = _localStorage.getToken();
    final query = token != null && token.isNotEmpty ? '?token=$token' : '';
    return Uri(
      scheme: scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '${base.path}$path'.replaceAll('//', '/'),
      query: query,
    );
  }

  Map<String, dynamic>? _decodeEvent(dynamic event) {
    try {
      final raw = event is String ? jsonDecode(event) : event;
      if (raw is Map<String, dynamic>) {
        final msg = raw['message'];
        if (msg is Map<String, dynamic>) return msg;
        return raw;
      }
    } catch (_) {}
    return null;
  }

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
    return ChatMessage(
      id: (m['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      senderId: (m['author_id'] ?? 0) as int,
      senderName: _userDisplayName(author),
      senderAvatarUrl: author?['avatar_url'] as String?,
      type: _fromApiMessageType((m['message_type'] ?? 'text') as String),
      text: (m['text'] as String?) ?? '',
      stickerCode: m['sticker_code'] as String?,
      attachmentUrl: (m['attachment_url'] as String?) ?? (m['attachment'] as String?),
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
    return ChannelMessage(
      id: (m['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      channelId: (m['channel'] ?? '').toString(),
      author: _parseUserOrNull(author),
      authorId: (m['author_id'] ?? 0) as int,
      type: _fromApiMessageType((m['message_type'] ?? 'text') as String),
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
    if (user == null) return 'Пользователь';
    final nick = user['username'] as String?;
    final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    return (nick != null && nick.isNotEmpty) ? '@$nick' : (fullName.isEmpty ? 'Пользователь' : fullName);
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _toApiMessageType(MessageType type) =>
      type == MessageType.sticker ? 'sticker' :
      type == MessageType.voice ? 'voice' :
      type == MessageType.video ? 'video' : 'text';

  MessageType _fromApiMessageType(String type) =>
      type == 'sticker' ? MessageType.sticker :
      type == 'voice' ? MessageType.voice :
      type == 'video' ? MessageType.video : MessageType.text;

  Map<String, dynamic> _buildMessagePayload({
    required MessageType type,
    String? text,
    String? stickerCode,
  }) {
    final payload = <String, dynamic>{'message_type': _toApiMessageType(type)};
    if (type == MessageType.text) {
      final t = (text ?? '').trim();
      if (t.isNotEmpty) payload['text'] = t;
    }
    if (type == MessageType.sticker) {
      final s = (stickerCode ?? '').trim();
      if (s.isNotEmpty) payload['sticker_code'] = s;
    }
    return payload;
  }

  String _extractDioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
    }
    return e.message ?? 'Ошибка сети';
  }
}

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/messenger/chat_models.dart';

abstract class MessengerRepository {
  // Groups
  Future<Either<Failure, List<ChatGroup>>> getGroups();
  Future<Either<Failure, ChatGroup>> getGroupDetail(String groupId);
  Future<Either<Failure, ChatGroup>> createGroup(String title, List<ChatMember> members);
  Future<Either<Failure, List<ChatMessage>>> getGroupMessages(String groupId);
  Future<Either<Failure, void>> sendGroupMessage(String groupId, ChatMessage message);
  Future<Either<Failure, void>> setLeader(String groupId, int userId);

  // Channels
  Future<Either<Failure, List<Channel>>> getChannels();
  Future<Either<Failure, Channel>> getChannelDetail(String channelId);
  Future<Either<Failure, Channel>> createChannel(String name, String? description);
  Future<Either<Failure, void>> updateChannel(String channelId, String name, String? description);
  Future<Either<Failure, void>> deleteChannel(String channelId);
  Future<Either<Failure, List<ChannelMessage>>> getChannelMessages(String channelId);
  Future<Either<Failure, void>> sendChannelMessage(String channelId, ChannelMessage message);
}

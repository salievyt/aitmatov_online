import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/messenger/chat_models.dart';

abstract class MessengerRepository {
  Future<Either<Failure, List<ChatGroup>>> getGroups();
  Future<Either<Failure, ChatGroup>> createGroup(String title, List<ChatMember> members);
  Future<Either<Failure, ChatGroup>> addMessage(String groupId, ChatMessage message);
  Future<Either<Failure, ChatGroup>> setLeader(String groupId, int userId);
}

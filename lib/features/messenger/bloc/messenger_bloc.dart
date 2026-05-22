import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/local/secure_local_storage.dart';
import '../../../domain/entities/messenger/chat_models.dart';
import '../../../domain/repositories/messenger_repository.dart';

part 'messenger_event.dart';
part 'messenger_state.dart';

class MessengerBloc extends Bloc<MessengerEvent, MessengerState> {
  final MessengerRepository _repository;
  final SecureLocalStorage _localStorage;

  MessengerBloc(this._repository, this._localStorage) : super(MessengerInitial()) {
    on<LoadGroupsRequested>(_onLoadGroups);
    on<CreateGroupRequested>(_onCreateGroup);
    on<LoadGroupMessagesRequested>(_onLoadGroupMessages);
    on<SendGroupMessageRequested>(_onSendGroupMessage);
    on<SetLeaderRequested>(_onSetLeader);

    on<LoadChannelsRequested>(_onLoadChannels);
    on<CreateChannelRequested>(_onCreateChannel);
    on<LoadChannelMessagesRequested>(_onLoadChannelMessages);
    on<SendChannelMessageRequested>(_onSendChannelMessage);
    on<DeleteChannelRequested>(_onDeleteChannel);
  }

  int? get _cachedUserId {
    final user = _localStorage.getCachedUser();
    return user?['id'] as int?;
  }

  // ─── Groups ───

  Future<void> _onLoadGroups(LoadGroupsRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final result = await _repository.getGroups();
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (groups) => emit(MessengerGroupsLoaded(groups)),
    );
  }

  Future<void> _onCreateGroup(CreateGroupRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final result = await _repository.createGroup(event.title, event.members);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadGroupsRequested()),
    );
  }

  Future<void> _onLoadGroupMessages(LoadGroupMessagesRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final groupResult = await _repository.getGroupDetail(event.groupId);
    if (groupResult.isLeft()) {
      emit(MessengerError(groupResult.fold((l) => l.message, (_) => '')));
      return;
    }
    final group = groupResult.getOrElse(() => throw Exception());

    final messagesResult = await _repository.getGroupMessages(event.groupId);
    messagesResult.fold(
      (failure) => emit(MessengerError(failure.message)),
      (messages) => emit(MessengerGroupChatLoaded(group, messages, currentUserId: _cachedUserId ?? 0)),
    );
  }

  Future<void> _onSendGroupMessage(SendGroupMessageRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.sendGroupMessage(event.groupId, event.message);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadGroupMessagesRequested(groupId: event.groupId)),
    );
  }

  Future<void> _onSetLeader(SetLeaderRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.setLeader(event.groupId, event.userId);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadGroupMessagesRequested(groupId: event.groupId)),
    );
  }

  // ─── Channels ───

  Future<void> _onLoadChannels(LoadChannelsRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final result = await _repository.getChannels();
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (channels) => emit(MessengerChannelsLoaded(channels)),
    );
  }

  Future<void> _onCreateChannel(CreateChannelRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final result = await _repository.createChannel(event.name, event.description);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadChannelsRequested()),
    );
  }

  Future<void> _onLoadChannelMessages(LoadChannelMessagesRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final channelResult = await _repository.getChannelDetail(event.channelId);
    if (channelResult.isLeft()) {
      emit(MessengerError(channelResult.fold((l) => l.message, (_) => '')));
      return;
    }
    final channel = channelResult.getOrElse(() => throw Exception());

    final messagesResult = await _repository.getChannelMessages(event.channelId);
    messagesResult.fold(
      (failure) => emit(MessengerError(failure.message)),
      (messages) => emit(MessengerChannelChatLoaded(channel, messages, currentUserId: _cachedUserId ?? 0)),
    );
  }

  Future<void> _onSendChannelMessage(SendChannelMessageRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.sendChannelMessage(event.channelId, event.message);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadChannelMessagesRequested(channelId: event.channelId)),
    );
  }

  Future<void> _onDeleteChannel(DeleteChannelRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.deleteChannel(event.channelId);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) => add(LoadChannelsRequested()),
    );
  }
}

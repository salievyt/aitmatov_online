import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/messenger/chat_models.dart';
import '../../../domain/repositories/messenger_repository.dart';

part 'messenger_event.dart';
part 'messenger_state.dart';

class MessengerBloc extends Bloc<MessengerEvent, MessengerState> {
  final MessengerRepository _repository;

  MessengerBloc(this._repository) : super(MessengerInitial()) {
    on<MessengerLoadRequested>(_onLoad);
    on<MessengerCreateGroupRequested>(_onCreateGroup);
    on<MessengerSendMessageRequested>(_onSendMessage);
    on<MessengerSetLeaderRequested>(_onSetLeader);
  }

  Future<void> _onLoad(MessengerLoadRequested event, Emitter<MessengerState> emit) async {
    emit(MessengerLoading());
    final result = await _repository.getGroups();
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (groups) => emit(MessengerLoaded(groups)),
    );
  }

  Future<void> _onCreateGroup(MessengerCreateGroupRequested event, Emitter<MessengerState> emit) async {
    final current = state;
    if (current is! MessengerLoaded) return;
    final result = await _repository.createGroup(event.title, event.members);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) async => add(MessengerLoadRequested()),
    );
  }

  Future<void> _onSendMessage(MessengerSendMessageRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.addMessage(event.groupId, event.message);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) async => add(MessengerLoadRequested()),
    );
  }

  Future<void> _onSetLeader(MessengerSetLeaderRequested event, Emitter<MessengerState> emit) async {
    final result = await _repository.setLeader(event.groupId, event.userId);
    result.fold(
      (failure) => emit(MessengerError(failure.message)),
      (_) async => add(MessengerLoadRequested()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/messenger/chat_models.dart';
import '../../../domain/repositories/messenger_repository.dart';
import '../bloc/messenger_bloc.dart';

class MessengerChatScreen extends StatefulWidget {
  final String groupId;
  const MessengerChatScreen({super.key, required this.groupId});

  @override
  State<MessengerChatScreen> createState() => _MessengerChatScreenState();
}

class _MessengerChatScreenState extends State<MessengerChatScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _send(BuildContext context, MessageType type, String payload) async {
    final message = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: 1,
      senderName: 'Вы',
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );
    context.read<MessengerBloc>().add(MessengerSendMessageRequested(groupId: widget.groupId, message: message));
    _textController.clear();
  }

  Future<void> _setLeader(BuildContext context, ChatGroup group) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Назначить старосту'),
        children: group.members
            .map((m) => SimpleDialogOption(onPressed: () => Navigator.pop(context, m.userId), child: Text(m.name)))
            .toList(),
      ),
    );
    if (selected == null) return;
    if (!context.mounted) return;
    context.read<MessengerBloc>().add(MessengerSetLeaderRequested(groupId: group.id, userId: selected));
  }

  String _render(ChatMessage message) {
    switch (message.type) {
      case MessageType.sticker:
        return 'Стикер: ${message.payload}';
      case MessageType.voice:
        return 'Голосовое: ${message.payload}';
      case MessageType.video:
        return 'Видео: ${message.payload}';
      case MessageType.circle:
        return 'Кружок: ${message.payload}';
      case MessageType.text:
        return message.payload;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessengerBloc(context.read<MessengerRepository>())..add(MessengerLoadRequested()),
      child: BlocBuilder<MessengerBloc, MessengerState>(
        builder: (context, state) {
          if (state is MessengerLoading || state is MessengerInitial) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state is MessengerError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          final groups = (state as MessengerLoaded).groups;
          final group = groups.where((e) => e.id == widget.groupId).firstOrNull;
          if (group == null) return const Scaffold(body: Center(child: Text('Группа не найдена')));
          final leader = group.members.where((m) => m.isLeader).firstOrNull;

          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.title),
                  if (leader != null) Text('Староста: ${leader.name}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              actions: [IconButton(onPressed: () => _setLeader(context, group), icon: const Icon(Icons.star_outline))],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: group.messages.length,
                    itemBuilder: (context, index) {
                      final m = group.messages[index];
                      return Align(
                        alignment: m.senderId == 1 ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                          child: GestureDetector(
                            onTap: m.senderId > 0 ? () => context.push('/users/${m.senderId}/profile') : null,
                            child: Text('${m.senderName}: ${_render(m)}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _textController, decoration: const InputDecoration(hintText: 'Сообщение...'))),
                          IconButton(onPressed: () => _send(context, MessageType.text, _textController.text.trim()), icon: const Icon(Icons.send)),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          OutlinedButton(onPressed: () => _send(context, MessageType.sticker, '😀'), child: const Text('Стикер')),
                          OutlinedButton(onPressed: () => _send(context, MessageType.voice, 'voice_001.ogg'), child: const Text('Голос')),
                          OutlinedButton(onPressed: () => _send(context, MessageType.video, 'video_001.mp4'), child: const Text('Видео')),
                          OutlinedButton(onPressed: () => _send(context, MessageType.circle, 'circle_001.mp4'), child: const Text('Кружок')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

extension _IterableExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

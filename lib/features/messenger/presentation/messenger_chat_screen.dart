import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../data/local/secure_local_storage.dart';
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
  final ScrollController _scrollController = ScrollController();
  late final MessengerBloc _bloc;
  List<ChatMessage> _liveMessages = const [];
  StreamSubscription<ChatMessage>? _wsSub;

  @override
  void initState() {
    super.initState();
    _bloc = MessengerBloc(
      GetIt.I<MessengerRepository>(),
      GetIt.I<SecureLocalStorage>(),
    )..add(LoadGroupMessagesRequested(groupId: widget.groupId));
    _wsSub = GetIt.I<MessengerRepository>().connectGroupStream(widget.groupId).listen((event) {
      if (!mounted) return;
      setState(() => _liveMessages = [..._liveMessages, event]);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _bloc.close();
    _wsSub?.cancel();
    GetIt.I<MessengerRepository>().disconnectGroupStream(widget.groupId);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 0,
      senderName: 'Вы',
      type: MessageType.text,
      text: text,
      createdAt: DateTime.now(),
    );

    _bloc.add(SendGroupMessageRequested(groupId: widget.groupId, message: message));
    _textController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<MessengerBloc, MessengerState>(
        listenWhen: (previous, current) =>
            current is MessengerGroupChatLoaded || current is MessengerError,
        listener: (context, state) {
          if (state is MessengerGroupChatLoaded) {
            _scrollToBottom();
          }
        },
        buildWhen: (previous, current) =>
            current is MessengerGroupChatLoaded ||
            current is MessengerLoading ||
            current is MessengerError,
        builder: (context, state) {
          if (state is MessengerLoading || state is MessengerInitial) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is MessengerError) {
            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _buildAppBar(theme, null),
              body: _ErrorBody(
                message: state.message,
                onRetry: () => _bloc.add(
                  LoadGroupMessagesRequested(groupId: widget.groupId),
                ),
              ),
            );
          }

          if (state is MessengerGroupChatLoaded) {
            final group = state.group;
            final messages = [...state.messages, ..._liveMessages];
            final currentUserId = state.currentUserId;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: _buildAppBar(theme, group),
              body: Column(
                children: [
                  Expanded(
                    child: _MessagesList(
                      messages: messages,
                      currentUserId: currentUserId,
                      scrollController: _scrollController,
                    ),
                  ),
                  _MessageInput(
                    controller: _textController,
                    onSend: _sendText,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ChatGroup? group) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      title: group == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      group.title.length > 1
                          ? group.title.substring(0, 2).toUpperCase()
                          : group.title[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${group.membersCount} участников',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        if (group != null)
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onPressed: () => _showGroupOptions(context, group),
          ),
      ],
    );
  }

  void _showGroupOptions(BuildContext context, ChatGroup group) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.star_outline, color: theme.colorScheme.primary),
                title: const Text('Назначить старосту'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSetLeaderDialog(context, group);
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline, color: theme.colorScheme.primary),
                title: const Text('Участники'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/messenger/group/${group.id}/members');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSetLeaderDialog(BuildContext context, ChatGroup group) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Назначить старосту'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: group.members.length,
            itemBuilder: (_, index) {
              final member = group.members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: member.isLeader
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: member.isLeader ? Colors.amber : Colors.grey,
                  ),
                ),
                title: Text(member.name),
                trailing: member.isLeader
                    ? const Icon(Icons.star, color: Colors.amber, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _bloc.add(
                    SetLeaderRequested(
                      groupId: group.id,
                      userId: member.userId,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }
}

// ─── Messages List ───

class _MessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final int currentUserId;
  final ScrollController scrollController;

  const _MessagesList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Нет сообщений',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Начните общение первым',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final showAvatar = !isMe;
        final isFirstInSequence = index == 0 ||
            messages[index - 1].senderId != message.senderId;

        return _MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar && isFirstInSequence,
          showName: !isMe && isFirstInSequence,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showName;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.showName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && showAvatar) ...[
              _buildAvatar(theme),
              const SizedBox(width: 8),
            ] else if (!isMe) ...[
              const SizedBox(width: 44),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (showName)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Text(
                        message.senderName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe
                          ? null
                          : theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                    ),
                    child: _buildMessageContent(theme),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _formatTime(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    switch (message.type) {
      case MessageType.sticker:
        return Text(
          message.stickerCode ?? '🙂',
          style: const TextStyle(fontSize: 32),
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 18,
              color: isMe ? Colors.white70 : theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              'Голосовое',
              style: TextStyle(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        );
      case MessageType.video:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam,
              size: 18,
              color: isMe ? Colors.white70 : theme.colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              'Видео',
              style: TextStyle(
                color: isMe ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        );
      case MessageType.text:
        return Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : theme.colorScheme.onSurface,
            fontSize: 15,
            height: 1.3,
          ),
        );
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Message Input ───

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Сообщение...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.outline.withOpacity(0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Body ───

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Что-то пошло не так',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

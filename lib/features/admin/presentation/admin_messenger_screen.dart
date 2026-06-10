import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../data/local/secure_local_storage.dart';
import '../../../domain/repositories/messenger_repository.dart';
import '../../messenger/bloc/messenger_bloc.dart';

class AdminMessengerScreen extends StatefulWidget {
  const AdminMessengerScreen({super.key});

  @override
  State<AdminMessengerScreen> createState() => _AdminMessengerScreenState();
}

class _AdminMessengerScreenState extends State<AdminMessengerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the same MessengerBloc to load lists; repository should return all items for admin
    return BlocProvider(
      create: (context) => MessengerBloc(
        context.read<MessengerRepository>(),
        getIt<SecureLocalStorage>(),
      )
        ..add(LoadGroupsRequested())
        ..add(LoadChannelsRequested()),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Админ: Сообщения'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Группы'), Tab(text: 'Каналы')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _AdminGroupsTab(),
              _AdminChannelsTab(),
            ],
          ),
        );
      }),
    );
  }
}

class _AdminGroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessengerBloc, MessengerState>(
      buildWhen: (previous, current) =>
          current is MessengerGroupsLoaded ||
          current is MessengerLoading ||
          current is MessengerError,
      builder: (context, state) {
        if (state is MessengerLoading || state is MessengerInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MessengerError) {
          return Center(child: Text(state.message));
        }
        if (state is MessengerGroupsLoaded) {
          final groups = state.groups;
          if (groups.isEmpty) {
            return const Center(child: Text('Нет групп'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final g = groups[index];
              return ListTile(
                leading: CircleAvatar(
                    child: Text(
                        g.title.isNotEmpty ? g.title[0].toUpperCase() : '?')),
                title: Text(g.title),
                subtitle: Text('${g.membersCount} участников'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'view') {
                      context.push('/messenger/group/${g.id}');
                    } else if (v == 'members') {
                      context.push('/messenger/group/${g.id}/members');
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('Открыть чат')),
                    const PopupMenuItem(
                        value: 'members', child: Text('Участники')),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AdminChannelsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessengerBloc, MessengerState>(
      buildWhen: (previous, current) =>
          current is MessengerChannelsLoaded ||
          current is MessengerLoading ||
          current is MessengerError,
      builder: (context, state) {
        if (state is MessengerLoading || state is MessengerInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MessengerError) {
          return Center(child: Text(state.message));
        }
        if (state is MessengerChannelsLoaded) {
          final channels = state.channels;
          if (channels.isEmpty) {
            return const Center(child: Text('Нет каналов'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: channels.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final c = channels[index];
              return ListTile(
                leading: CircleAvatar(child: const Icon(Icons.campaign)),
                title: Text(c.name),
                subtitle: c.description != null ? Text(c.description!) : null,
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'open') {
                      context.push('/messenger/channel/${c.id}');
                    } else if (v == 'members') {
                      context.push('/messenger/channel/${c.id}/members');
                    } else if (v == 'delete') {
                      // ask confirmation then dispatch delete
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (d) => AlertDialog(
                          title: const Text('Удалить канал?'),
                          content: const Text('Это действие нельзя отменить.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(d, false),
                                child: const Text('Отмена')),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(d, true),
                                child: const Text('Удалить')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        context
                            .read<MessengerBloc>()
                            .add(DeleteChannelRequested(channelId: c.id));
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'open', child: Text('Открыть')),
                    const PopupMenuItem(
                        value: 'members', child: Text('Участники')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Удалить'),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

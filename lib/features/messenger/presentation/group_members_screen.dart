import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/messenger/chat_models.dart';
import '../../../domain/repositories/messenger_repository.dart';

class GroupMembersScreen extends StatefulWidget {
  final String groupId;
  const GroupMembersScreen({super.key, required this.groupId});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  bool _loading = true;
  List<ChatMember> _members = const [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final result = await context.read<MessengerRepository>().getGroupMembers(widget.groupId);
    result.fold((_) {}, (data) => _members = data);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Участники группы')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _members.length,
        itemBuilder: (_, i) {
          final m = _members[i];
          return ListTile(title: Text(m.name), trailing: m.isLeader ? const Icon(Icons.star, color: Colors.amber) : null);
        },
      ),
    );
  }
}

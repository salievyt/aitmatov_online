import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/messenger/chat_models.dart';
import '../../../domain/repositories/messenger_repository.dart';

class ChannelMembersScreen extends StatefulWidget {
  final String channelId;
  const ChannelMembersScreen({super.key, required this.channelId});

  @override
  State<ChannelMembersScreen> createState() => _ChannelMembersScreenState();
}

class _ChannelMembersScreenState extends State<ChannelMembersScreen> {
  bool _loading = true;
  List<ChatMember> _members = const [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final result = await context.read<MessengerRepository>().getChannelMembers(widget.channelId);
    result.fold((_) {}, (data) => _members = data);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Участники канала')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _members.length,
        itemBuilder: (_, i) => ListTile(title: Text(_members[i].name)),
      ),
    );
  }
}

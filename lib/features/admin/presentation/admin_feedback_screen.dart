import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/admin_models.dart';
import '../../../domain/repositories/admin_repository.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  bool _loading = true;
  List<FeedbackSubmissionItem> _items = const [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await context.read<AdminRepository>().getFeedbackSubmissions();
    result.fold((_) {}, (data) => _items = data);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _createFeedback() async {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая обратная связь'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Тема')),
          TextField(controller: messageController, decoration: const InputDecoration(labelText: 'Сообщение')),
        ]),
        actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Отмена')), FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Отправить'))],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AdminRepository>().createFeedbackSubmission(subject: subjectController.text.trim(), message: messageController.text.trim());
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      floatingActionButton: FloatingActionButton(onPressed: _createFeedback, child: const Icon(Icons.add_comment_outlined)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final item = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(item.subject),
                    subtitle: Text('${item.feedbackType} • ${item.status}\n${item.message}', maxLines: 3, overflow: TextOverflow.ellipsis),
                    trailing: item.rating != null ? Chip(label: Text('★${item.rating}')) : null,
                  ),
                );
              },
            ),
    );
  }
}

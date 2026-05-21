import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/admin_repository.dart';

class FeedbackRequestScreen extends StatefulWidget {
  const FeedbackRequestScreen({super.key});

  @override
  State<FeedbackRequestScreen> createState() => _FeedbackRequestScreenState();
}

class _FeedbackRequestScreenState extends State<FeedbackRequestScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    final result = await context.read<AdminRepository>().createFeedbackSubmission(
      subject: _subject.text.trim(),
      message: _message.text.trim(),
      feedbackType: 'support',
    );
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Обращение отправлено'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обращения')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Тема')),
            const SizedBox(height: 12),
            TextField(controller: _message, maxLines: 5, decoration: const InputDecoration(labelText: 'Сообщение')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _sending ? null : _send, child: Text(_sending ? 'Отправка...' : 'Отправить')),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TeacherMessagesScreen extends StatelessWidget {
  const TeacherMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Голосовые сообщения')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.mic), title: Text('Записать сообщение'), subtitle: Text('Подключи endpoint загрузки/отправки voice message.'))),
          Card(child: ListTile(leading: Icon(Icons.history), title: Text('История отправок'), subtitle: Text('Подключи endpoint истории сообщений.'))),
        ],
      ),
    );
  }
}

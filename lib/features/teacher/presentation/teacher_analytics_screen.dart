import 'package:flutter/material.dart';

class TeacherAnalyticsScreen extends StatelessWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика класса')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.bar_chart), title: Text('Завершение уроков'), subtitle: Text('Подключи teacher analytics endpoint.'))),
          Card(child: ListTile(leading: Icon(Icons.timeline), title: Text('Динамика успеваемости'), subtitle: Text('Подключи teacher analytics endpoint.'))),
        ],
      ),
    );
  }
}

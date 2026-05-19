import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/daily_schedule.dart';
import '../../../domain/repositories/schedule_repository.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  int _selectedDay = 1;
  bool _isLoading = true;
  List<DailySchedule> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await context.read<ScheduleRepository>().getSchedules(day: _selectedDay);
    result.fold((_) {}, (data) => _items = [...data]..sort((a, b) => a.startTime.compareTo(b.startTime)));
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _upsert({DailySchedule? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final startCtrl = TextEditingController(text: existing?.startTime ?? '08:00:00');
    final endCtrl = TextEditingController(text: existing?.endTime ?? '08:45:00');
    int day = existing?.day ?? _selectedDay;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Добавить занятие' : 'Редактировать занятие'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: day,
                  items: List.generate(7, (i) => i + 1)
                      .map((d) => DropdownMenuItem(value: d, child: Text(_dayTitle(d))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => day = v ?? 1),
                ),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Название')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Описание')),
                TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Начало (HH:MM:SS)')),
                TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Конец (HH:MM:SS)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            FilledButton(
              onPressed: () async {
                final payload = {
                  'day': day,
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'start_time': startCtrl.text.trim(),
                  'end_time': endCtrl.text.trim(),
                  'is_active': true,
                };
                final repo = context.read<ScheduleRepository>();
                final result = existing == null
                    ? await repo.createSchedule(payload)
                    : await repo.updateSchedule(existing.id, payload);
                if (!mounted) return;
                result.fold(
                  (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
                  (_) {
                    Navigator.pop(context);
                    _load();
                  },
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(DailySchedule item) async {
    final result = await context.read<ScheduleRepository>().deleteSchedule(item.id);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (_) => _load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование расписания')),
      floatingActionButton: FloatingActionButton(onPressed: () => _upsert(), child: const Icon(Icons.add)),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (_, i) {
                final day = i + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_dayShort(day)),
                    selected: day == _selectedDay,
                    onSelected: (_) {
                      setState(() => _selectedDay = day);
                      _load();
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text('${_hhmm(item.startTime)} - ${_hhmm(item.endTime)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _upsert(existing: item)),
                              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(item)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _dayShort(int day) => ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][day - 1];
  String _dayTitle(int day) => ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'][day - 1];
  String _hhmm(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0]}:${parts[1]}';
  }
}

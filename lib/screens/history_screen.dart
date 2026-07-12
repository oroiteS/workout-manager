import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final recordDatesAsync = ref.watch(recordDatesProvider);
    final recordsAsync = ref.watch(recordsForDateProvider(_selectedDay));

    final isPastOrToday = !_selectedDay.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练记录'),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (_, ref, __) => IconButton(
              icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, size: 20),
              onPressed: () => ref.read(themeModeProvider.notifier).update(
                (s) => s == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              ),
              tooltip: '切换主题',
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('v1.1.2', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
        ],
      ),
      floatingActionButton: isPastOrToday
          ? FloatingActionButton.extended(
              onPressed: () => _retroAddRecords(),
              icon: const Icon(Icons.add),
              label: const Text('补录训练'),
            )
          : null,
      body: Column(
        children: [
          recordDatesAsync.when(
            loading: () => const SizedBox(height: 340, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => const SizedBox(height: 340, child: Center(child: Text('加载失败'))),
            data: (recordDates) {
              final eventDays = recordDates
                  .map((d) => DateTime(d.year, d.month, d.day))
                  .toSet();

              return TableCalendar(
                firstDay: DateTime(2026, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {CalendarFormat.month: '月'},
                eventLoader: (day) {
                  return eventDays.contains(DateTime(day.year, day.month, day.day)) ? [true] : [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(180),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                locale: 'zh_CN',
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: recordsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Text(
                      '${DateFormat('M月d日').format(_selectedDay)} 无训练记录',
                      style: TextStyle(fontSize: 15, color: Colors.grey[500]),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    return _RecordTile(
                      record: r,
                      onTap: () => _editRecord(r),
                      onDelete: () => _deleteRecord(r.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(int id) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定要删除这条训练记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              ref.read(deleteRecordProvider(id));
              Navigator.pop(dialogCtx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _retroAddRecords() async {
    final templateExercises = await ref.read(templateByDayProvider(_selectedDay.weekday).future);
    if (templateExercises.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${DateFormat('M月d日 EEEE', 'zh_CN').format(_selectedDay)} 的模板没有动作，请先去「周模板」添加')),
        );
      }
      return;
    }

    if (!mounted) return;

    final controllers = <int, TextEditingController>{};
    for (final t in templateExercises) {
      controllers[t.exerciseId] = TextEditingController();
    }

    final result = await showDialog<Map<int, ({String name, double weight})>>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('补录：${DateFormat('M月d日 EEEE', 'zh_CN').format(_selectedDay)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: templateExercises.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: controllers[t.exerciseId],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: t.exerciseName,
                    hintText: '重量 (kg)，留空则跳过',
                    border: const OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final records = <int, ({String name, double weight})>{};
              for (final t in templateExercises) {
                final v = double.tryParse(controllers[t.exerciseId]!.text.trim());
                if (v != null && v > 0) {
                  records[t.exerciseId] = (name: t.exerciseName, weight: v);
                }
              }
              Navigator.pop(dialogCtx, records);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    for (final c in controllers.values) {
      c.dispose();
    }

    if (result != null && result.isNotEmpty) {
      try {
        await ref.read(saveRecordsForDateProvider((date: _selectedDay, records: result)).future);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已补录 ${result.length} 个动作到 ${DateFormat('M月d日').format(_selectedDay)}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('补录失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _editRecord(TrainingRecordData record) async {
    final controller = TextEditingController(text: record.weight.toString());
    final newWeight = await showDialog<double>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('编辑：${record.exerciseName}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '输入新重量 (kg)',
            border: OutlineInputBorder(),
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null && v > 0) Navigator.pop(dialogCtx, v);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newWeight != null) {
      try {
        final db = ref.read(databaseProvider);
        await db.recordDao.updateWeight(record.id, newWeight);
        ref.invalidate(recordsForDateProvider);
        ref.invalidate(recordsGroupedByDateProvider);
        ref.invalidate(recordDatesProvider);
        ref.invalidate(exerciseHistoryProvider);
        ref.invalidate(lastWeightsProvider(record.exerciseId));
        ref.invalidate(lastTrainedDateProvider(record.exerciseId));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _RecordTile extends StatelessWidget {
  final TrainingRecordData record;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _RecordTile({required this.record, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('rec-${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
        title: Text(record.exerciseName),
        subtitle: Text(
          DateFormat('yyyy-MM-dd').format(record.trainedAt),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${record.weight} kg',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
        onTap: onTap,
        onLongPress: onDelete,
        dense: true,
      ),
    );
  }
}

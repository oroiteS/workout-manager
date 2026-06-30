// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsGroupedByDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练记录'),
        centerTitle: true,
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('暂无训练记录', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                ],
              ),
            );
          }

          final items = _buildItems(records);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is _DateHeaderItem) {
                return _DateHeader(date: item.date);
              }
              return _RecordRow(
                record: (item as _RecordRowItem).record,
                onDelete: () => _deleteRecord(context, ref, (item).record.id),
              );
            },
          );
        },
      ),
    );
  }

  List<_HistoryItem> _buildItems(List<TrainingRecordData> records) {
    final items = <_HistoryItem>[];
    String? lastDateKey;

    for (final r in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(r.trainedAt);
      if (dateKey != lastDateKey) {
        items.add(_DateHeaderItem(date: r.trainedAt));
        lastDateKey = dateKey;
      }
      items.add(_RecordRowItem(record: r));
    }

    return items;
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定要删除这条训练记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              ref.read(deleteRecordProvider(id));
              Navigator.pop(ctx);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// --- item types ---
sealed class _HistoryItem {}
class _DateHeaderItem extends _HistoryItem {
  final DateTime date;
  _DateHeaderItem({required this.date});
}
class _RecordRowItem extends _HistoryItem {
  final TrainingRecordData record;
  _RecordRowItem({required this.record});
}

// --- widgets ---

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final dayStr = DateFormat('M月d日 EEEE', 'zh_CN').format(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        dayStr,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final TrainingRecordData record;
  final VoidCallback onDelete;
  const _RecordRow({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('record-${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // we handle deletion with dialog
      },
      child: ListTile(
        title: Text(record.exerciseName),
        trailing: Text(
          '${record.weight} kg',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        dense: true,
      ),
    );
  }
}

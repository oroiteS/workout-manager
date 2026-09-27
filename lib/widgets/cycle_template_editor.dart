import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/day_template_card.dart';
import 'package:workout_manager/widgets/exercise_add_flow.dart';
import 'package:workout_manager/widgets/pick_target.dart';

/// 循环模式的模板编辑区：循环天数选择 + 每天的动作卡片。
class CycleTemplateEditor extends ConsumerWidget {
  const CycleTemplateEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayCountAsync = ref.watch(cycleDayCountProvider);
    final templateAsync = ref.watch(cycleTemplateProvider);

    // 有旧值时直接渲染，invalidate 重载期间不闪转圈（与周模板行为一致）。
    final dayCount = dayCountAsync.valueOrNull;
    final allExercises = templateAsync.valueOrNull;
    if (dayCount == null || allExercises == null) {
      if (dayCountAsync.hasError || templateAsync.hasError) {
        return const Center(child: Text('加载失败'));
      }
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text('循环天数', style: TextStyle(fontSize: 14)),
              const Spacer(),
              DropdownButton<int>(
                value: dayCount,
                items: [
                  for (var i = 1; i <= CycleDao.maxDayCount; i++)
                    DropdownMenuItem(value: i, child: Text('$i 天')),
                ],
                onChanged: (value) => _changeDayCount(context, ref, dayCount, value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        for (var day = 1; day <= dayCount; day++)
          DayTemplateCard(
            dayLabel: '第$day天',
            dayOfWeek: day,
            showToday: false,
            exercises: allExercises
                .where((t) => t.dayOfWeek == day)
                .map((t) => (exerciseId: t.exerciseId, exerciseName: t.exerciseName))
                .toList(),
            onAdd: () => showAddExerciseFlow(
              context,
              ref,
              pickTarget: CyclePickTarget(day),
              dayLabel: '第$day天',
            ),
            onDelete: (exerciseId, exerciseName) async {
              try {
                final db = ref.read(databaseProvider);
                await db.cycleDao.deleteExercise(day, exerciseId);
                ref.invalidate(cycleTemplateProvider);
                ref.invalidate(cycleByDayProvider(day));
                ref.invalidate(cycleTodayStateProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
      ],
    );
  }

  Future<void> _changeDayCount(
    BuildContext context,
    WidgetRef ref,
    int current,
    int? value,
  ) async {
    if (value == null || value == current) return;

    if (value < current) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('缩短循环'),
          content: Text(
            '缩短后将删除第 ${value + 1} 至第 $current 天的循环动作'
            '（训练记录不受影响）。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('缩短'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    final db = ref.read(databaseProvider);
    try {
      await db.cycleDao.setDayCount(value);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('修改循环天数失败: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    ref.invalidate(cycleDayCountProvider);
    ref.invalidate(cycleTemplateProvider);
    ref.invalidate(cycleByDayProvider);
    ref.invalidate(cycleTodayStateProvider);
  }
}

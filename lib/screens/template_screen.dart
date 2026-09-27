import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/plan/plan_import.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/cycle_template_editor.dart';
import 'package:workout_manager/widgets/day_template_card.dart';
import 'package:workout_manager/widgets/exercise_add_flow.dart';
import 'package:workout_manager/widgets/pick_target.dart';

const _dayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

class TemplateScreen extends ConsumerWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(templateProvider);
    final modeAsync = ref.watch(planModeProvider);
    final isCycle = modeAsync.valueOrNull == PlanMode.cycle;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCycle ? '循环模板' : '周训练模板'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 20),
            tooltip: '从 CSV 导入计划',
            onPressed: () => _importCsv(context, ref),
          ),
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
            child: Center(child: Text('v1.3.0', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
        ],
      ),
      body: modeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (mode) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: SegmentedButton<PlanMode>(
                segments: const [
                  ButtonSegment(
                    value: PlanMode.weekly,
                    label: Text('计划模式'),
                    icon: Icon(Icons.calendar_month_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: PlanMode.cycle,
                    label: Text('循环模式'),
                    icon: Icon(Icons.repeat, size: 18),
                  ),
                ],
                selected: {mode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    _switchMode(context, ref, selection.first),
              ),
            ),
            Expanded(
              child: mode == PlanMode.cycle
                  ? const CycleTemplateEditor()
                  : _buildWeeklyList(context, ref, templateAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<TemplateWithExercise>> templateAsync,
  ) {
    return templateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (allTemplates) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 7,
          itemBuilder: (context, index) {
            final day = index + 1;
            final dayExercises = allTemplates
                .where((t) => t.dayOfWeek == day)
                .map((t) => (exerciseId: t.exerciseId, exerciseName: t.exerciseName))
                .toList();

            return DayTemplateCard(
              dayLabel: _dayLabels[index],
              dayOfWeek: day,
              exercises: dayExercises,
              onAdd: () => showAddExerciseFlow(
                context,
                ref,
                pickTarget: WeekPickTarget(day),
                dayLabel: _dayLabels[index],
              ),
              onDelete: (exerciseId, exerciseName) async {
                try {
                  final db = ref.read(databaseProvider);
                  await db.templateDao.deleteExercise(day, exerciseId);
                  ref.invalidate(templateProvider);
                  ref.invalidate(templateByDayProvider(day));
                  ref.invalidate(todayExercisesProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    WidgetRef ref,
    PlanMode mode,
  ) async {
    final db = ref.read(databaseProvider);
    try {
      await db.cycleDao.setPlanMode(mode);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换模式失败: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    ref.invalidate(planModeProvider);
    ref.invalidate(cycleTodayStateProvider);
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择计划 CSV',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;

    final path = result.files.single.path;
    if (path == null) {
      _showSnack(context, '无法读取文件路径');
      return;
    }

    final isCycle = ref.read(planModeProvider).valueOrNull == PlanMode.cycle;

    final ParsedPlan plan;
    try {
      final raw = await File(path).readAsString();
      plan = isCycle
          ? parsePlanCsv(
              raw,
              dayCount: await ref.read(cycleDayCountProvider.future),
              cycle: true,
            )
          : parsePlanCsv(raw);
    } on PlanCsvException catch (e) {
      if (!context.mounted) return;
      _showSnack(context, '解析失败: ${e.message}');
      return;
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, '读取文件失败: $e');
      return;
    }
    if (!context.mounted) return;

    final db = ref.read(databaseProvider);
    final current = isCycle
        ? await db.cycleDao.getAll()
        : await db.templateDao.getAll();
    if (!context.mounted) return;

    final diff = buildPlanDiff(
      [
        for (final t in current)
          (dayOfWeek: t.dayOfWeek, exerciseName: t.exerciseName),
      ],
      plan,
    );
    if (!diff.hasChanges) {
      _showSnack(context, 'CSV 内容与当前计划相同');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildDiffDialog(ctx, diff, cycle: isCycle),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      if (isCycle) {
        await db.cycleDao.replaceAll(plan.exercisesByDay);
      } else {
        await db.templateDao.replaceAll(plan.exercisesByDay);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, '导入失败: $e');
      return;
    }
    if (!context.mounted) return;

    if (isCycle) {
      ref.invalidate(cycleTemplateProvider);
      ref.invalidate(cycleByDayProvider);
      ref.invalidate(cycleTodayStateProvider);
      ref.invalidate(allExercisesProvider);
    } else {
      ref.invalidate(templateProvider);
      ref.invalidate(templateByDayProvider);
      ref.invalidate(todayExercisesProvider);
      ref.invalidate(allExercisesProvider);
    }
    _showSnack(context, '已导入 ${plan.exerciseCount} 个动作');
  }

  String _dayLabel(int day, {required bool cycle}) =>
      cycle ? '第$day天' : _dayLabels[day - 1];

  Widget _buildDiffDialog(BuildContext context, PlanDiff diff,
      {required bool cycle}) {
    String label(int day) => _dayLabel(day, cycle: cycle);
    return AlertDialog(
      title: Text(cycle ? '导入循环计划' : '导入周计划'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CSV 共 ${diff.exerciseCount} 个动作，'
                '新增 ${diff.totalAdded}、移除 ${diff.totalRemoved}，'
                '将替换整个${cycle ? '循环计划' : '周计划'}。',
              ),
              const SizedBox(height: 6),
              Text(
                cycle
                    ? '只改循环模板，不会删除任何训练记录与每日选择。'
                    : '只改周计划，不会删除任何训练记录。',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (diff.clearedDays.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '以下 ${diff.clearedDays.length} 天将被清空：'
                  '${diff.clearedDays.map(label).join('、')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              for (final d in diff.days) ...[
                Text(
                  label(d.day),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (d.kept.isNotEmpty)
                  Text(
                    '  保留 ${d.kept.length} 个',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                for (final n in d.added)
                  Text(
                    '  + $n',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                for (final n in d.removed)
                  Text(
                    '  - $n',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('替换导入'),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

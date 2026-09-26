import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/plan/plan_import.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/catalog_browser.dart';
import 'package:workout_manager/widgets/catalog_browser_mode.dart';
import 'package:workout_manager/widgets/day_template_card.dart';

const _dayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

class TemplateScreen extends ConsumerWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(templateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('周训练模板'),
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
      body: templateAsync.when(
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
                onAdd: () => _onAdd(context, ref, day, _dayLabels[index]),
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
      ),
    );
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

    final ParsedPlan plan;
    try {
      plan = parsePlanCsv(await File(path).readAsString());
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
    final current = await db.templateDao.getAll();
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
      builder: (ctx) => _buildDiffDialog(ctx, diff),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await db.templateDao.replaceAll(plan.exercisesByDay);
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, '导入失败: $e');
      return;
    }
    if (!context.mounted) return;

    ref.invalidate(templateProvider);
    ref.invalidate(templateByDayProvider);
    ref.invalidate(todayExercisesProvider);
    ref.invalidate(allExercisesProvider);
    _showSnack(context, '已导入 ${plan.exerciseCount} 个动作');
  }

  Widget _buildDiffDialog(BuildContext context, PlanDiff diff) {
    return AlertDialog(
      title: const Text('导入周计划'),
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
                '将替换整个周计划。',
              ),
              const SizedBox(height: 6),
              Text(
                '只改周计划，不会删除任何训练记录。',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (diff.clearedDays.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '以下 ${diff.clearedDays.length} 天将被清空：'
                  '${diff.clearedDays.map((d) => _dayLabels[d - 1]).join('、')}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              for (final d in diff.days) ...[
                Text(
                  _dayLabels[d.day - 1],
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

  Future<void> _onAdd(
    BuildContext context,
    WidgetRef ref,
    int day,
    String dayLabel,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('从动作库选择'),
              onTap: () => Navigator.pop(ctx, 'catalog'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('自定义名称'),
              onTap: () => Navigator.pop(ctx, 'custom'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || choice == null) return;

    if (choice == 'catalog') {
      final previousQuery = ref.read(catalogQueryProvider);
      ref.read(catalogQueryProvider.notifier).state = CatalogQuery.empty();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('从动作库选择'),
            ),
            body: CatalogBrowser(
              mode: CatalogBrowserMode.pick,
              dayOfWeek: day,
            ),
          ),
        ),
      );
      ref.read(catalogQueryProvider.notifier).state = previousQuery;
      return;
    }

    if (choice == 'custom') {
      await _addCustom(context, ref, day, dayLabel);
    }
  }

  Future<void> _addCustom(
    BuildContext context,
    WidgetRef ref,
    int day,
    String dayLabel,
  ) async {
    String prefill = '';
    while (true) {
      if (!context.mounted) return;
      final controller = TextEditingController(text: prefill);
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('为$dayLabel添加动作'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '动作名称',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) Navigator.pop(ctx, text);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (name == null || name.isEmpty || !context.mounted) return;

      try {
        final db = ref.read(databaseProvider);
        final hit = await db.catalogDao.findByNameZh(name);
        if (hit != null) {
          if (!context.mounted) return;
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('合并动作'),
              content: Text('库中已有「$name」，合并并显示示意图？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('合并'),
                ),
              ],
            ),
          );
          if (ok != true) {
            prefill = name;
            continue;
          }
          await db.templateDao.addExercise(day, hit.nameZh, datasetId: hit.datasetId);
        } else {
          await db.templateDao.addExercise(day, name, datasetId: null);
        }
        ref.invalidate(templateProvider);
        ref.invalidate(templateByDayProvider(day));
        ref.invalidate(todayExercisesProvider);
        return;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }
  }
}

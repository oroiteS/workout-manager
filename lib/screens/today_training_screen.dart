// lib/screens/today_training_screen.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workout_manager/backup/backup_models.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/exercise_input_card.dart';

class TodayTrainingScreen extends ConsumerStatefulWidget {
  const TodayTrainingScreen({super.key});

  @override
  ConsumerState<TodayTrainingScreen> createState() => _TodayTrainingScreenState();
}

class _TodayTrainingScreenState extends ConsumerState<TodayTrainingScreen> {
  final Map<int, double?> _weights = {};
  bool _initialized = false;
  late final AppDatabase _db;

  @override
  void initState() {
    super.initState();
    // 提前持有数据库：即使弹层关闭时组件恰好销毁，选择也能先写库再判断挂载。
    _db = ref.read(databaseProvider);
  }

  Future<void> _exportBackup() async {
    try {
      final service = ref.read(backupServiceProvider);
      final jsonString = await service.exportToJson();
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final suggestedName = 'workout-backup-$dateStr.json';

      try {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '导出备份',
          fileName: suggestedName,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result == null) {
          return;
        }

        await File(result).writeAsString(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已导出: $result')),
          );
        }
        return;
      } catch (_) {
        // saveFile 不可用或写盘失败时，回退到系统分享
      }

      final dir = await getTemporaryDirectory();
      final tempPath = '${dir.path}/$suggestedName';
      final tempFile = File(tempPath);
      await tempFile.writeAsString(jsonString);
      await Share.shareXFiles(
        [XFile(tempPath, mimeType: 'application/json')],
        subject: suggestedName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已通过分享导出备份')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择备份文件',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final file = result.files.single;
    final path = file.path;
    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法读取文件路径')),
        );
      }
      return;
    }
    final content = await File(path).readAsString();
    if (!mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入备份'),
        content: const Text(
          '将覆盖当前全部训练数据（动作、周模板、训练记录）。此操作不可撤销。',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('导入')),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      final service = ref.read(backupServiceProvider);
      await service.importFromJsonString(content);
      if (!mounted) {
        return;
      }
      ref.invalidate(todayExercisesProvider);
      ref.invalidate(templateProvider);
      ref.invalidate(templateByDayProvider);
      ref.invalidate(allExercisesProvider);
      ref.invalidate(exerciseHistoryProvider);
      ref.invalidate(recordsGroupedByDateProvider);
      ref.invalidate(recordDatesProvider);
      ref.invalidate(recordsForDateProvider);
      ref.invalidate(saveRecordsProvider);
      ref.invalidate(saveRecordsForDateProvider);
      ref.invalidate(lastWeightsProvider);
      ref.invalidate(lastTrainedDateProvider);
      ref.invalidate(deleteRecordProvider);
      invalidateCycleProviders(ref);
      setState(() {
        _weights.clear();
        _initialized = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导入成功')),
      );
    } on BackupParseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeAsync = ref.watch(planModeProvider);
    final cycleStateAsync = ref.watch(cycleTodayStateProvider);
    final todayRecordsAsync = ref.watch(recordsGroupedByDateProvider);

    if (!_initialized && todayRecordsAsync.hasValue) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      for (final r in todayRecordsAsync.value!) {
        if (!r.trainedAt.isBefore(todayStart)) {
          _weights.putIfAbsent(r.exerciseId, () => r.weight);
        }
      }
      _initialized = true;
    }

    final isCycle = modeAsync.valueOrNull == PlanMode.cycle;
    // 模式未加载完成前不显示保存按钮，避免循环模式冷启动时闪现。
    final showSaveButton = modeAsync.hasValue &&
        (!isCycle ||
            cycleStateAsync.valueOrNull?.selection?.kind ==
                CycleSelectionKind.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: '导入备份',
            onPressed: _importBackup,
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: '导出备份',
            onPressed: _exportBackup,
          ),
          Consumer(
            builder: (_, ref, __) => IconButton(
              icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode, size: 20),
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
        data: (mode) {
          if (mode == PlanMode.cycle) {
            return _buildCycleBody(cycleStateAsync);
          }
          return _buildWeeklyBody();
        },
      ),
      bottomNavigationBar: showSaveButton
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _saveRecords,
                  icon: const Icon(Icons.save),
                  label: const Text('保存训练记录'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ---------- 计划模式（周模板） ----------

  Widget _buildWeeklyBody() {
    final exercisesAsync = ref.watch(todayExercisesProvider);

    return exercisesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (exercises) {
        if (exercises.isEmpty) {
          return _emptyHint(
            icon: Icons.fitness_center,
            title: '今天还没有动作',
            subtitle: '去「周模板」添加吧',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return _ExerciseRow(
              exerciseId: exercise.exerciseId,
              exerciseName: exercise.exerciseName,
              onWeightChanged: (v) => _weights[exercise.exerciseId] = v,
            );
          },
        );
      },
    );
  }

  // ---------- 循环模式 ----------

  Widget _buildCycleBody(AsyncValue<CycleTodayState> stateAsync) {
    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (state) {
        final selection = state.selection;
        if (selection == null) {
          return _buildCycleChooser(state);
        }
        if (selection.kind == CycleSelectionKind.day) {
          final dayIndex = selection.dayIndex!;
          return Column(
            children: [
              _buildCycleHeader('今日安排：第$dayIndex天', state),
              Expanded(
                child: state.exercises.isEmpty
                    ? _emptyHint(
                        icon: Icons.playlist_add,
                        title: '第$dayIndex天还没有动作',
                        subtitle: '去「周模板」的循环模式里添加吧',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: state.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = state.exercises[index];
                          return _ExerciseRow(
                            exerciseId: exercise.exerciseId,
                            exerciseName: exercise.exerciseName,
                            onWeightChanged: (v) =>
                                _weights[exercise.exerciseId] = v,
                          );
                        },
                      ),
              ),
            ],
          );
        }

        final isCardio = selection.kind == CycleSelectionKind.cardio;
        return Column(
          children: [
            _buildCycleHeader(isCardio ? '今日安排：有氧' : '今日安排：休息', state),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCardio ? Icons.directions_run : Icons.hotel,
                      size: 72,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCardio ? '今天练有氧' : '今天好好休息',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCardio ? '有氧不占用循环进度' : '恢复也是训练的一部分',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCycleHeader(String title, CycleTodayState state) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            Icon(Icons.repeat, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => _openPicker(state),
              child: const Text('更换'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleChooser(CycleTodayState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '循环模式 · 共 ${state.dayCount} 天',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              '今天建议：第${state.recommendedDay}天',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => _setSelection(CycleSelection(
                date: dateKeyOf(DateTime.now()),
                kind: CycleSelectionKind.day,
                dayIndex: state.recommendedDay,
              )),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('循环开练 · 第${state.recommendedDay}天'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.maxFinite,
              child: OutlinedButton.icon(
                onPressed: () => _openPicker(state),
                icon: const Icon(Icons.tune),
                label: const Text('自主选择今天的内容'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(CycleTodayState state) async {
    final current = state.selection;
    final today = dateKeyOf(DateTime.now());

    // 打开前等待模板加载完成，避免冷启动时动作数副标题误显示「暂无动作」。
    List<TemplateWithExercise> allTemplate;
    try {
      allTemplate = await ref.read(cycleTemplateProvider.future);
    } catch (_) {
      allTemplate = const [];
    }
    if (!mounted) return;

    final result = await showModalBottomSheet<CycleSelection>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  '选择今天的内容',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              for (var i = 1; i <= state.dayCount; i++)
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.fitness_center, size: 20),
                  title: Row(
                    children: [
                      Text('第$i天'),
                      if (state.recommendedDay == i) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text('推荐', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    _countForDay(allTemplate, i) > 0
                        ? '${_countForDay(allTemplate, i)} 个动作'
                        : '暂无动作',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: current?.kind == CycleSelectionKind.day &&
                          current?.dayIndex == i
                      ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.pop(
                    ctx,
                    CycleSelection(
                      date: today,
                      kind: CycleSelectionKind.day,
                      dayIndex: i,
                    ),
                  ),
                ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.directions_run, size: 20),
                title: const Text('有氧'),
                trailing: current?.kind == CycleSelectionKind.cardio
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(
                  ctx,
                  CycleSelection(date: today, kind: CycleSelectionKind.cardio),
                ),
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.hotel, size: 20),
                title: const Text('休息'),
                trailing: current?.kind == CycleSelectionKind.rest
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(
                  ctx,
                  CycleSelection(date: today, kind: CycleSelectionKind.rest),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;
    await _setSelection(result);
  }

  int _countForDay(List<TemplateWithExercise> all, int dayIndex) {
    var count = 0;
    for (final t in all) {
      if (t.dayOfWeek == dayIndex) count++;
    }
    return count;
  }

  Future<void> _setSelection(CycleSelection selection) async {
    // 先写库再判挂载：用户的选择不会因组件期间销毁而静默丢失。
    try {
      await _db.cycleDao.setSelection(selection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择失败: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    if (mounted) {
      ref.invalidate(cycleTodayStateProvider);
    }
  }

  // ---------- 通用 ----------

  Widget _emptyHint({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Future<void> _saveRecords() async {
    final isCycle = ref.read(planModeProvider).valueOrNull == PlanMode.cycle;
    final exercises = isCycle
        ? (ref.read(cycleTodayStateProvider).valueOrNull?.exercises ??
            const <TemplateWithExercise>[])
        : (ref.read(todayExercisesProvider).valueOrNull ??
            const <TemplateWithExercise>[]);

    final validRecords = <int, ({String name, double weight})>{};
    for (final ex in exercises) {
      final weight = _weights[ex.exerciseId];
      if (weight != null && weight > 0) {
        validRecords[ex.exerciseId] = (name: ex.exerciseName, weight: weight);
      }
    }

    if (validRecords.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请至少输入一个动作的重量')),
        );
      }
      return;
    }

    await ref.read(saveRecordsProvider(validRecords).future);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存')),
      );
      ref.invalidate(todayExercisesProvider);
      _weights.clear();
    }
  }
}

class _ExerciseRow extends ConsumerWidget {
  final int exerciseId;
  final String exerciseName;
  final ValueChanged<double?> onWeightChanged;

  const _ExerciseRow({
    required this.exerciseId,
    required this.exerciseName,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastWeightAsync = ref.watch(lastWeightsProvider(exerciseId));
    final lastDateAsync = ref.watch(lastTrainedDateProvider(exerciseId));

    return ExerciseInputCard(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      lastWeight: lastWeightAsync.valueOrNull,
      lastDate: lastDateAsync.valueOrNull,
      onWeightChanged: onWeightChanged,
    );
  }
}

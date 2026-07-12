// lib/screens/today_training_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(todayExercisesProvider);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练'),
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
            child: Center(child: Text('v1.1.3', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
        ],
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (exercises) {
          if (exercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '今天还没有动作',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '去「周模板」添加吧',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
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
      ),
    );
  }

  Future<void> _saveRecords() async {
    final exercises = ref.read(todayExercisesProvider).valueOrNull ?? [];

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

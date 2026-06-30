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
  final Map<String, double?> _weights = {};

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(todayExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日训练'),
        centerTitle: true,
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
                      exerciseName: exercise.exerciseName,
                      onWeightChanged: (v) => _weights[exercise.exerciseName] = v,
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
    final validRecords = <String, double>{};
    _weights.forEach((name, weight) {
      if (weight != null && weight > 0) {
        validRecords[name] = weight;
      }
    });

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
        const SnackBar(content: Text('已保存 ✅')),
      );
      ref.invalidate(todayExercisesProvider);
      _weights.clear();
    }
  }
}

/// 单个动作行 — 从 provider 查上次重量
class _ExerciseRow extends ConsumerWidget {
  final String exerciseName;
  final ValueChanged<double?> onWeightChanged;

  const _ExerciseRow({
    required this.exerciseName,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastWeightAsync = ref.watch(lastWeightsProvider(exerciseName));
    final lastDateAsync = ref.watch(lastTrainedDateProvider(exerciseName));

    return ExerciseInputCard(
      exerciseName: exerciseName,
      lastWeight: lastWeightAsync.valueOrNull,
      lastDate: lastDateAsync.valueOrNull,
      onWeightChanged: onWeightChanged,
    );
  }
}

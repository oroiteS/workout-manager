import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/providers/workout_providers.dart';

/// 动作库「加入模板」的目标：周模板的一天，或循环模板的一天。
sealed class PickTarget {
  const PickTarget();
}

class WeekPickTarget extends PickTarget {
  final int dayOfWeek;

  const WeekPickTarget(this.dayOfWeek);
}

class CyclePickTarget extends PickTarget {
  final int dayIndex;

  const CyclePickTarget(this.dayIndex);
}

/// 将动作写入 [target] 指向的模板并刷新相关 provider。
Future<void> addExerciseToTarget(
  WidgetRef ref,
  PickTarget target,
  String exerciseName, {
  String? datasetId,
}) async {
  final db = ref.read(databaseProvider);
  switch (target) {
    case WeekPickTarget(:final dayOfWeek):
      await db.templateDao.addExercise(
        dayOfWeek,
        exerciseName,
        datasetId: datasetId,
      );
      ref.invalidate(templateProvider);
      ref.invalidate(templateByDayProvider(dayOfWeek));
      ref.invalidate(todayExercisesProvider);
    case CyclePickTarget(:final dayIndex):
      await db.cycleDao.addExercise(
        dayIndex,
        exerciseName,
        datasetId: datasetId,
      );
      ref.invalidate(cycleTemplateProvider);
      ref.invalidate(cycleByDayProvider(dayIndex));
      ref.invalidate(cycleTodayStateProvider);
  }
}

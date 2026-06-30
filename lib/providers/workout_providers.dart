import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/database/database.dart';

// ─── 数据库单例 ───
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// ─── 今日训练 ───

/// 今天该练的动作列表（从模板加载）
final todayExercisesProvider = FutureProvider<List<WeekTemplateData>>((ref) async {
  final db = ref.watch(databaseProvider);
  final weekday = DateTime.now().weekday; // 1=Mon..7=Sun
  return db.templateDao.getByDay(weekday);
});

/// 每个动作的上次训练重量
final lastWeightsProvider = FutureProvider.family<double?, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastWeight(exerciseName);
});

/// 每个动作的上次训练日期
final lastTrainedDateProvider = FutureProvider.family<DateTime?, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastTrainedAt(exerciseName);
});

// ─── 周模板 ───

/// 全部 7 天的模板数据
final templateProvider = FutureProvider<List<WeekTemplateData>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getAll();
});

/// 按天过滤的模板
final templateByDayProvider = FutureProvider.family<List<WeekTemplateData>, int>((ref, day) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getByDay(day);
});

// ─── 训练记录 ───

/// 保存训练记录
final saveRecordsProvider = FutureProvider.family<void, Map<String, double>>((ref, records) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  for (final entry in records.entries) {
    await db.recordDao.insertRecord(entry.key, entry.value, now);
  }
  ref.invalidate(lastWeightsProvider);
  ref.invalidate(lastTrainedDateProvider);
});

// ─── 图表数据 ───

/// 单个动作的历史记录（用于趋势图）
final exerciseHistoryProvider =
    FutureProvider.family<List<TrainingRecordData>, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getHistory(exerciseName, limit: 20);
});

// ─── 模板操作（mutation helpers） ───

/// 添加模板动作
final addTemplateExerciseProvider = FutureProvider.family<void, ({int day, String name})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    await db.templateDao.addExercise(params.day, params.name);
    ref.invalidate(templateProvider);
    ref.invalidate(templateByDayProvider(params.day));
    ref.invalidate(todayExercisesProvider);
  },
);

/// 删除模板动作
final deleteTemplateExerciseProvider = FutureProvider.family<void, ({int day, String name})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    await db.templateDao.deleteExercise(params.day, params.name);
    ref.invalidate(templateProvider);
    ref.invalidate(templateByDayProvider(params.day));
    ref.invalidate(todayExercisesProvider);
  },
);

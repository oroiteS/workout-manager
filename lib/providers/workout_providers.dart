import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/database/database.dart';

// ─── 数据库单例 ───
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// ─── 今日训练 ───

final todayExercisesProvider = FutureProvider<List<WeekTemplateData>>((ref) async {
  final db = ref.watch(databaseProvider);
  final weekday = DateTime.now().weekday; // 1=Mon..7=Sun
  return db.templateDao.getByDay(weekday);
});

final lastWeightsProvider = FutureProvider.family<double?, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastWeight(exerciseName);
});

final lastTrainedDateProvider = FutureProvider.family<DateTime?, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastTrainedAt(exerciseName);
});

// ─── 周模板 ───

final templateProvider = FutureProvider<List<WeekTemplateData>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getAll();
});

final templateByDayProvider = FutureProvider.family<List<WeekTemplateData>, int>((ref, day) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getByDay(day);
});

// ─── 训练记录 ───

final saveRecordsProvider = FutureProvider.family<void, Map<String, double>>((ref, records) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  for (final entry in records.entries) {
    await db.recordDao.upsertRecord(entry.key, entry.value, now);
  }
  ref.invalidate(lastWeightsProvider);
  ref.invalidate(lastTrainedDateProvider);
  ref.invalidate(exerciseHistoryProvider);
  ref.invalidate(recordsGroupedByDateProvider);
  ref.invalidate(recordDatesProvider);
  ref.invalidate(recordsForDateProvider);
});

final deleteRecordProvider = FutureProvider.family<void, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  await db.recordDao.deleteById(id);
  ref.invalidate(exerciseHistoryProvider);
  ref.invalidate(recordsGroupedByDateProvider);
  ref.invalidate(recordDatesProvider);
  ref.invalidate(recordsForDateProvider);
});

final recordsGroupedByDateProvider = FutureProvider<List<TrainingRecordData>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordsGroupedByDate(limit: 50);
});

// ─── 图表数据 ───

final exerciseHistoryProvider =
    FutureProvider.family<List<TrainingRecordData>, String>((ref, exerciseName) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getHistory(exerciseName, limit: 20);
});

// ─── 日历 ───

final recordDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordDates();
});

final recordsForDateProvider = FutureProvider.family<List<TrainingRecordData>, DateTime>((ref, date) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordsForDate(date);
});

// ─── 模板操作 ───

final addTemplateExerciseProvider = FutureProvider.family<void, ({int day, String name})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    await db.templateDao.addExercise(params.day, params.name);
    ref.invalidate(templateProvider);
    ref.invalidate(templateByDayProvider(params.day));
    ref.invalidate(todayExercisesProvider);
  },
);

final deleteTemplateExerciseProvider = FutureProvider.family<void, ({int day, String name})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    await db.templateDao.deleteExercise(params.day, params.name);
    ref.invalidate(templateProvider);
    ref.invalidate(templateByDayProvider(params.day));
    ref.invalidate(todayExercisesProvider);
  },
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/database/database.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.exerciseDao.getAll();
});

final todayExercisesProvider = FutureProvider<List<TemplateWithExercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  final weekday = DateTime.now().weekday;
  return db.templateDao.getByDay(weekday);
});

final lastWeightsProvider = FutureProvider.family<double?, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastWeight(exerciseId);
});

final lastTrainedDateProvider = FutureProvider.family<DateTime?, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastTrainedAt(exerciseId);
});

final templateProvider = FutureProvider<List<TemplateWithExercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getAll();
});

final templateByDayProvider = FutureProvider.family<List<TemplateWithExercise>, int>((ref, day) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getByDay(day);
});

final saveRecordsProvider = FutureProvider.family<void, Map<int, ({String name, double weight})>>((ref, records) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  for (final entry in records.entries) {
    await db.recordDao.upsertRecord(entry.key, entry.value.name, entry.value.weight, now);
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

final exerciseHistoryProvider =
    FutureProvider.family<List<TrainingRecordData>, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getHistory(exerciseId, limit: 20);
});

final recordDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordDates();
});

final recordsForDateProvider = FutureProvider.family<List<TrainingRecordData>, DateTime>((ref, date) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordsForDate(date);
});

final saveRecordsForDateProvider =
    FutureProvider.family<void, ({DateTime date, Map<int, ({String name, double weight})> records})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    for (final entry in params.records.entries) {
      await db.recordDao.upsertRecord(entry.key, entry.value.name, entry.value.weight, params.date);
    }
    ref.invalidate(lastWeightsProvider);
    ref.invalidate(lastTrainedDateProvider);
    ref.invalidate(exerciseHistoryProvider);
    ref.invalidate(recordsGroupedByDateProvider);
    ref.invalidate(recordDatesProvider);
    ref.invalidate(recordsForDateProvider);
  },
);

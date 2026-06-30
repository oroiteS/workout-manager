import 'package:drift/drift.dart';
import 'database.dart';

part 'record_dao.g.dart';

@DriftAccessor(tables: [TrainingRecord])
class RecordDao extends DatabaseAccessor<AppDatabase> with _$RecordDaoMixin {
  RecordDao(super.attachedDatabase);

  Future<List<TrainingRecordData>> getHistory(
    String exerciseName, {
    int limit = 20,
  }) {
    return (select(trainingRecord)
          ..where((t) => t.exerciseName.equals(exerciseName))
          ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
          ..limit(limit))
        .get();
  }

  Future<double?> getLastWeight(String exerciseName) async {
    final query = select(trainingRecord)
      ..where((t) => t.exerciseName.equals(exerciseName))
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.weight;
  }

  Future<DateTime?> getLastTrainedAt(String exerciseName) async {
    final query = select(trainingRecord)
      ..where((t) => t.exerciseName.equals(exerciseName))
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.trainedAt;
  }

  Future<void> upsertRecord(
    String exerciseName,
    double weight,
    DateTime trainedAt,
  ) async {
    final startOfDay = DateTime(trainedAt.year, trainedAt.month, trainedAt.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await (select(trainingRecord)
      ..where((t) =>
          t.exerciseName.equals(exerciseName) &
          t.trainedAt.isBiggerOrEqualValue(startOfDay) &
          t.trainedAt.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(trainingRecord) ..where((t) => t.id.equals(existing.id)))
          .write(TrainingRecordCompanion(weight: Value(weight)));
    } else {
      await into(trainingRecord).insert(
        TrainingRecordCompanion.insert(
          exerciseName: exerciseName,
          weight: weight,
          trainedAt: trainedAt,
        ),
      );
    }
  }

  Future<void> updateWeight(int id, double weight) async {
    await (update(trainingRecord) ..where((t) => t.id.equals(id)))
        .write(TrainingRecordCompanion(weight: Value(weight)));
  }

  Future<void> deleteById(int id) async {
    await (delete(trainingRecord) ..where((t) => t.id.equals(id))).go();
  }

  Future<List<TrainingRecordData>> getRecordsGroupedByDate({int limit = 50}) {
    return (select(trainingRecord)
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
      ..limit(limit))
        .get();
  }

  Future<List<TrainingRecordData>> getRecordsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(trainingRecord)
      ..where((t) =>
          t.trainedAt.isBiggerOrEqualValue(startOfDay) &
          t.trainedAt.isSmallerThanValue(endOfDay))
      ..orderBy([(t) => OrderingTerm(expression: t.exerciseName)]))
      .get();
  }

  /// 获取有训练记录的所有日期（去重），用于日历标记
  Future<List<DateTime>> getRecordDates() async {
    final all = await (select(trainingRecord)
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)]))
      .get();

    final seen = <String>{};
    final result = <DateTime>[];
    for (final r in all) {
      final d = r.trainedAt;
      final key = '${d.year}-${d.month}-${d.day}';
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(DateTime(d.year, d.month, d.day));
      }
    }
    return result;
  }
}

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

  Future<void> deleteById(int id) async {
    await (delete(trainingRecord) ..where((t) => t.id.equals(id))).go();
  }

  Future<List<TrainingRecordData>> getRecordsGroupedByDate({int limit = 50}) {
    return (select(trainingRecord)
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
      ..limit(limit))
        .get();
  }

  Future<DateTime?> getLastTrainedAt(String exerciseName) async {
    final query = select(trainingRecord)
      ..where((t) => t.exerciseName.equals(exerciseName))
      ..orderBy([(t) => OrderingTerm(expression: t.trainedAt, mode: OrderingMode.desc)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.trainedAt;
  }
}

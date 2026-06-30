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

  Future<void> insertRecord(
    String exerciseName,
    double weight,
    DateTime trainedAt,
  ) {
    return into(trainingRecord).insert(
      TrainingRecordCompanion.insert(
        exerciseName: exerciseName,
        weight: weight,
        trainedAt: trainedAt,
      ),
    );
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

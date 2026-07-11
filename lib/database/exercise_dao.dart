import 'package:drift/drift.dart';
import 'database.dart';

part 'exercise_dao.g.dart';

@DriftAccessor(tables: [Exercises])
class ExerciseDao extends DatabaseAccessor<AppDatabase> with _$ExerciseDaoMixin {
  ExerciseDao(super.attachedDatabase);

  Future<List<Exercise>> getAll() {
    return select(exercises).get();
  }

  Future<Exercise?> getById(int id) {
    return (select(exercises)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<Exercise?> getByName(String name) {
    return (select(exercises)..where((e) => e.name.equals(name))).getSingleOrNull();
  }

  Future<int> add(String name, {String? datasetId}) {
    return into(exercises).insert(
      ExercisesCompanion.insert(
        name: name,
        datasetId: Value(datasetId),
      ),
    );
  }

  /// Find-or-create by exact name. Optionally bind [datasetId] when provided.
  Future<int> ensureExercise({
    required String name,
    String? datasetId,
  }) async {
    final existing = await getByName(name);
    if (existing == null) {
      return add(name, datasetId: datasetId);
    }
    if (datasetId != null &&
        datasetId.isNotEmpty &&
        (existing.datasetId == null || existing.datasetId!.isEmpty)) {
      await (update(exercises)..where((e) => e.id.equals(existing.id))).write(
        ExercisesCompanion(datasetId: Value(datasetId)),
      );
    }
    return existing.id;
  }

  Future<int> deleteById(int id) async {
    await (delete(attachedDatabase.weekTemplate)
          ..where((t) => t.exerciseId.equals(id)))
        .go();
    await (delete(attachedDatabase.trainingRecord)
          ..where((t) => t.exerciseId.equals(id)))
        .go();
    return (delete(exercises)..where((e) => e.id.equals(id))).go();
  }

  Future<bool> updateName(int id, String newName) async {
    final rows = await (update(exercises)..where((e) => e.id.equals(id)))
        .write(ExercisesCompanion(name: Value(newName)));
    return rows > 0;
  }
}

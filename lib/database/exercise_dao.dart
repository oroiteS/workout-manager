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

  Future<int> add(String name) {
    return into(exercises).insert(ExercisesCompanion.insert(name: name));
  }

  Future<int> delete(int id) {
    return (delete(exercises)..where((e) => e.id.equals(id))).go();
  }

  Future<bool> updateName(int id, String newName) async {
    final rows = await (update(exercises)
      ..where((e) => e.id.equals(id)))
      .write(ExercisesCompanion(name: Value(newName)));
    return rows > 0;
  }
}

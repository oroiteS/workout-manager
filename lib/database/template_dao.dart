import 'package:drift/drift.dart';
import 'database.dart';

part 'template_dao.g.dart';

@DriftAccessor(tables: [WeekTemplate])
class TemplateDao extends DatabaseAccessor<AppDatabase> with _$TemplateDaoMixin {
  TemplateDao(super.attachedDatabase);

  Future<List<WeekTemplateData>> getByDay(int dayOfWeek) {
    return (select(weekTemplate)
          ..where((t) => t.dayOfWeek.equals(dayOfWeek))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .get();
  }

  Future<List<WeekTemplateData>> getAll() {
    return select(weekTemplate).get();
  }

  Future<void> addExercise(int dayOfWeek, String exerciseName) {
    return into(weekTemplate).insert(
      WeekTemplateCompanion.insert(
        dayOfWeek: dayOfWeek,
        exerciseName: exerciseName,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteExercise(int dayOfWeek, String exerciseName) {
    return (delete(weekTemplate)
          ..where((t) =>
              t.dayOfWeek.equals(dayOfWeek) &
              t.exerciseName.equals(exerciseName)))
        .go();
  }

  Future<void> updateSortOrder(
      String exerciseName, int dayOfWeek, int newOrder) {
    return (update(weekTemplate)
          ..where((t) =>
              t.exerciseName.equals(exerciseName) &
              t.dayOfWeek.equals(dayOfWeek)))
        .write(WeekTemplateCompanion(sortOrder: Value(newOrder)));
  }
}

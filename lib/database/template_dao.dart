import 'package:drift/drift.dart';
import 'database.dart';

part 'template_dao.g.dart';

class TemplateWithExercise {
  final int dayOfWeek;
  final int exerciseId;
  final String exerciseName;
  final int sortOrder;

  const TemplateWithExercise({
    required this.dayOfWeek,
    required this.exerciseId,
    required this.exerciseName,
    required this.sortOrder,
  });
}

@DriftAccessor(tables: [WeekTemplate, Exercises])
class TemplateDao extends DatabaseAccessor<AppDatabase> with _$TemplateDaoMixin {
  TemplateDao(super.attachedDatabase);

  Future<List<TemplateWithExercise>> getByDay(int dayOfWeek) async {
    final query = select(weekTemplate).join([
      innerJoin(exercises, exercises.id.equalsExp(weekTemplate.exerciseId)),
    ])
      ..where(weekTemplate.dayOfWeek.equals(dayOfWeek))
      ..orderBy([OrderingTerm(expression: weekTemplate.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      final template = row.readTable(weekTemplate);
      final exercise = row.readTable(exercises);
      return TemplateWithExercise(
        dayOfWeek: template.dayOfWeek,
        exerciseId: template.exerciseId,
        exerciseName: exercise.name,
        sortOrder: template.sortOrder,
      );
    }).toList();
  }

  Future<List<TemplateWithExercise>> getAll() async {
    final query = select(weekTemplate).join([
      innerJoin(exercises, exercises.id.equalsExp(weekTemplate.exerciseId)),
    ]);

    final rows = await query.get();
    return rows.map((row) {
      final template = row.readTable(weekTemplate);
      final exercise = row.readTable(exercises);
      return TemplateWithExercise(
        dayOfWeek: template.dayOfWeek,
        exerciseId: template.exerciseId,
        exerciseName: exercise.name,
        sortOrder: template.sortOrder,
      );
    }).toList();
  }

  Future<void> addExercise(int dayOfWeek, String exerciseName) async {
    final existing = await (select(exercises)
      ..where((e) => e.name.equals(exerciseName)))
      .getSingleOrNull();

    final exerciseId = existing?.id ??
      await into(exercises).insert(ExercisesCompanion.insert(name: exerciseName));

    await into(weekTemplate).insert(
      WeekTemplateCompanion.insert(
        dayOfWeek: dayOfWeek,
        exerciseId: exerciseId,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteExercise(int dayOfWeek, int exerciseId) {
    return (delete(weekTemplate)
      ..where((t) =>
        t.dayOfWeek.equals(dayOfWeek) &
        t.exerciseId.equals(exerciseId)))
      .go();
  }

  Future<void> updateSortOrder(int exerciseId, int dayOfWeek, int newOrder) {
    return (update(weekTemplate)
      ..where((t) =>
        t.exerciseId.equals(exerciseId) &
        t.dayOfWeek.equals(dayOfWeek)))
      .write(WeekTemplateCompanion(sortOrder: Value(newOrder)));
  }
}

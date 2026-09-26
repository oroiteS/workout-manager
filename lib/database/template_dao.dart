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

  Future<void> addExercise(
    int dayOfWeek,
    String exerciseName, {
    String? datasetId,
  }) async {
    final exerciseId = await attachedDatabase.exerciseDao.ensureExercise(
      name: exerciseName,
      datasetId: datasetId,
    );

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

  Future<int> insertWithId(WeekTemplateCompanion companion) {
    return into(weekTemplate).insert(companion);
  }

  Future<void> deleteAll() async {
    await delete(weekTemplate).go();
  }

  /// 用 [exercisesByDay] 整周替换当前计划（day 1-7 → 动作名，按列表顺序设定 sort_order）。
  ///
  /// 只写 `week_template`，不改动 `training_record`：历史记录与动作库条目均保留，
  /// 仅按中文名复用或新建动作（并尝试绑定库内 datasetId 以显示示意图）。
  Future<void> replaceAll(Map<int, List<String>> exercisesByDay) {
    return attachedDatabase.transaction(() async {
      await deleteAll();
      for (final entry in exercisesByDay.entries) {
        var order = 0;
        for (final name in entry.value) {
          final hit =
              await attachedDatabase.catalogDao.findByNameZh(name);
          final exerciseId = await attachedDatabase.exerciseDao
              .ensureExercise(name: name, datasetId: hit?.datasetId);
          await into(weekTemplate).insert(
            WeekTemplateCompanion.insert(
              dayOfWeek: entry.key,
              exerciseId: exerciseId,
              sortOrder: Value(order++),
            ),
          );
        }
      }
    });
  }
}

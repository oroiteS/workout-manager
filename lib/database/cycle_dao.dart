import 'package:drift/drift.dart';
import 'database.dart';

part 'cycle_dao.g.dart';

enum PlanMode { weekly, cycle }

enum CycleSelectionKind { day, cardio, rest }

/// Local-date key `yyyy-MM-dd` used by [CycleDailySelection.date].
String dateKeyOf(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

class CycleSelection {
  final String date;
  final CycleSelectionKind kind;

  /// Only meaningful when [kind] is [CycleSelectionKind.day].
  final int? dayIndex;

  const CycleSelection({
    required this.date,
    required this.kind,
    this.dayIndex,
  });
}

@DriftAccessor(
  tables: [CycleTemplate, CycleDailySelection, Exercises, AppMeta],
)
class CycleDao extends DatabaseAccessor<AppDatabase> with _$CycleDaoMixin {
  CycleDao(super.attachedDatabase);

  static const metaPlanMode = 'plan_mode';
  static const metaCycleDayCount = 'cycle_day_count';
  static const defaultDayCount = 3;
  static const maxDayCount = 10;

  // ---------- 计划模式 ----------

  Future<PlanMode> getPlanMode() async {
    final value = await _getMeta(metaPlanMode);
    return value == PlanMode.cycle.name ? PlanMode.cycle : PlanMode.weekly;
  }

  Future<void> setPlanMode(PlanMode mode) =>
      _setMeta(metaPlanMode, mode.name);

  // ---------- 循环天数 ----------

  Future<int> getDayCount() async {
    final value = int.tryParse(await _getMeta(metaCycleDayCount) ?? '');
    if (value == null || value < 1) return defaultDayCount;
    return value > maxDayCount ? maxDayCount : value;
  }

  /// 设置循环天数；缩短时在同一事务里删除超出范围的循环动作。
  Future<void> setDayCount(int count) {
    final clamped = count.clamp(1, maxDayCount).toInt();
    return attachedDatabase.transaction(() async {
      await _setMeta(metaCycleDayCount, '$clamped');
      await (delete(cycleTemplate)
            ..where((t) => t.dayIndex.isBiggerThanValue(clamped)))
          .go();
    });
  }

  /// 移除计划模式/循环天数配置（备份导入用），保留 catalog 等其他 meta。
  Future<void> clearSettings() async {
    await (delete(appMeta)..where((t) => t.key.equals(metaPlanMode))).go();
    await (delete(appMeta)..where((t) => t.key.equals(metaCycleDayCount))).go();
  }

  // ---------- 循环动作 ----------

  Future<List<TemplateWithExercise>> getByDay(int dayIndex) async {
    final query = select(cycleTemplate).join([
      innerJoin(exercises, exercises.id.equalsExp(cycleTemplate.exerciseId)),
    ])
      ..where(cycleTemplate.dayIndex.equals(dayIndex))
      ..orderBy([OrderingTerm(expression: cycleTemplate.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      final template = row.readTable(cycleTemplate);
      final exercise = row.readTable(exercises);
      return TemplateWithExercise(
        dayOfWeek: template.dayIndex,
        exerciseId: template.exerciseId,
        exerciseName: exercise.name,
        sortOrder: template.sortOrder,
      );
    }).toList();
  }

  Future<List<TemplateWithExercise>> getAll() async {
    final query = select(cycleTemplate).join([
      innerJoin(exercises, exercises.id.equalsExp(cycleTemplate.exerciseId)),
    ])
      ..orderBy([
        OrderingTerm(expression: cycleTemplate.dayIndex),
        OrderingTerm(expression: cycleTemplate.sortOrder),
      ]);

    final rows = await query.get();
    return rows.map((row) {
      final template = row.readTable(cycleTemplate);
      final exercise = row.readTable(exercises);
      return TemplateWithExercise(
        dayOfWeek: template.dayIndex,
        exerciseId: template.exerciseId,
        exerciseName: exercise.name,
        sortOrder: template.sortOrder,
      );
    }).toList();
  }

  Future<void> addExercise(
    int dayIndex,
    String exerciseName, {
    String? datasetId,
  }) async {
    final exerciseId = await attachedDatabase.exerciseDao.ensureExercise(
      name: exerciseName,
      datasetId: datasetId,
    );
    await into(cycleTemplate).insert(
      CycleTemplateCompanion.insert(
        dayIndex: dayIndex,
        exerciseId: exerciseId,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteExercise(int dayIndex, int exerciseId) {
    return (delete(cycleTemplate)
      ..where((t) =>
          t.dayIndex.equals(dayIndex) & t.exerciseId.equals(exerciseId)))
        .go();
  }

  Future<void> deleteAll() => delete(cycleTemplate).go();

  Future<int> insertFromBackup(CycleTemplateCompanion companion) {
    return into(cycleTemplate).insert(companion);
  }

  /// 用 [exercisesByDay] 整体替换循环模板（第 N 天 → 动作名，按行序设 sort_order）。
  ///
  /// 只写 `cycle_template`，不改动训练记录与每日选择：历史记录按动作保留，
  /// 仅按中文名复用或新建动作（并尝试绑定库内 datasetId 以显示示意图）。
  Future<void> replaceAll(Map<int, List<String>> exercisesByDay) {
    return attachedDatabase.transaction(() async {
      await deleteAll();
      for (final entry in exercisesByDay.entries) {
        var order = 0;
        for (final name in entry.value) {
          final hit = await attachedDatabase.catalogDao.findByNameZh(name);
          final exerciseId = await attachedDatabase.exerciseDao
              .ensureExercise(name: name, datasetId: hit?.datasetId);
          await into(cycleTemplate).insert(
            CycleTemplateCompanion.insert(
              dayIndex: entry.key,
              exerciseId: exerciseId,
              sortOrder: Value(order++),
            ),
          );
        }
      }
    });
  }

  // ---------- 每日选择 ----------

  Future<CycleSelection?> getSelection(String date) async {
    final row = await (select(cycleDailySelection)
          ..where((t) => t.date.equals(date)))
        .getSingleOrNull();
    if (row == null) return null;
    final kind = CycleSelectionKind.values.asNameMap()[row.kind];
    if (kind == null) return null;
    if (kind == CycleSelectionKind.day && row.dayIndex == null) return null;
    return CycleSelection(date: row.date, kind: kind, dayIndex: row.dayIndex);
  }

  Future<void> setSelection(CycleSelection selection) {
    return into(cycleDailySelection).insert(
      CycleDailySelectionCompanion.insert(
        date: selection.date,
        kind: selection.kind.name,
        dayIndex: Value(selection.dayIndex),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<CycleSelection>> getAllSelections() async {
    final rows = await select(cycleDailySelection).get();
    return rows
        .map((row) {
          final kind = CycleSelectionKind.values.asNameMap()[row.kind];
          if (kind == null) return null;
          return CycleSelection(
            date: row.date,
            kind: kind,
            dayIndex: row.dayIndex,
          );
        })
        .nonNulls
        .toList();
  }

  Future<void> deleteAllSelections() => delete(cycleDailySelection).go();

  // ---------- 循环进度 ----------

  /// 建议的循环天：[date] 之前最近一次「训练日」选择的下一天；无历史则第 1 天。
  ///
  /// 只看严格早于 [date] 的选择，因此今天的已选内容不影响今天的建议；
  /// 有氧/休息不产生训练日选择，因此不推进循环；
  /// 缩短循环天数后越界的陈旧行（dayIndex > [dayCount]）同样跳过。
  Future<int> recommendDayIndex(DateTime date, {required int dayCount}) async {
    final query = select(cycleDailySelection)
      ..where((t) =>
          t.kind.equals(CycleSelectionKind.day.name) &
          t.dayIndex.isNotNull() &
          t.dayIndex.isSmallerOrEqualValue(dayCount) &
          t.date.isSmallerThanValue(dateKeyOf(date)))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ])
      ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return 1;
    return (rows.first.dayIndex! % dayCount) + 1;
  }

  Future<String?> _getMeta(String key) async {
    final row = await (select(appMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _setMeta(String key, String value) {
    return into(appMeta).insert(
      AppMetaCompanion.insert(key: key, value: value),
      mode: InsertMode.insertOrReplace,
    );
  }
}

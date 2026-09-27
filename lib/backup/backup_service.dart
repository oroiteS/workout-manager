import 'dart:convert';

import 'package:workout_manager/database/database.dart';

import 'backup_models.dart';

class BackupService {
  final AppDatabase db;
  BackupService(this.db);

  Future<String> exportToJson({String? suggestedFileName}) async {
    final exercises = await db.exerciseDao.getAll();
    final templates = await db.templateDao.getAll();
    final allRecords = await db.recordDao.getAllForBackup();
    final cycleRows = await db.cycleDao.getAll();
    final cycleSelections = await db.cycleDao.getAllSelections();
    final planMode = await db.cycleDao.getPlanMode();
    final dayCount = await db.cycleDao.getDayCount();

    final now = DateTime.now();
    final exercisesRows = exercises
        .map(
          (e) => BackupExercise(
            id: e.id,
            name: e.name,
            datasetId: e.datasetId,
          ),
        )
        .toList();

    final templateRows = templates
        .map(
          (t) => WeekTemplateRowData(
            dayOfWeek: t.dayOfWeek,
            exerciseId: t.exerciseId,
            sortOrder: t.sortOrder,
          ),
        )
        .toList();

    final recordRows = allRecords
        .map(
          (r) => TrainingRecordRowData(
            exerciseId: r.exerciseId,
            exerciseName: r.exerciseName,
            weight: r.weight,
            trainedAt: r.trainedAt.toIso8601String(),
          ),
        )
        .toList();

    final cycleRowsOut = cycleRows
        .map(
          (t) => CycleTemplateRowData(
            dayIndex: t.dayOfWeek,
            exerciseId: t.exerciseId,
            sortOrder: t.sortOrder,
          ),
        )
        .toList();

    final selectionRows = cycleSelections
        .map(
          (s) => CycleSelectionRowData(
            date: s.date,
            kind: s.kind.name,
            dayIndex: s.dayIndex,
          ),
        )
        .toList();

    final backup = BackupFile(
      exportedAt: now.toUtc().toIso8601String(),
      appVersion: '1.4.0+18',
      data: BackupData(
        exercises: exercisesRows,
        weekTemplate: templateRows,
        trainingRecords: recordRows,
        cycleTemplate: cycleRowsOut,
        cycleSelections: selectionRows,
        cycleSettings: CycleSettingsData(
          planMode: planMode.name,
          dayCount: dayCount,
        ),
      ),
    );

    return const JsonEncoder.withIndent('  ').convert(backup.toJson());
  }

  Future<void> importFromJsonString(String jsonString) async {
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw BackupParseException('JSON 根节点必须为对象');
      }
      json = decoded;
    } on FormatException catch (e) {
      throw BackupParseException('JSON 解析失败: ${e.message}');
    }

    final backup = validateBackup(json);

    await db.transaction(() async {
      await db.recordDao.deleteAll();
      await db.templateDao.deleteAll();
      await db.exerciseDao.deleteAll();
      await db.cycleDao.deleteAll();
      await db.cycleDao.deleteAllSelections();
      await db.cycleDao.clearSettings();

      for (final e in backup.data.exercises) {
        await db.exerciseDao.insertWithId(e.toCompanion());
      }
      for (final t in backup.data.weekTemplate) {
        await db.templateDao.insertWithId(t.toCompanion());
      }
      for (final r in backup.data.trainingRecords) {
        await db.recordDao.insertFromBackup(
          exerciseId: r.exerciseId,
          exerciseName: r.exerciseName,
          weight: r.weight,
          trainedAt: DateTime.parse(r.trainedAt),
        );
      }
      for (final t in backup.data.cycleTemplate) {
        await db.cycleDao.insertFromBackup(t.toCompanion());
      }
      for (final s in backup.data.cycleSelections) {
        await db.cycleDao.setSelection(CycleSelection(
          date: s.date,
          kind: CycleSelectionKind.values.asNameMap()[s.kind]!,
          dayIndex: s.dayIndex,
        ));
      }
      final settings = backup.data.cycleSettings;
      if (settings != null) {
        await db.cycleDao
            .setPlanMode(PlanMode.values.asNameMap()[settings.planMode]!);
        if (settings.dayCount != null) {
          await db.cycleDao.setDayCount(settings.dayCount!);
        }
      }
    });
  }
}

// lib/database/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'exercise_dao.dart';
import 'template_dao.dart';
import 'record_dao.dart';
import 'catalog_dao.dart';
import 'cycle_dao.dart';

export 'exercise_dao.dart';
export 'template_dao.dart';
export 'record_dao.dart';
export 'catalog_dao.dart';
export 'cycle_dao.dart';

part 'database.g.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get datasetId => text().nullable()();
}

class WeekTemplate extends Table {
  IntColumn get dayOfWeek => integer()();
  IntColumn get exerciseId => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayOfWeek, exerciseId};
}

class TrainingRecord extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get exerciseId => integer()();
  TextColumn get exerciseName => text()();
  RealColumn get weight => real()();
  DateTimeColumn get trainedAt => dateTime()();
}

class CatalogExercises extends Table {
  TextColumn get datasetId => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameZh => text()();
  TextColumn get bodyPart => text()();
  TextColumn get equipment => text()();
  TextColumn get target => text()();
  TextColumn get muscleGroup => text()();
  TextColumn get secondaryMuscles => text()();
  TextColumn get instructionsZh => text()();
  TextColumn get instructionStepsZh => text()();
  TextColumn get gifAsset => text()();

  @override
  Set<Column> get primaryKey => {datasetId};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class CycleTemplate extends Table {
  IntColumn get dayIndex => integer()();
  IntColumn get exerciseId => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayIndex, exerciseId};
}

class CycleDailySelection extends Table {
  TextColumn get date => text()();
  TextColumn get kind => text()();
  IntColumn get dayIndex => integer().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(
  tables: [
    Exercises,
    WeekTemplate,
    TrainingRecord,
    CatalogExercises,
    AppMeta,
    CycleTemplate,
    CycleDailySelection,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// 测试用：指定底层执行器（如模拟旧版本数据库执行升级）。
  AppDatabase.forTestingOn(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            // v1/v2 表结构与现行差异过大，且自 app v2 起就无法打开，
            // 不再支持自动迁移：指引用对应旧版本导出备份后导入恢复。
            throw Exception(
              '数据库版本过旧（v1/v2），无法自动升级。'
              '请用对应的旧版本导出备份后，在当前版本导入恢复。',
            );
          }
          // v3 → v4：仅新增循环两张表。
          await m.createTable(cycleTemplate);
          await m.createTable(cycleDailySelection);
        },
      );

  ExerciseDao get exerciseDao => ExerciseDao(this);
  TemplateDao get templateDao => TemplateDao(this);
  RecordDao get recordDao => RecordDao(this);
  CatalogDao get catalogDao => CatalogDao(this);
  CycleDao get cycleDao => CycleDao(this);
}

AppDatabase createMemoryDb() {
  return AppDatabase.forTesting();
}

QueryExecutor _openDatabase() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'workout.db'));
    return NativeDatabase.createInBackground(file);
  });
}

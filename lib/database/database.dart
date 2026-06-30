// lib/database/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'template_dao.dart';
import 'record_dao.dart';

export 'template_dao.dart';
export 'record_dao.dart';

part 'database.g.dart';

/// 周训练模板 — 每天有几个动作
class WeekTemplate extends Table {
  IntColumn get dayOfWeek => integer()();
  TextColumn get exerciseName => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {dayOfWeek, exerciseName};
}

/// 训练记录 — 每次训练的动作+重量
class TrainingRecord extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseName => text()();
  RealColumn get weight => real()();
  DateTimeColumn get trainedAt => dateTime()();
}

@DriftDatabase(tables: [WeekTemplate, TrainingRecord])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  /// 暴露 DAOs
  TemplateDao get templateDao => TemplateDao(this);
  RecordDao get recordDao => RecordDao(this);
}

/// 用于测试的内存数据库
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

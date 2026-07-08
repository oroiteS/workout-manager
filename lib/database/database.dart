// lib/database/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'exercise_dao.dart';
import 'template_dao.dart';
import 'record_dao.dart';

export 'exercise_dao.dart';
export 'template_dao.dart';
export 'record_dao.dart';

part 'database.g.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
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

@DriftDatabase(tables: [Exercises, WeekTemplate, TrainingRecord])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  ExerciseDao get exerciseDao => ExerciseDao(this);
  TemplateDao get templateDao => TemplateDao(this);
  RecordDao get recordDao => RecordDao(this);
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

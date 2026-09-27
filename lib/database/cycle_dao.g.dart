// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_dao.dart';

// ignore_for_file: type=lint
mixin _$CycleDaoMixin on DatabaseAccessor<AppDatabase> {
  $CycleTemplateTable get cycleTemplate => attachedDatabase.cycleTemplate;
  $CycleDailySelectionTable get cycleDailySelection =>
      attachedDatabase.cycleDailySelection;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $AppMetaTable get appMeta => attachedDatabase.appMeta;
  CycleDaoManager get managers => CycleDaoManager(this);
}

class CycleDaoManager {
  final _$CycleDaoMixin _db;
  CycleDaoManager(this._db);
  $$CycleTemplateTableTableManager get cycleTemplate =>
      $$CycleTemplateTableTableManager(_db.attachedDatabase, _db.cycleTemplate);
  $$CycleDailySelectionTableTableManager get cycleDailySelection =>
      $$CycleDailySelectionTableTableManager(
          _db.attachedDatabase, _db.cycleDailySelection);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db.attachedDatabase, _db.appMeta);
}

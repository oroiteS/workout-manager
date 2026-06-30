// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_dao.dart';

// ignore_for_file: type=lint
mixin _$RecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingRecordTable get trainingRecord => attachedDatabase.trainingRecord;
  RecordDaoManager get managers => RecordDaoManager(this);
}

class RecordDaoManager {
  final _$RecordDaoMixin _db;
  RecordDaoManager(this._db);
  $$TrainingRecordTableTableManager get trainingRecord =>
      $$TrainingRecordTableTableManager(
          _db.attachedDatabase, _db.trainingRecord);
}

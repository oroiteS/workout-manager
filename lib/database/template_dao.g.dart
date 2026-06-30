// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $WeekTemplateTable get weekTemplate => attachedDatabase.weekTemplate;
  TemplateDaoManager get managers => TemplateDaoManager(this);
}

class TemplateDaoManager {
  final _$TemplateDaoMixin _db;
  TemplateDaoManager(this._db);
  $$WeekTemplateTableTableManager get weekTemplate =>
      $$WeekTemplateTableTableManager(_db.attachedDatabase, _db.weekTemplate);
}

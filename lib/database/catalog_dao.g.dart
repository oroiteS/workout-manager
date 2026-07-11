// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dao.dart';

// ignore_for_file: type=lint
mixin _$CatalogDaoMixin on DatabaseAccessor<AppDatabase> {
  $CatalogExercisesTable get catalogExercises =>
      attachedDatabase.catalogExercises;
  $AppMetaTable get appMeta => attachedDatabase.appMeta;
  CatalogDaoManager get managers => CatalogDaoManager(this);
}

class CatalogDaoManager {
  final _$CatalogDaoMixin _db;
  CatalogDaoManager(this._db);
  $$CatalogExercisesTableTableManager get catalogExercises =>
      $$CatalogExercisesTableTableManager(
          _db.attachedDatabase, _db.catalogExercises);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db.attachedDatabase, _db.appMeta);
}

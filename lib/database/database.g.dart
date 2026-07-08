// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(Insertable<Exercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  const Exercise({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Exercise copyWith({int? id, String? name}) => Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise && other.id == this.id && other.name == this.name);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ExercisesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $WeekTemplateTable extends WeekTemplate
    with TableInfo<$WeekTemplateTable, WeekTemplateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekTemplateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [dayOfWeek, exerciseId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_template';
  @override
  VerificationContext validateIntegrity(Insertable<WeekTemplateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayOfWeek, exerciseId};
  @override
  WeekTemplateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekTemplateData(
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $WeekTemplateTable createAlias(String alias) {
    return $WeekTemplateTable(attachedDatabase, alias);
  }
}

class WeekTemplateData extends DataClass
    implements Insertable<WeekTemplateData> {
  final int dayOfWeek;
  final int exerciseId;
  final int sortOrder;
  const WeekTemplateData(
      {required this.dayOfWeek,
      required this.exerciseId,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WeekTemplateCompanion toCompanion(bool nullToAbsent) {
    return WeekTemplateCompanion(
      dayOfWeek: Value(dayOfWeek),
      exerciseId: Value(exerciseId),
      sortOrder: Value(sortOrder),
    );
  }

  factory WeekTemplateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekTemplateData(
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WeekTemplateData copyWith(
          {int? dayOfWeek, int? exerciseId, int? sortOrder}) =>
      WeekTemplateData(
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        exerciseId: exerciseId ?? this.exerciseId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WeekTemplateData copyWithCompanion(WeekTemplateCompanion data) {
    return WeekTemplateData(
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekTemplateData(')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayOfWeek, exerciseId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekTemplateData &&
          other.dayOfWeek == this.dayOfWeek &&
          other.exerciseId == this.exerciseId &&
          other.sortOrder == this.sortOrder);
}

class WeekTemplateCompanion extends UpdateCompanion<WeekTemplateData> {
  final Value<int> dayOfWeek;
  final Value<int> exerciseId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WeekTemplateCompanion({
    this.dayOfWeek = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekTemplateCompanion.insert({
    required int dayOfWeek,
    required int exerciseId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : dayOfWeek = Value(dayOfWeek),
        exerciseId = Value(exerciseId);
  static Insertable<WeekTemplateData> custom({
    Expression<int>? dayOfWeek,
    Expression<int>? exerciseId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekTemplateCompanion copyWith(
      {Value<int>? dayOfWeek,
      Value<int>? exerciseId,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return WeekTemplateCompanion(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      exerciseId: exerciseId ?? this.exerciseId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekTemplateCompanion(')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingRecordTable extends TrainingRecord
    with TableInfo<$TrainingRecordTable, TrainingRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingRecordTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exerciseNameMeta =
      const VerificationMeta('exerciseName');
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
      'exercise_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _trainedAtMeta =
      const VerificationMeta('trainedAt');
  @override
  late final GeneratedColumn<DateTime> trainedAt = GeneratedColumn<DateTime>(
      'trained_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, exerciseId, exerciseName, weight, trainedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_record';
  @override
  VerificationContext validateIntegrity(Insertable<TrainingRecordData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
          _exerciseNameMeta,
          exerciseName.isAcceptableOrUnknown(
              data['exercise_name']!, _exerciseNameMeta));
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('trained_at')) {
      context.handle(_trainedAtMeta,
          trainedAt.isAcceptableOrUnknown(data['trained_at']!, _trainedAtMeta));
    } else if (isInserting) {
      context.missing(_trainedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingRecordData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_id'])!,
      exerciseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_name'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      trainedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}trained_at'])!,
    );
  }

  @override
  $TrainingRecordTable createAlias(String alias) {
    return $TrainingRecordTable(attachedDatabase, alias);
  }
}

class TrainingRecordData extends DataClass
    implements Insertable<TrainingRecordData> {
  final int id;
  final int exerciseId;
  final String exerciseName;
  final double weight;
  final DateTime trainedAt;
  const TrainingRecordData(
      {required this.id,
      required this.exerciseId,
      required this.exerciseName,
      required this.weight,
      required this.trainedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['weight'] = Variable<double>(weight);
    map['trained_at'] = Variable<DateTime>(trainedAt);
    return map;
  }

  TrainingRecordCompanion toCompanion(bool nullToAbsent) {
    return TrainingRecordCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      exerciseName: Value(exerciseName),
      weight: Value(weight),
      trainedAt: Value(trainedAt),
    );
  }

  factory TrainingRecordData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingRecordData(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      weight: serializer.fromJson<double>(json['weight']),
      trainedAt: serializer.fromJson<DateTime>(json['trainedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'weight': serializer.toJson<double>(weight),
      'trainedAt': serializer.toJson<DateTime>(trainedAt),
    };
  }

  TrainingRecordData copyWith(
          {int? id,
          int? exerciseId,
          String? exerciseName,
          double? weight,
          DateTime? trainedAt}) =>
      TrainingRecordData(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        exerciseName: exerciseName ?? this.exerciseName,
        weight: weight ?? this.weight,
        trainedAt: trainedAt ?? this.trainedAt,
      );
  TrainingRecordData copyWithCompanion(TrainingRecordCompanion data) {
    return TrainingRecordData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      weight: data.weight.present ? data.weight.value : this.weight,
      trainedAt: data.trainedAt.present ? data.trainedAt.value : this.trainedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingRecordData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('trainedAt: $trainedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseId, exerciseName, weight, trainedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingRecordData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.weight == this.weight &&
          other.trainedAt == this.trainedAt);
}

class TrainingRecordCompanion extends UpdateCompanion<TrainingRecordData> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<String> exerciseName;
  final Value<double> weight;
  final Value<DateTime> trainedAt;
  const TrainingRecordCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.weight = const Value.absent(),
    this.trainedAt = const Value.absent(),
  });
  TrainingRecordCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required String exerciseName,
    required double weight,
    required DateTime trainedAt,
  })  : exerciseId = Value(exerciseId),
        exerciseName = Value(exerciseName),
        weight = Value(weight),
        trainedAt = Value(trainedAt);
  static Insertable<TrainingRecordData> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<String>? exerciseName,
    Expression<double>? weight,
    Expression<DateTime>? trainedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (weight != null) 'weight': weight,
      if (trainedAt != null) 'trained_at': trainedAt,
    });
  }

  TrainingRecordCompanion copyWith(
      {Value<int>? id,
      Value<int>? exerciseId,
      Value<String>? exerciseName,
      Value<double>? weight,
      Value<DateTime>? trainedAt}) {
    return TrainingRecordCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      trainedAt: trainedAt ?? this.trainedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (trainedAt.present) {
      map['trained_at'] = Variable<DateTime>(trainedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingRecordCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('trainedAt: $trainedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WeekTemplateTable weekTemplate = $WeekTemplateTable(this);
  late final $TrainingRecordTable trainingRecord = $TrainingRecordTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [exercises, weekTemplate, trainingRecord];
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> name,
});

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$ExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
    Exercise,
    PrefetchHooks Function()> {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            name: name,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) =>
              ExercisesCompanion.insert(
            id: id,
            name: name,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExercisesTable,
    Exercise,
    $$ExercisesTableFilterComposer,
    $$ExercisesTableOrderingComposer,
    $$ExercisesTableAnnotationComposer,
    $$ExercisesTableCreateCompanionBuilder,
    $$ExercisesTableUpdateCompanionBuilder,
    (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
    Exercise,
    PrefetchHooks Function()>;
typedef $$WeekTemplateTableCreateCompanionBuilder = WeekTemplateCompanion
    Function({
  required int dayOfWeek,
  required int exerciseId,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$WeekTemplateTableUpdateCompanionBuilder = WeekTemplateCompanion
    Function({
  Value<int> dayOfWeek,
  Value<int> exerciseId,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$WeekTemplateTableFilterComposer
    extends Composer<_$AppDatabase, $WeekTemplateTable> {
  $$WeekTemplateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$WeekTemplateTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekTemplateTable> {
  $$WeekTemplateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$WeekTemplateTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekTemplateTable> {
  $$WeekTemplateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$WeekTemplateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeekTemplateTable,
    WeekTemplateData,
    $$WeekTemplateTableFilterComposer,
    $$WeekTemplateTableOrderingComposer,
    $$WeekTemplateTableAnnotationComposer,
    $$WeekTemplateTableCreateCompanionBuilder,
    $$WeekTemplateTableUpdateCompanionBuilder,
    (
      WeekTemplateData,
      BaseReferences<_$AppDatabase, $WeekTemplateTable, WeekTemplateData>
    ),
    WeekTemplateData,
    PrefetchHooks Function()> {
  $$WeekTemplateTableTableManager(_$AppDatabase db, $WeekTemplateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekTemplateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekTemplateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekTemplateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> exerciseId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekTemplateCompanion(
            dayOfWeek: dayOfWeek,
            exerciseId: exerciseId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int dayOfWeek,
            required int exerciseId,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekTemplateCompanion.insert(
            dayOfWeek: dayOfWeek,
            exerciseId: exerciseId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeekTemplateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeekTemplateTable,
    WeekTemplateData,
    $$WeekTemplateTableFilterComposer,
    $$WeekTemplateTableOrderingComposer,
    $$WeekTemplateTableAnnotationComposer,
    $$WeekTemplateTableCreateCompanionBuilder,
    $$WeekTemplateTableUpdateCompanionBuilder,
    (
      WeekTemplateData,
      BaseReferences<_$AppDatabase, $WeekTemplateTable, WeekTemplateData>
    ),
    WeekTemplateData,
    PrefetchHooks Function()>;
typedef $$TrainingRecordTableCreateCompanionBuilder = TrainingRecordCompanion
    Function({
  Value<int> id,
  required int exerciseId,
  required String exerciseName,
  required double weight,
  required DateTime trainedAt,
});
typedef $$TrainingRecordTableUpdateCompanionBuilder = TrainingRecordCompanion
    Function({
  Value<int> id,
  Value<int> exerciseId,
  Value<String> exerciseName,
  Value<double> weight,
  Value<DateTime> trainedAt,
});

class $$TrainingRecordTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingRecordTable> {
  $$TrainingRecordTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get trainedAt => $composableBuilder(
      column: $table.trainedAt, builder: (column) => ColumnFilters(column));
}

class $$TrainingRecordTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingRecordTable> {
  $$TrainingRecordTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get trainedAt => $composableBuilder(
      column: $table.trainedAt, builder: (column) => ColumnOrderings(column));
}

class $$TrainingRecordTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingRecordTable> {
  $$TrainingRecordTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get trainedAt =>
      $composableBuilder(column: $table.trainedAt, builder: (column) => column);
}

class $$TrainingRecordTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrainingRecordTable,
    TrainingRecordData,
    $$TrainingRecordTableFilterComposer,
    $$TrainingRecordTableOrderingComposer,
    $$TrainingRecordTableAnnotationComposer,
    $$TrainingRecordTableCreateCompanionBuilder,
    $$TrainingRecordTableUpdateCompanionBuilder,
    (
      TrainingRecordData,
      BaseReferences<_$AppDatabase, $TrainingRecordTable, TrainingRecordData>
    ),
    TrainingRecordData,
    PrefetchHooks Function()> {
  $$TrainingRecordTableTableManager(
      _$AppDatabase db, $TrainingRecordTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingRecordTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingRecordTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingRecordTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> exerciseId = const Value.absent(),
            Value<String> exerciseName = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<DateTime> trainedAt = const Value.absent(),
          }) =>
              TrainingRecordCompanion(
            id: id,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            weight: weight,
            trainedAt: trainedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int exerciseId,
            required String exerciseName,
            required double weight,
            required DateTime trainedAt,
          }) =>
              TrainingRecordCompanion.insert(
            id: id,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            weight: weight,
            trainedAt: trainedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrainingRecordTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrainingRecordTable,
    TrainingRecordData,
    $$TrainingRecordTableFilterComposer,
    $$TrainingRecordTableOrderingComposer,
    $$TrainingRecordTableAnnotationComposer,
    $$TrainingRecordTableCreateCompanionBuilder,
    $$TrainingRecordTableUpdateCompanionBuilder,
    (
      TrainingRecordData,
      BaseReferences<_$AppDatabase, $TrainingRecordTable, TrainingRecordData>
    ),
    TrainingRecordData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WeekTemplateTableTableManager get weekTemplate =>
      $$WeekTemplateTableTableManager(_db, _db.weekTemplate);
  $$TrainingRecordTableTableManager get trainingRecord =>
      $$TrainingRecordTableTableManager(_db, _db.trainingRecord);
}

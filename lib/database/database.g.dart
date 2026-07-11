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
  static const VerificationMeta _datasetIdMeta =
      const VerificationMeta('datasetId');
  @override
  late final GeneratedColumn<String> datasetId = GeneratedColumn<String>(
      'dataset_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, datasetId];
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
    if (data.containsKey('dataset_id')) {
      context.handle(_datasetIdMeta,
          datasetId.isAcceptableOrUnknown(data['dataset_id']!, _datasetIdMeta));
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
      datasetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dataset_id']),
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
  final String? datasetId;
  const Exercise({required this.id, required this.name, this.datasetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || datasetId != null) {
      map['dataset_id'] = Variable<String>(datasetId);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      datasetId: datasetId == null && nullToAbsent
          ? const Value.absent()
          : Value(datasetId),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      datasetId: serializer.fromJson<String?>(json['datasetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'datasetId': serializer.toJson<String?>(datasetId),
    };
  }

  Exercise copyWith(
          {int? id,
          String? name,
          Value<String?> datasetId = const Value.absent()}) =>
      Exercise(
        id: id ?? this.id,
        name: name ?? this.name,
        datasetId: datasetId.present ? datasetId.value : this.datasetId,
      );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      datasetId: data.datasetId.present ? data.datasetId.value : this.datasetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('datasetId: $datasetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, datasetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.datasetId == this.datasetId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> datasetId;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.datasetId = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.datasetId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? datasetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (datasetId != null) 'dataset_id': datasetId,
    });
  }

  ExercisesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String?>? datasetId}) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      datasetId: datasetId ?? this.datasetId,
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
    if (datasetId.present) {
      map['dataset_id'] = Variable<String>(datasetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('datasetId: $datasetId')
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

class $CatalogExercisesTable extends CatalogExercises
    with TableInfo<$CatalogExercisesTable, CatalogExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _datasetIdMeta =
      const VerificationMeta('datasetId');
  @override
  late final GeneratedColumn<String> datasetId = GeneratedColumn<String>(
      'dataset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameZhMeta = const VerificationMeta('nameZh');
  @override
  late final GeneratedColumn<String> nameZh = GeneratedColumn<String>(
      'name_zh', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyPartMeta =
      const VerificationMeta('bodyPart');
  @override
  late final GeneratedColumn<String> bodyPart = GeneratedColumn<String>(
      'body_part', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
      'equipment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
      'target', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _muscleGroupMeta =
      const VerificationMeta('muscleGroup');
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
      'muscle_group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _secondaryMusclesMeta =
      const VerificationMeta('secondaryMuscles');
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
      'secondary_muscles', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsZhMeta =
      const VerificationMeta('instructionsZh');
  @override
  late final GeneratedColumn<String> instructionsZh = GeneratedColumn<String>(
      'instructions_zh', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionStepsZhMeta =
      const VerificationMeta('instructionStepsZh');
  @override
  late final GeneratedColumn<String> instructionStepsZh =
      GeneratedColumn<String>('instruction_steps_zh', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gifAssetMeta =
      const VerificationMeta('gifAsset');
  @override
  late final GeneratedColumn<String> gifAsset = GeneratedColumn<String>(
      'gif_asset', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        datasetId,
        nameEn,
        nameZh,
        bodyPart,
        equipment,
        target,
        muscleGroup,
        secondaryMuscles,
        instructionsZh,
        instructionStepsZh,
        gifAsset
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<CatalogExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dataset_id')) {
      context.handle(_datasetIdMeta,
          datasetId.isAcceptableOrUnknown(data['dataset_id']!, _datasetIdMeta));
    } else if (isInserting) {
      context.missing(_datasetIdMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('name_zh')) {
      context.handle(_nameZhMeta,
          nameZh.isAcceptableOrUnknown(data['name_zh']!, _nameZhMeta));
    } else if (isInserting) {
      context.missing(_nameZhMeta);
    }
    if (data.containsKey('body_part')) {
      context.handle(_bodyPartMeta,
          bodyPart.isAcceptableOrUnknown(data['body_part']!, _bodyPartMeta));
    } else if (isInserting) {
      context.missing(_bodyPartMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(_equipmentMeta,
          equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta));
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('target')) {
      context.handle(_targetMeta,
          target.isAcceptableOrUnknown(data['target']!, _targetMeta));
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
          _muscleGroupMeta,
          muscleGroup.isAcceptableOrUnknown(
              data['muscle_group']!, _muscleGroupMeta));
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
          _secondaryMusclesMeta,
          secondaryMuscles.isAcceptableOrUnknown(
              data['secondary_muscles']!, _secondaryMusclesMeta));
    } else if (isInserting) {
      context.missing(_secondaryMusclesMeta);
    }
    if (data.containsKey('instructions_zh')) {
      context.handle(
          _instructionsZhMeta,
          instructionsZh.isAcceptableOrUnknown(
              data['instructions_zh']!, _instructionsZhMeta));
    } else if (isInserting) {
      context.missing(_instructionsZhMeta);
    }
    if (data.containsKey('instruction_steps_zh')) {
      context.handle(
          _instructionStepsZhMeta,
          instructionStepsZh.isAcceptableOrUnknown(
              data['instruction_steps_zh']!, _instructionStepsZhMeta));
    } else if (isInserting) {
      context.missing(_instructionStepsZhMeta);
    }
    if (data.containsKey('gif_asset')) {
      context.handle(_gifAssetMeta,
          gifAsset.isAcceptableOrUnknown(data['gif_asset']!, _gifAssetMeta));
    } else if (isInserting) {
      context.missing(_gifAssetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {datasetId};
  @override
  CatalogExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogExercise(
      datasetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dataset_id'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      nameZh: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_zh'])!,
      bodyPart: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_part'])!,
      equipment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}equipment'])!,
      target: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target'])!,
      muscleGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}muscle_group'])!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}secondary_muscles'])!,
      instructionsZh: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}instructions_zh'])!,
      instructionStepsZh: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}instruction_steps_zh'])!,
      gifAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gif_asset'])!,
    );
  }

  @override
  $CatalogExercisesTable createAlias(String alias) {
    return $CatalogExercisesTable(attachedDatabase, alias);
  }
}

class CatalogExercise extends DataClass implements Insertable<CatalogExercise> {
  final String datasetId;
  final String nameEn;
  final String nameZh;
  final String bodyPart;
  final String equipment;
  final String target;
  final String muscleGroup;
  final String secondaryMuscles;
  final String instructionsZh;
  final String instructionStepsZh;
  final String gifAsset;
  const CatalogExercise(
      {required this.datasetId,
      required this.nameEn,
      required this.nameZh,
      required this.bodyPart,
      required this.equipment,
      required this.target,
      required this.muscleGroup,
      required this.secondaryMuscles,
      required this.instructionsZh,
      required this.instructionStepsZh,
      required this.gifAsset});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dataset_id'] = Variable<String>(datasetId);
    map['name_en'] = Variable<String>(nameEn);
    map['name_zh'] = Variable<String>(nameZh);
    map['body_part'] = Variable<String>(bodyPart);
    map['equipment'] = Variable<String>(equipment);
    map['target'] = Variable<String>(target);
    map['muscle_group'] = Variable<String>(muscleGroup);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    map['instructions_zh'] = Variable<String>(instructionsZh);
    map['instruction_steps_zh'] = Variable<String>(instructionStepsZh);
    map['gif_asset'] = Variable<String>(gifAsset);
    return map;
  }

  CatalogExercisesCompanion toCompanion(bool nullToAbsent) {
    return CatalogExercisesCompanion(
      datasetId: Value(datasetId),
      nameEn: Value(nameEn),
      nameZh: Value(nameZh),
      bodyPart: Value(bodyPart),
      equipment: Value(equipment),
      target: Value(target),
      muscleGroup: Value(muscleGroup),
      secondaryMuscles: Value(secondaryMuscles),
      instructionsZh: Value(instructionsZh),
      instructionStepsZh: Value(instructionStepsZh),
      gifAsset: Value(gifAsset),
    );
  }

  factory CatalogExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogExercise(
      datasetId: serializer.fromJson<String>(json['datasetId']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      nameZh: serializer.fromJson<String>(json['nameZh']),
      bodyPart: serializer.fromJson<String>(json['bodyPart']),
      equipment: serializer.fromJson<String>(json['equipment']),
      target: serializer.fromJson<String>(json['target']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      instructionsZh: serializer.fromJson<String>(json['instructionsZh']),
      instructionStepsZh:
          serializer.fromJson<String>(json['instructionStepsZh']),
      gifAsset: serializer.fromJson<String>(json['gifAsset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'datasetId': serializer.toJson<String>(datasetId),
      'nameEn': serializer.toJson<String>(nameEn),
      'nameZh': serializer.toJson<String>(nameZh),
      'bodyPart': serializer.toJson<String>(bodyPart),
      'equipment': serializer.toJson<String>(equipment),
      'target': serializer.toJson<String>(target),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'instructionsZh': serializer.toJson<String>(instructionsZh),
      'instructionStepsZh': serializer.toJson<String>(instructionStepsZh),
      'gifAsset': serializer.toJson<String>(gifAsset),
    };
  }

  CatalogExercise copyWith(
          {String? datasetId,
          String? nameEn,
          String? nameZh,
          String? bodyPart,
          String? equipment,
          String? target,
          String? muscleGroup,
          String? secondaryMuscles,
          String? instructionsZh,
          String? instructionStepsZh,
          String? gifAsset}) =>
      CatalogExercise(
        datasetId: datasetId ?? this.datasetId,
        nameEn: nameEn ?? this.nameEn,
        nameZh: nameZh ?? this.nameZh,
        bodyPart: bodyPart ?? this.bodyPart,
        equipment: equipment ?? this.equipment,
        target: target ?? this.target,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
        instructionsZh: instructionsZh ?? this.instructionsZh,
        instructionStepsZh: instructionStepsZh ?? this.instructionStepsZh,
        gifAsset: gifAsset ?? this.gifAsset,
      );
  CatalogExercise copyWithCompanion(CatalogExercisesCompanion data) {
    return CatalogExercise(
      datasetId: data.datasetId.present ? data.datasetId.value : this.datasetId,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      nameZh: data.nameZh.present ? data.nameZh.value : this.nameZh,
      bodyPart: data.bodyPart.present ? data.bodyPart.value : this.bodyPart,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      target: data.target.present ? data.target.value : this.target,
      muscleGroup:
          data.muscleGroup.present ? data.muscleGroup.value : this.muscleGroup,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      instructionsZh: data.instructionsZh.present
          ? data.instructionsZh.value
          : this.instructionsZh,
      instructionStepsZh: data.instructionStepsZh.present
          ? data.instructionStepsZh.value
          : this.instructionStepsZh,
      gifAsset: data.gifAsset.present ? data.gifAsset.value : this.gifAsset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogExercise(')
          ..write('datasetId: $datasetId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameZh: $nameZh, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('equipment: $equipment, ')
          ..write('target: $target, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructionsZh: $instructionsZh, ')
          ..write('instructionStepsZh: $instructionStepsZh, ')
          ..write('gifAsset: $gifAsset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      datasetId,
      nameEn,
      nameZh,
      bodyPart,
      equipment,
      target,
      muscleGroup,
      secondaryMuscles,
      instructionsZh,
      instructionStepsZh,
      gifAsset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogExercise &&
          other.datasetId == this.datasetId &&
          other.nameEn == this.nameEn &&
          other.nameZh == this.nameZh &&
          other.bodyPart == this.bodyPart &&
          other.equipment == this.equipment &&
          other.target == this.target &&
          other.muscleGroup == this.muscleGroup &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.instructionsZh == this.instructionsZh &&
          other.instructionStepsZh == this.instructionStepsZh &&
          other.gifAsset == this.gifAsset);
}

class CatalogExercisesCompanion extends UpdateCompanion<CatalogExercise> {
  final Value<String> datasetId;
  final Value<String> nameEn;
  final Value<String> nameZh;
  final Value<String> bodyPart;
  final Value<String> equipment;
  final Value<String> target;
  final Value<String> muscleGroup;
  final Value<String> secondaryMuscles;
  final Value<String> instructionsZh;
  final Value<String> instructionStepsZh;
  final Value<String> gifAsset;
  final Value<int> rowid;
  const CatalogExercisesCompanion({
    this.datasetId = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.nameZh = const Value.absent(),
    this.bodyPart = const Value.absent(),
    this.equipment = const Value.absent(),
    this.target = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.instructionsZh = const Value.absent(),
    this.instructionStepsZh = const Value.absent(),
    this.gifAsset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogExercisesCompanion.insert({
    required String datasetId,
    required String nameEn,
    required String nameZh,
    required String bodyPart,
    required String equipment,
    required String target,
    required String muscleGroup,
    required String secondaryMuscles,
    required String instructionsZh,
    required String instructionStepsZh,
    required String gifAsset,
    this.rowid = const Value.absent(),
  })  : datasetId = Value(datasetId),
        nameEn = Value(nameEn),
        nameZh = Value(nameZh),
        bodyPart = Value(bodyPart),
        equipment = Value(equipment),
        target = Value(target),
        muscleGroup = Value(muscleGroup),
        secondaryMuscles = Value(secondaryMuscles),
        instructionsZh = Value(instructionsZh),
        instructionStepsZh = Value(instructionStepsZh),
        gifAsset = Value(gifAsset);
  static Insertable<CatalogExercise> custom({
    Expression<String>? datasetId,
    Expression<String>? nameEn,
    Expression<String>? nameZh,
    Expression<String>? bodyPart,
    Expression<String>? equipment,
    Expression<String>? target,
    Expression<String>? muscleGroup,
    Expression<String>? secondaryMuscles,
    Expression<String>? instructionsZh,
    Expression<String>? instructionStepsZh,
    Expression<String>? gifAsset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (datasetId != null) 'dataset_id': datasetId,
      if (nameEn != null) 'name_en': nameEn,
      if (nameZh != null) 'name_zh': nameZh,
      if (bodyPart != null) 'body_part': bodyPart,
      if (equipment != null) 'equipment': equipment,
      if (target != null) 'target': target,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (instructionsZh != null) 'instructions_zh': instructionsZh,
      if (instructionStepsZh != null)
        'instruction_steps_zh': instructionStepsZh,
      if (gifAsset != null) 'gif_asset': gifAsset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogExercisesCompanion copyWith(
      {Value<String>? datasetId,
      Value<String>? nameEn,
      Value<String>? nameZh,
      Value<String>? bodyPart,
      Value<String>? equipment,
      Value<String>? target,
      Value<String>? muscleGroup,
      Value<String>? secondaryMuscles,
      Value<String>? instructionsZh,
      Value<String>? instructionStepsZh,
      Value<String>? gifAsset,
      Value<int>? rowid}) {
    return CatalogExercisesCompanion(
      datasetId: datasetId ?? this.datasetId,
      nameEn: nameEn ?? this.nameEn,
      nameZh: nameZh ?? this.nameZh,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      target: target ?? this.target,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      instructionsZh: instructionsZh ?? this.instructionsZh,
      instructionStepsZh: instructionStepsZh ?? this.instructionStepsZh,
      gifAsset: gifAsset ?? this.gifAsset,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (datasetId.present) {
      map['dataset_id'] = Variable<String>(datasetId.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (nameZh.present) {
      map['name_zh'] = Variable<String>(nameZh.value);
    }
    if (bodyPart.present) {
      map['body_part'] = Variable<String>(bodyPart.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (instructionsZh.present) {
      map['instructions_zh'] = Variable<String>(instructionsZh.value);
    }
    if (instructionStepsZh.present) {
      map['instruction_steps_zh'] = Variable<String>(instructionStepsZh.value);
    }
    if (gifAsset.present) {
      map['gif_asset'] = Variable<String>(gifAsset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogExercisesCompanion(')
          ..write('datasetId: $datasetId, ')
          ..write('nameEn: $nameEn, ')
          ..write('nameZh: $nameZh, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('equipment: $equipment, ')
          ..write('target: $target, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('instructionsZh: $instructionsZh, ')
          ..write('instructionStepsZh: $instructionStepsZh, ')
          ..write('gifAsset: $gifAsset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) => AppMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
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
  late final $CatalogExercisesTable catalogExercises =
      $CatalogExercisesTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [exercises, weekTemplate, trainingRecord, catalogExercises, appMeta];
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> datasetId,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> datasetId,
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

  ColumnFilters<String> get datasetId => $composableBuilder(
      column: $table.datasetId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get datasetId => $composableBuilder(
      column: $table.datasetId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get datasetId =>
      $composableBuilder(column: $table.datasetId, builder: (column) => column);
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
            Value<String?> datasetId = const Value.absent(),
          }) =>
              ExercisesCompanion(
            id: id,
            name: name,
            datasetId: datasetId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> datasetId = const Value.absent(),
          }) =>
              ExercisesCompanion.insert(
            id: id,
            name: name,
            datasetId: datasetId,
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
typedef $$CatalogExercisesTableCreateCompanionBuilder
    = CatalogExercisesCompanion Function({
  required String datasetId,
  required String nameEn,
  required String nameZh,
  required String bodyPart,
  required String equipment,
  required String target,
  required String muscleGroup,
  required String secondaryMuscles,
  required String instructionsZh,
  required String instructionStepsZh,
  required String gifAsset,
  Value<int> rowid,
});
typedef $$CatalogExercisesTableUpdateCompanionBuilder
    = CatalogExercisesCompanion Function({
  Value<String> datasetId,
  Value<String> nameEn,
  Value<String> nameZh,
  Value<String> bodyPart,
  Value<String> equipment,
  Value<String> target,
  Value<String> muscleGroup,
  Value<String> secondaryMuscles,
  Value<String> instructionsZh,
  Value<String> instructionStepsZh,
  Value<String> gifAsset,
  Value<int> rowid,
});

class $$CatalogExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get datasetId => $composableBuilder(
      column: $table.datasetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameZh => $composableBuilder(
      column: $table.nameZh, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyPart => $composableBuilder(
      column: $table.bodyPart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get muscleGroup => $composableBuilder(
      column: $table.muscleGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
      column: $table.secondaryMuscles,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionsZh => $composableBuilder(
      column: $table.instructionsZh,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionStepsZh => $composableBuilder(
      column: $table.instructionStepsZh,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gifAsset => $composableBuilder(
      column: $table.gifAsset, builder: (column) => ColumnFilters(column));
}

class $$CatalogExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get datasetId => $composableBuilder(
      column: $table.datasetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameZh => $composableBuilder(
      column: $table.nameZh, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyPart => $composableBuilder(
      column: $table.bodyPart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get equipment => $composableBuilder(
      column: $table.equipment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
      column: $table.muscleGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
      column: $table.secondaryMuscles,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionsZh => $composableBuilder(
      column: $table.instructionsZh,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionStepsZh => $composableBuilder(
      column: $table.instructionStepsZh,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gifAsset => $composableBuilder(
      column: $table.gifAsset, builder: (column) => ColumnOrderings(column));
}

class $$CatalogExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogExercisesTable> {
  $$CatalogExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get datasetId =>
      $composableBuilder(column: $table.datasetId, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get nameZh =>
      $composableBuilder(column: $table.nameZh, builder: (column) => column);

  GeneratedColumn<String> get bodyPart =>
      $composableBuilder(column: $table.bodyPart, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
      column: $table.muscleGroup, builder: (column) => column);

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
      column: $table.secondaryMuscles, builder: (column) => column);

  GeneratedColumn<String> get instructionsZh => $composableBuilder(
      column: $table.instructionsZh, builder: (column) => column);

  GeneratedColumn<String> get instructionStepsZh => $composableBuilder(
      column: $table.instructionStepsZh, builder: (column) => column);

  GeneratedColumn<String> get gifAsset =>
      $composableBuilder(column: $table.gifAsset, builder: (column) => column);
}

class $$CatalogExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CatalogExercisesTable,
    CatalogExercise,
    $$CatalogExercisesTableFilterComposer,
    $$CatalogExercisesTableOrderingComposer,
    $$CatalogExercisesTableAnnotationComposer,
    $$CatalogExercisesTableCreateCompanionBuilder,
    $$CatalogExercisesTableUpdateCompanionBuilder,
    (
      CatalogExercise,
      BaseReferences<_$AppDatabase, $CatalogExercisesTable, CatalogExercise>
    ),
    CatalogExercise,
    PrefetchHooks Function()> {
  $$CatalogExercisesTableTableManager(
      _$AppDatabase db, $CatalogExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> datasetId = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> nameZh = const Value.absent(),
            Value<String> bodyPart = const Value.absent(),
            Value<String> equipment = const Value.absent(),
            Value<String> target = const Value.absent(),
            Value<String> muscleGroup = const Value.absent(),
            Value<String> secondaryMuscles = const Value.absent(),
            Value<String> instructionsZh = const Value.absent(),
            Value<String> instructionStepsZh = const Value.absent(),
            Value<String> gifAsset = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogExercisesCompanion(
            datasetId: datasetId,
            nameEn: nameEn,
            nameZh: nameZh,
            bodyPart: bodyPart,
            equipment: equipment,
            target: target,
            muscleGroup: muscleGroup,
            secondaryMuscles: secondaryMuscles,
            instructionsZh: instructionsZh,
            instructionStepsZh: instructionStepsZh,
            gifAsset: gifAsset,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String datasetId,
            required String nameEn,
            required String nameZh,
            required String bodyPart,
            required String equipment,
            required String target,
            required String muscleGroup,
            required String secondaryMuscles,
            required String instructionsZh,
            required String instructionStepsZh,
            required String gifAsset,
            Value<int> rowid = const Value.absent(),
          }) =>
              CatalogExercisesCompanion.insert(
            datasetId: datasetId,
            nameEn: nameEn,
            nameZh: nameZh,
            bodyPart: bodyPart,
            equipment: equipment,
            target: target,
            muscleGroup: muscleGroup,
            secondaryMuscles: secondaryMuscles,
            instructionsZh: instructionsZh,
            instructionStepsZh: instructionStepsZh,
            gifAsset: gifAsset,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CatalogExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CatalogExercisesTable,
    CatalogExercise,
    $$CatalogExercisesTableFilterComposer,
    $$CatalogExercisesTableOrderingComposer,
    $$CatalogExercisesTableAnnotationComposer,
    $$CatalogExercisesTableCreateCompanionBuilder,
    $$CatalogExercisesTableUpdateCompanionBuilder,
    (
      CatalogExercise,
      BaseReferences<_$AppDatabase, $CatalogExercisesTable, CatalogExercise>
    ),
    CatalogExercise,
    PrefetchHooks Function()>;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaData,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
    AppMetaData,
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
  $$CatalogExercisesTableTableManager get catalogExercises =>
      $$CatalogExercisesTableTableManager(_db, _db.catalogExercises);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}

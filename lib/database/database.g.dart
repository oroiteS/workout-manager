// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _exerciseNameMeta =
      const VerificationMeta('exerciseName');
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
      'exercise_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [dayOfWeek, exerciseName, sortOrder];
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
    if (data.containsKey('exercise_name')) {
      context.handle(
          _exerciseNameMeta,
          exerciseName.isAcceptableOrUnknown(
              data['exercise_name']!, _exerciseNameMeta));
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dayOfWeek, exerciseName};
  @override
  WeekTemplateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekTemplateData(
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      exerciseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_name'])!,
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
  final String exerciseName;
  final int sortOrder;
  const WeekTemplateData(
      {required this.dayOfWeek,
      required this.exerciseName,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WeekTemplateCompanion toCompanion(bool nullToAbsent) {
    return WeekTemplateCompanion(
      dayOfWeek: Value(dayOfWeek),
      exerciseName: Value(exerciseName),
      sortOrder: Value(sortOrder),
    );
  }

  factory WeekTemplateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekTemplateData(
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WeekTemplateData copyWith(
          {int? dayOfWeek, String? exerciseName, int? sortOrder}) =>
      WeekTemplateData(
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        exerciseName: exerciseName ?? this.exerciseName,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WeekTemplateData copyWithCompanion(WeekTemplateCompanion data) {
    return WeekTemplateData(
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekTemplateData(')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dayOfWeek, exerciseName, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekTemplateData &&
          other.dayOfWeek == this.dayOfWeek &&
          other.exerciseName == this.exerciseName &&
          other.sortOrder == this.sortOrder);
}

class WeekTemplateCompanion extends UpdateCompanion<WeekTemplateData> {
  final Value<int> dayOfWeek;
  final Value<String> exerciseName;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WeekTemplateCompanion({
    this.dayOfWeek = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekTemplateCompanion.insert({
    required int dayOfWeek,
    required String exerciseName,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : dayOfWeek = Value(dayOfWeek),
        exerciseName = Value(exerciseName);
  static Insertable<WeekTemplateData> custom({
    Expression<int>? dayOfWeek,
    Expression<String>? exerciseName,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekTemplateCompanion copyWith(
      {Value<int>? dayOfWeek,
      Value<String>? exerciseName,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return WeekTemplateCompanion(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      exerciseName: exerciseName ?? this.exerciseName,
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
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
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
          ..write('exerciseName: $exerciseName, ')
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
  List<GeneratedColumn> get $columns => [id, exerciseName, weight, trainedAt];
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
  final String exerciseName;
  final double weight;
  final DateTime trainedAt;
  const TrainingRecordData(
      {required this.id,
      required this.exerciseName,
      required this.weight,
      required this.trainedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['weight'] = Variable<double>(weight);
    map['trained_at'] = Variable<DateTime>(trainedAt);
    return map;
  }

  TrainingRecordCompanion toCompanion(bool nullToAbsent) {
    return TrainingRecordCompanion(
      id: Value(id),
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
      'exerciseName': serializer.toJson<String>(exerciseName),
      'weight': serializer.toJson<double>(weight),
      'trainedAt': serializer.toJson<DateTime>(trainedAt),
    };
  }

  TrainingRecordData copyWith(
          {int? id,
          String? exerciseName,
          double? weight,
          DateTime? trainedAt}) =>
      TrainingRecordData(
        id: id ?? this.id,
        exerciseName: exerciseName ?? this.exerciseName,
        weight: weight ?? this.weight,
        trainedAt: trainedAt ?? this.trainedAt,
      );
  TrainingRecordData copyWithCompanion(TrainingRecordCompanion data) {
    return TrainingRecordData(
      id: data.id.present ? data.id.value : this.id,
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
          ..write('exerciseName: $exerciseName, ')
          ..write('weight: $weight, ')
          ..write('trainedAt: $trainedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exerciseName, weight, trainedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingRecordData &&
          other.id == this.id &&
          other.exerciseName == this.exerciseName &&
          other.weight == this.weight &&
          other.trainedAt == this.trainedAt);
}

class TrainingRecordCompanion extends UpdateCompanion<TrainingRecordData> {
  final Value<int> id;
  final Value<String> exerciseName;
  final Value<double> weight;
  final Value<DateTime> trainedAt;
  const TrainingRecordCompanion({
    this.id = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.weight = const Value.absent(),
    this.trainedAt = const Value.absent(),
  });
  TrainingRecordCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseName,
    required double weight,
    required DateTime trainedAt,
  })  : exerciseName = Value(exerciseName),
        weight = Value(weight),
        trainedAt = Value(trainedAt);
  static Insertable<TrainingRecordData> custom({
    Expression<int>? id,
    Expression<String>? exerciseName,
    Expression<double>? weight,
    Expression<DateTime>? trainedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (weight != null) 'weight': weight,
      if (trainedAt != null) 'trained_at': trainedAt,
    });
  }

  TrainingRecordCompanion copyWith(
      {Value<int>? id,
      Value<String>? exerciseName,
      Value<double>? weight,
      Value<DateTime>? trainedAt}) {
    return TrainingRecordCompanion(
      id: id ?? this.id,
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
  late final $WeekTemplateTable weekTemplate = $WeekTemplateTable(this);
  late final $TrainingRecordTable trainingRecord = $TrainingRecordTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [weekTemplate, trainingRecord];
}

typedef $$WeekTemplateTableCreateCompanionBuilder = WeekTemplateCompanion
    Function({
  required int dayOfWeek,
  required String exerciseName,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$WeekTemplateTableUpdateCompanionBuilder = WeekTemplateCompanion
    Function({
  Value<int> dayOfWeek,
  Value<String> exerciseName,
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

  ColumnFilters<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get exerciseName => $composableBuilder(
      column: $table.exerciseName, builder: (column) => column);

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
            Value<String> exerciseName = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekTemplateCompanion(
            dayOfWeek: dayOfWeek,
            exerciseName: exerciseName,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int dayOfWeek,
            required String exerciseName,
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekTemplateCompanion.insert(
            dayOfWeek: dayOfWeek,
            exerciseName: exerciseName,
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
  required String exerciseName,
  required double weight,
  required DateTime trainedAt,
});
typedef $$TrainingRecordTableUpdateCompanionBuilder = TrainingRecordCompanion
    Function({
  Value<int> id,
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
            Value<String> exerciseName = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<DateTime> trainedAt = const Value.absent(),
          }) =>
              TrainingRecordCompanion(
            id: id,
            exerciseName: exerciseName,
            weight: weight,
            trainedAt: trainedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String exerciseName,
            required double weight,
            required DateTime trainedAt,
          }) =>
              TrainingRecordCompanion.insert(
            id: id,
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
  $$WeekTemplateTableTableManager get weekTemplate =>
      $$WeekTemplateTableTableManager(_db, _db.weekTemplate);
  $$TrainingRecordTableTableManager get trainingRecord =>
      $$TrainingRecordTableTableManager(_db, _db.trainingRecord);
}

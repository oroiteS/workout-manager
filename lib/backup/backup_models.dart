import 'package:drift/drift.dart';
import 'package:workout_manager/database/database.dart';

class BackupExercise {
  final int id;
  final String name;
  final String? datasetId;

  BackupExercise({required this.id, required this.name, this.datasetId});

  factory BackupExercise.fromJson(Map<String, dynamic> json) => BackupExercise(
        id: json['id'] as int,
        name: json['name'] as String,
        datasetId: json['datasetId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'datasetId': datasetId,
      };

  ExercisesCompanion toCompanion() => ExercisesCompanion(
        id: Value(id),
        name: Value(name),
        datasetId: Value(datasetId),
      );
}

class WeekTemplateRowData {
  final int dayOfWeek;
  final int exerciseId;
  final int sortOrder;

  WeekTemplateRowData({
    required this.dayOfWeek,
    required this.exerciseId,
    required this.sortOrder,
  });

  factory WeekTemplateRowData.fromJson(Map<String, dynamic> json) =>
      WeekTemplateRowData(
        dayOfWeek: json['dayOfWeek'] as int,
        exerciseId: json['exerciseId'] as int,
        sortOrder: json['sortOrder'] as int,
      );

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'exerciseId': exerciseId,
        'sortOrder': sortOrder,
      };

  WeekTemplateCompanion toCompanion() => WeekTemplateCompanion(
        dayOfWeek: Value(dayOfWeek),
        exerciseId: Value(exerciseId),
        sortOrder: Value(sortOrder),
      );
}

class TrainingRecordRowData {
  final int exerciseId;
  final String exerciseName;
  final double weight;
  final String trainedAt;

  TrainingRecordRowData({
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.trainedAt,
  });

  factory TrainingRecordRowData.fromJson(Map<String, dynamic> json) =>
      TrainingRecordRowData(
        exerciseId: json['exerciseId'] as int,
        exerciseName: json['exerciseName'] as String,
        weight: (json['weight'] as num).toDouble(),
        trainedAt: json['trainedAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'weight': weight,
        'trainedAt': trainedAt,
      };
}

class CycleTemplateRowData {
  final int dayIndex;
  final int exerciseId;
  final int sortOrder;

  CycleTemplateRowData({
    required this.dayIndex,
    required this.exerciseId,
    required this.sortOrder,
  });

  factory CycleTemplateRowData.fromJson(Map<String, dynamic> json) =>
      CycleTemplateRowData(
        dayIndex: json['dayIndex'] as int,
        exerciseId: json['exerciseId'] as int,
        sortOrder: json['sortOrder'] as int,
      );

  Map<String, dynamic> toJson() => {
        'dayIndex': dayIndex,
        'exerciseId': exerciseId,
        'sortOrder': sortOrder,
      };

  CycleTemplateCompanion toCompanion() => CycleTemplateCompanion(
        dayIndex: Value(dayIndex),
        exerciseId: Value(exerciseId),
        sortOrder: Value(sortOrder),
      );
}

class CycleSelectionRowData {
  final String date;
  final String kind;
  final int? dayIndex;

  CycleSelectionRowData({
    required this.date,
    required this.kind,
    this.dayIndex,
  });

  factory CycleSelectionRowData.fromJson(Map<String, dynamic> json) =>
      CycleSelectionRowData(
        date: json['date'] as String,
        kind: json['kind'] as String,
        dayIndex: json['dayIndex'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'kind': kind,
        'dayIndex': dayIndex,
      };
}

class CycleSettingsData {
  final String planMode;
  final int? dayCount;

  CycleSettingsData({required this.planMode, this.dayCount});

  factory CycleSettingsData.fromJson(Map<String, dynamic> json) =>
      CycleSettingsData(
        planMode: json['planMode'] as String,
        dayCount: json['dayCount'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'planMode': planMode,
        'dayCount': dayCount,
      };
}

class BackupData {
  final List<BackupExercise> exercises;
  final List<WeekTemplateRowData> weekTemplate;
  final List<TrainingRecordRowData> trainingRecords;
  final List<CycleTemplateRowData> cycleTemplate;
  final List<CycleSelectionRowData> cycleSelections;
  final CycleSettingsData? cycleSettings;

  const BackupData({
    required this.exercises,
    required this.weekTemplate,
    required this.trainingRecords,
    this.cycleTemplate = const [],
    this.cycleSelections = const [],
    this.cycleSettings,
  });

  factory BackupData.fromJson(Map<String, dynamic> json) => BackupData(
        exercises: (json['exercises'] as List)
            .map((e) => BackupExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        weekTemplate: (json['weekTemplate'] as List)
            .map((e) => WeekTemplateRowData.fromJson(e as Map<String, dynamic>))
            .toList(),
        trainingRecords: (json['trainingRecords'] as List)
            .map(
              (e) => TrainingRecordRowData.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        cycleTemplate: (json['cycleTemplate'] as List? ?? const [])
            .map(
              (e) => CycleTemplateRowData.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        cycleSelections: (json['cycleSelections'] as List? ?? const [])
            .map(
              (e) =>
                  CycleSelectionRowData.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        cycleSettings: json['cycleSettings'] == null
            ? null
            : CycleSettingsData.fromJson(
                json['cycleSettings'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => {
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'weekTemplate': weekTemplate.map((e) => e.toJson()).toList(),
        'trainingRecords': trainingRecords.map((e) => e.toJson()).toList(),
        'cycleTemplate': cycleTemplate.map((e) => e.toJson()).toList(),
        'cycleSelections': cycleSelections.map((e) => e.toJson()).toList(),
        'cycleSettings': cycleSettings?.toJson(),
      };
}

class BackupFile {
  static const String format = 'workout-manager-backup';

  /// v1：无循环数据；v2：含 cycleTemplate/cycleSelections/cycleSettings。
  static const int version = 2;
  static const int minVersion = 1;

  final String exportedAt;
  final String appVersion;
  final BackupData data;

  BackupFile({
    required this.exportedAt,
    required this.appVersion,
    required this.data,
  });

  factory BackupFile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return BackupFile(
      exportedAt: json['exportedAt'] as String,
      appVersion: json['appVersion'] as String,
      data: BackupData.fromJson(data),
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format,
        'version': version,
        'exportedAt': exportedAt,
        'appVersion': appVersion,
        'data': data.toJson(),
      };
}

class BackupParseException implements Exception {
  final String message;
  BackupParseException(this.message);

  @override
  String toString() => 'BackupParseException: $message';
}

BackupFile validateBackup(Map<String, dynamic> json) {
  if (json['format'] != BackupFile.format) {
    throw BackupParseException('不支持的备份格式');
  }
  final version = json['version'];
  if (version is! int ||
      version < BackupFile.minVersion ||
      version > BackupFile.version) {
    throw BackupParseException('不支持的备份版本: $version');
  }
  final data = json['data'];
  if (data is! Map<String, dynamic>) {
    throw BackupParseException('data 字段缺失或格式错误');
  }
  final exercises = data['exercises'];
  final weekTemplate = data['weekTemplate'];
  final trainingRecords = data['trainingRecords'];
  if (exercises is! List ||
      weekTemplate is! List ||
      trainingRecords is! List) {
    throw BackupParseException('备份文件结构不完整');
  }
  final cycleTemplate = data['cycleTemplate'];
  final cycleSelections = data['cycleSelections'];
  final cycleSettings = data['cycleSettings'];
  if ((cycleTemplate != null && cycleTemplate is! List) ||
      (cycleSelections != null && cycleSelections is! List) ||
      (cycleSettings != null && cycleSettings is! Map<String, dynamic>)) {
    throw BackupParseException('循环数据格式错误');
  }

  final exerciseIds = <int>{};
  for (final e in exercises) {
    if (e is! Map<String, dynamic>) {
      throw BackupParseException('exercises 元素格式错误');
    }
    final id = e['id'];
    final name = e['name'];
    if (id is! int || name is! String) {
      throw BackupParseException('exercises 缺少 id 或 name');
    }
    exerciseIds.add(id);
  }
  for (final row in weekTemplate) {
    if (row is! Map<String, dynamic>) {
      throw BackupParseException('weekTemplate 元素格式错误');
    }
    final dayOfWeek = row['dayOfWeek'];
    final exerciseId = row['exerciseId'];
    final sortOrder = row['sortOrder'];
    if (dayOfWeek is! int || exerciseId is! int || sortOrder is! int) {
      throw BackupParseException('weekTemplate 字段类型错误');
    }
    if (!exerciseIds.contains(exerciseId)) {
      throw BackupParseException(
        'weekTemplate 引用了不存在的 exerciseId: $exerciseId',
      );
    }
  }
  for (final row in trainingRecords) {
    if (row is! Map<String, dynamic>) {
      throw BackupParseException('trainingRecords 元素格式错误');
    }
    final exerciseId = row['exerciseId'];
    final exerciseName = row['exerciseName'];
    final weight = row['weight'];
    final trainedAt = row['trainedAt'];
    if (exerciseId is! int ||
        exerciseName is! String ||
        weight is! num ||
        trainedAt is! String) {
      throw BackupParseException('trainingRecords 字段类型错误');
    }
    if (DateTime.tryParse(trainedAt) == null) {
      throw BackupParseException('trainingRecords trainedAt 无法解析: $trainedAt');
    }
    if (!exerciseIds.contains(exerciseId)) {
      throw BackupParseException(
        'trainingRecords 引用了不存在的 exerciseId: $exerciseId',
      );
    }
  }

  const validKinds = {'day', 'cardio', 'rest'};
  final cycleTemplateList = (cycleTemplate as List? ?? const []);
  final cycleSelectionsList = (cycleSelections as List? ?? const []);
  int? cycleDayCount;
  if (cycleSettings != null) {
    final planMode = cycleSettings['planMode'];
    final dayCount = cycleSettings['dayCount'];
    if (planMode is! String || (planMode != 'weekly' && planMode != 'cycle')) {
      throw BackupParseException('cycleSettings planMode 非法: $planMode');
    }
    if (dayCount is! int || dayCount < 1 || dayCount > CycleDao.maxDayCount) {
      throw BackupParseException('cycleSettings dayCount 非法: $dayCount');
    }
    cycleDayCount = dayCount;
  } else if (cycleTemplateList.isNotEmpty || cycleSelectionsList.isNotEmpty) {
    throw BackupParseException('存在循环数据但缺少 cycleSettings');
  }
  final seenPairs = <String>{};
  for (final row in cycleTemplateList) {
    if (row is! Map<String, dynamic>) {
      throw BackupParseException('cycleTemplate 元素格式错误');
    }
    final dayIndex = row['dayIndex'];
    final exerciseId = row['exerciseId'];
    final sortOrder = row['sortOrder'];
    if (dayIndex is! int || exerciseId is! int || sortOrder is! int) {
      throw BackupParseException('cycleTemplate 字段类型错误');
    }
    if (dayIndex < 1) {
      throw BackupParseException('cycleTemplate dayIndex 非法: $dayIndex');
    }
    if (cycleDayCount != null && dayIndex > cycleDayCount) {
      throw BackupParseException(
        'cycleTemplate dayIndex $dayIndex 超出循环天数 $cycleDayCount',
      );
    }
    if (!exerciseIds.contains(exerciseId)) {
      throw BackupParseException(
        'cycleTemplate 引用了不存在的 exerciseId: $exerciseId',
      );
    }
    if (!seenPairs.add('$dayIndex:$exerciseId')) {
      throw BackupParseException(
        'cycleTemplate 存在重复条目: 第 $dayIndex 天 / exerciseId $exerciseId',
      );
    }
  }
  final seenDates = <String>{};
  for (final row in cycleSelectionsList) {
    if (row is! Map<String, dynamic>) {
      throw BackupParseException('cycleSelections 元素格式错误');
    }
    final date = row['date'];
    final kind = row['kind'];
    final dayIndex = row['dayIndex'];
    if (date is! String || kind is! String || dayIndex is! int?) {
      throw BackupParseException('cycleSelections 字段类型错误');
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw BackupParseException('cycleSelections date 格式错误: $date');
    }
    if (!validKinds.contains(kind)) {
      throw BackupParseException('cycleSelections kind 非法: $kind');
    }
    if (kind == 'day' && dayIndex == null) {
      throw BackupParseException('cycleSelections 训练日缺少 dayIndex');
    }
    if (!seenDates.add(date)) {
      throw BackupParseException('cycleSelections 存在重复日期: $date');
    }
  }

  final exercisesParsed = exercises
      .map((e) => BackupExercise.fromJson(e as Map<String, dynamic>))
      .toList();
  final weekTemplateParsed = weekTemplate
      .map((e) => WeekTemplateRowData.fromJson(e as Map<String, dynamic>))
      .toList();
  final trainingRecordsParsed = trainingRecords
      .map((e) => TrainingRecordRowData.fromJson(e as Map<String, dynamic>))
      .toList();
  final cycleTemplateParsed = cycleTemplateList
      .map((e) => CycleTemplateRowData.fromJson(e as Map<String, dynamic>))
      .toList();
  final cycleSelectionsParsed = cycleSelectionsList
      .map((e) => CycleSelectionRowData.fromJson(e as Map<String, dynamic>))
      .toList();

  return BackupFile(
    exportedAt: json['exportedAt'] as String? ?? '',
    appVersion: json['appVersion'] as String? ?? '',
    data: BackupData(
      exercises: exercisesParsed,
      weekTemplate: weekTemplateParsed,
      trainingRecords: trainingRecordsParsed,
      cycleTemplate: cycleTemplateParsed,
      cycleSelections: cycleSelectionsParsed,
      cycleSettings: cycleSettings == null
          ? null
          : CycleSettingsData.fromJson(cycleSettings),
    ),
  );
}

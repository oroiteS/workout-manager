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

class BackupData {
  final List<BackupExercise> exercises;
  final List<WeekTemplateRowData> weekTemplate;
  final List<TrainingRecordRowData> trainingRecords;

  const BackupData({
    required this.exercises,
    required this.weekTemplate,
    required this.trainingRecords,
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
      );

  Map<String, dynamic> toJson() => {
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'weekTemplate': weekTemplate.map((e) => e.toJson()).toList(),
        'trainingRecords': trainingRecords.map((e) => e.toJson()).toList(),
      };
}

class BackupFile {
  static const String format = 'workout-manager-backup';
  static const int version = 1;

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
  if (version == null || version != BackupFile.version) {
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
    if (!exerciseIds.contains(exerciseId)) {
      throw BackupParseException(
        'trainingRecords 引用了不存在的 exerciseId: $exerciseId',
      );
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

  return BackupFile(
    exportedAt: json['exportedAt'] as String? ?? '',
    appVersion: json['appVersion'] as String? ?? '',
    data: BackupData(
      exercises: exercisesParsed,
      weekTemplate: weekTemplateParsed,
      trainingRecords: trainingRecordsParsed,
    ),
  );
}

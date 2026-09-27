import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/backup/backup_models.dart';

Map<String, dynamic> validBackupJson({
  List<Map<String, dynamic>>? exercises,
  List<Map<String, dynamic>>? weekTemplate,
  List<Map<String, dynamic>>? trainingRecords,
  List<Map<String, dynamic>>? cycleTemplate,
  List<Map<String, dynamic>>? cycleSelections,
  Map<String, dynamic>? cycleSettings,
  String format = 'workout-manager-backup',
  int version = 1,
}) {
  return {
    'format': format,
    'version': version,
    'exportedAt': '2026-07-14T10:00:00.000Z',
    'appVersion': '1.3.0+17',
    'data': {
      'exercises': exercises ??
          [
            {'id': 1, 'name': '杠铃卧推', 'datasetId': '0001'},
            {'id': 2, 'name': '深蹲', 'datasetId': null},
          ],
      'weekTemplate': weekTemplate ??
          [
            {'dayOfWeek': 1, 'exerciseId': 1, 'sortOrder': 0},
            {'dayOfWeek': 1, 'exerciseId': 2, 'sortOrder': 1},
          ],
      'trainingRecords': trainingRecords ??
          [
            {
              'exerciseId': 1,
              'exerciseName': '杠铃卧推',
              'weight': 60.5,
              'trainedAt': '2026-07-01T08:00:00.000',
            },
          ],
      if (cycleTemplate != null) 'cycleTemplate': cycleTemplate,
      if (cycleSelections != null) 'cycleSelections': cycleSelections,
      if (cycleSettings != null) 'cycleSettings': cycleSettings,
    },
  };
}

void main() {
  group('validateBackup', () {
    test('非法 format 抛出 BackupParseException', () {
      final json = validBackupJson(format: 'other-format');
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('不支持的备份格式'),
          ),
        ),
      );
    });

    test('非法 version 抛出 BackupParseException', () {
      final json = validBackupJson(version: 99);
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('不支持的备份版本'),
          ),
        ),
      );
    });

    test('结构不完整（缺 exercises）抛出 BackupParseException', () {
      final json = validBackupJson();
      (json['data'] as Map<String, dynamic>).remove('exercises');
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('备份文件结构不完整'),
          ),
        ),
      );
    });

    test('exercises 字段类型错误抛出 BackupParseException', () {
      final json = validBackupJson(
        exercises: [
          {'id': 'not-int', 'name': '杠铃卧推'},
        ],
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('exercises'),
          ),
        ),
      );
    });

    test('weekTemplate 引用不存在的 exerciseId', () {
      final json = validBackupJson(
        weekTemplate: [
          {'dayOfWeek': 1, 'exerciseId': 999, 'sortOrder': 0},
        ],
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('weekTemplate 引用了不存在的 exerciseId'),
          ),
        ),
      );
    });

    test('trainingRecords 引用不存在的 exerciseId', () {
      final json = validBackupJson(
        trainingRecords: [
          {
            'exerciseId': 999,
            'exerciseName': '未知',
            'weight': 10,
            'trainedAt': '2026-07-01T08:00:00.000',
          },
        ],
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('trainingRecords 引用了不存在的 exerciseId'),
          ),
        ),
      );
    });

    test('trainedAt 非法字符串抛出 BackupParseException', () {
      final json = validBackupJson(
        trainingRecords: [
          {
            'exerciseId': 1,
            'exerciseName': '杠铃卧推',
            'weight': 60.5,
            'trainedAt': 'not-a-date',
          },
        ],
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('trainedAt'),
          ),
        ),
      );
    });

    test('合法 JSON 返回 BackupFile', () {
      final json = validBackupJson();
      final file = validateBackup(json);
      expect(file.exportedAt, '2026-07-14T10:00:00.000Z');
      expect(file.appVersion, '1.3.0+17');
      expect(file.data.exercises.length, 2);
      expect(file.data.exercises[0].name, '杠铃卧推');
      expect(file.data.exercises[0].datasetId, '0001');
      expect(file.data.exercises[1].datasetId, isNull);
      expect(file.data.weekTemplate.length, 2);
      expect(file.data.trainingRecords.length, 1);
      expect(file.data.trainingRecords[0].weight, 60.5);
      expect(file.toJson()['format'], BackupFile.format);
      expect(file.toJson()['version'], BackupFile.version);
    });

    test('v1 旧备份（无循环字段）仍可解析', () {
      final json = validBackupJson(version: 1);
      final file = validateBackup(json);
      expect(file.data.cycleTemplate, isEmpty);
      expect(file.data.cycleSelections, isEmpty);
      expect(file.data.cycleSettings, isNull);
    });

    test('version 2 含循环字段返回解析结果', () {
      final json = validBackupJson(
        version: 2,
        cycleTemplate: [
          {'dayIndex': 1, 'exerciseId': 1, 'sortOrder': 0},
          {'dayIndex': 2, 'exerciseId': 2, 'sortOrder': 0},
        ],
        cycleSelections: [
          {'date': '2026-07-01', 'kind': 'day', 'dayIndex': 1},
          {'date': '2026-07-02', 'kind': 'cardio', 'dayIndex': null},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      final file = validateBackup(json);
      expect(file.data.cycleTemplate.length, 2);
      expect(file.data.cycleSelections.length, 2);
      expect(file.data.cycleSettings?.planMode, 'cycle');
      expect(file.data.cycleSettings?.dayCount, 3);
      final outData = file.toJson()['data'] as Map<String, dynamic>;
      expect(outData['cycleTemplate'], isA<List>());
      expect(outData['cycleSelections'], isA<List>());
      expect(outData['cycleSettings'], isA<Map<String, dynamic>>());
    });

    test('cycleTemplate 引用不存在的 exerciseId 抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleTemplate: [
          {'dayIndex': 1, 'exerciseId': 999, 'sortOrder': 0},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('cycleTemplate 引用了不存在的 exerciseId'),
          ),
        ),
      );
    });

    test('cycleTemplate dayIndex 超出循环天数抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleTemplate: [
          {'dayIndex': 5, 'exerciseId': 1, 'sortOrder': 0},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('超出循环天数'),
          ),
        ),
      );
    });

    test('cycleSelections 非法 kind 抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSelections: [
          {'date': '2026-07-01', 'kind': '游泳', 'dayIndex': null},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('kind 非法'),
          ),
        ),
      );
    });

    test('训练日选择缺少 dayIndex 抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSelections: [
          {'date': '2026-07-01', 'kind': 'day', 'dayIndex': null},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('缺少 dayIndex'),
          ),
        ),
      );
    });

    test('cycleSettings planMode 非法抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSettings: {'planMode': 'random', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('planMode 非法'),
          ),
        ),
      );
    });

    test('cycleSettings 缺少 planMode 抛出（而非 TypeError）', () {
      final json = validBackupJson(
        version: 2,
        cycleSettings: {'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('planMode 非法'),
          ),
        ),
      );
    });

    test('cycleSettings dayCount 超出上限抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSettings: {'planMode': 'cycle', 'dayCount': 15},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('dayCount 非法'),
          ),
        ),
      );
    });

    test('有循环数据但缺少 cycleSettings 抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleTemplate: [
          {'dayIndex': 1, 'exerciseId': 1, 'sortOrder': 0},
        ],
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('缺少 cycleSettings'),
          ),
        ),
      );
    });

    test('cycleTemplate 重复条目抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleTemplate: [
          {'dayIndex': 1, 'exerciseId': 1, 'sortOrder': 0},
          {'dayIndex': 1, 'exerciseId': 1, 'sortOrder': 1},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('重复条目'),
          ),
        ),
      );
    });

    test('cycleSelections 重复日期抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSelections: [
          {'date': '2026-07-01', 'kind': 'day', 'dayIndex': 1},
          {'date': '2026-07-01', 'kind': 'rest', 'dayIndex': null},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('重复日期'),
          ),
        ),
      );
    });

    test('cycleSelections date 非补零格式抛出', () {
      final json = validBackupJson(
        version: 2,
        cycleSelections: [
          {'date': '2026-7-1', 'kind': 'rest', 'dayIndex': null},
        ],
        cycleSettings: {'planMode': 'cycle', 'dayCount': 3},
      );
      expect(
        () => validateBackup(json),
        throwsA(
          isA<BackupParseException>().having(
            (e) => e.message,
            'message',
            contains('date 格式错误'),
          ),
        ),
      );
    });
  });
}

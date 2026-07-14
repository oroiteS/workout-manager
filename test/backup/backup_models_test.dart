import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/backup/backup_models.dart';

Map<String, dynamic> validBackupJson({
  List<Map<String, dynamic>>? exercises,
  List<Map<String, dynamic>>? weekTemplate,
  List<Map<String, dynamic>>? trainingRecords,
  String format = 'workout-manager-backup',
  int version = 1,
}) {
  return {
    'format': format,
    'version': version,
    'exportedAt': '2026-07-14T10:00:00.000Z',
    'appVersion': '1.2.0+16',
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
      expect(file.appVersion, '1.2.0+16');
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
  });
}

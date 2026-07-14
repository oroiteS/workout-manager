import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/backup/backup_models.dart';
import 'package:workout_manager/backup/backup_service.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() {
    db = createMemoryDb();
    service = BackupService(db);
  });

  tearDown(() async => await db.close());

  test('空库导出 → JSON 三表为空数组', () async {
    final jsonString = await service.exportToJson();
    final map = jsonDecode(jsonString) as Map<String, dynamic>;

    expect(map['format'], BackupFile.format);
    expect(map['version'], BackupFile.version);
    expect(map['appVersion'], '1.1.4+15');
    expect(map['exportedAt'], isA<String>());

    final data = map['data'] as Map<String, dynamic>;
    expect(data['exercises'], isEmpty);
    expect(data['weekTemplate'], isEmpty);
    expect(data['trainingRecords'], isEmpty);
  });

  test('有数据 export → import 到空库 → 三表一致', () async {
    final source = createMemoryDb();
    addTearDown(() async => await source.close());

    final exId1 = await source.exerciseDao.add('杠铃卧推', datasetId: '0001');
    final exId2 = await source.exerciseDao.add('深蹲');
    await source.templateDao.addExercise(1, '杠铃卧推', datasetId: '0001');
    await source.templateDao.addExercise(1, '深蹲');
    await source.templateDao.updateSortOrder(exId2, 1, 1);
    final trainedAt = DateTime(2026, 7, 1, 8, 0);
    await source.recordDao.upsertRecord(exId1, '杠铃卧推', 60.5, trainedAt);

    final sourceService = BackupService(source);
    final jsonString = await sourceService.exportToJson();

    await service.importFromJsonString(jsonString);

    final exercises = await db.exerciseDao.getAll();
    expect(exercises.length, 2);
    expect(
      exercises.map((e) => e.name).toSet(),
      {'杠铃卧推', '深蹲'},
    );
    final bench = exercises.firstWhere((e) => e.name == '杠铃卧推');
    expect(bench.datasetId, '0001');
    expect(bench.id, exId1);

    final templates = await db.templateDao.getAll();
    expect(templates.length, 2);
    expect(
      templates.map((t) => t.exerciseId).toSet(),
      {exId1, exId2},
    );

    final records = await db.recordDao.getAllForBackup();
    expect(records.length, 1);
    expect(records.first.exerciseId, exId1);
    expect(records.first.exerciseName, '杠铃卧推');
    expect(records.first.weight, 60.5);
    expect(DateTime.parse(records.first.trainedAt), trainedAt);
  });

  test('非法 JSON 导入 → 抛异常，原数据不变', () async {
    final id = await db.exerciseDao.add('保留动作');
    await db.templateDao.addExercise(2, '保留动作');
    await db.recordDao.upsertRecord(
      id,
      '保留动作',
      40,
      DateTime(2026, 6, 1),
    );

    await expectLater(
      service.importFromJsonString('not-json'),
      throwsA(isA<BackupParseException>()),
    );

    expect((await db.exerciseDao.getAll()).length, 1);
    expect((await db.templateDao.getAll()).length, 1);
    expect((await db.recordDao.getAllForBackup()).length, 1);
  });

  test('引用完整性失败 → 抛异常，原数据不变', () async {
    final id = await db.exerciseDao.add('原有动作');
    await db.recordDao.upsertRecord(
      id,
      '原有动作',
      50,
      DateTime(2026, 5, 1),
    );

    final badJson = jsonEncode({
      'format': BackupFile.format,
      'version': BackupFile.version,
      'exportedAt': '2026-07-14T10:00:00.000Z',
      'appVersion': '1.1.4+15',
      'data': {
        'exercises': [
          {'id': 1, 'name': '杠铃卧推', 'datasetId': null},
        ],
        'weekTemplate': [
          {'dayOfWeek': 1, 'exerciseId': 999, 'sortOrder': 0},
        ],
        'trainingRecords': <Map<String, dynamic>>[],
      },
    });

    await expectLater(
      service.importFromJsonString(badJson),
      throwsA(isA<BackupParseException>()),
    );

    final exercises = await db.exerciseDao.getAll();
    expect(exercises.length, 1);
    expect(exercises.first.name, '原有动作');
    expect((await db.recordDao.getAllForBackup()).length, 1);
  });
}

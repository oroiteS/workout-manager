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
    expect(map['appVersion'], '1.2.0+16');
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
      'appVersion': '1.2.0+16',
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

  test('JSON 数组导入 → 抛 BackupParseException', () async {
    await expectLater(
      service.importFromJsonString('[]'),
      throwsA(isA<BackupParseException>()),
    );
  });

  test('非空库全量替换，catalog 保留', () async {
    await db.catalogDao.importCatalog({
      'catalog_version': 1,
      'exercises': [
        {
          'dataset_id': '0001',
          'name_en': 'Bench Press',
          'name_zh': '杠铃卧推',
          'body_part': 'chest',
          'equipment': 'barbell',
          'target': 'pectorals',
          'muscle_group': 'chest',
          'secondary_muscles': ['triceps'],
          'instructions_zh': '说明',
          'instruction_steps_zh': ['步骤1'],
          'gif_asset': 'assets/exercises/gifs/0001.gif',
        },
        {
          'dataset_id': '0002',
          'name_en': 'Squat',
          'name_zh': '深蹲',
          'body_part': 'upper legs',
          'equipment': 'barbell',
          'target': 'quads',
          'muscle_group': 'quads',
          'secondary_muscles': ['glutes'],
          'instructions_zh': '说明2',
          'instruction_steps_zh': ['a'],
          'gif_asset': 'assets/exercises/gifs/0002.gif',
        },
      ],
    });
    final catalogBefore = await db.catalogDao.getAll();
    final catalogCountBefore = catalogBefore.length;
    final catalogIdsBefore =
        catalogBefore.map((e) => e.datasetId).toSet();

    final oldId = await db.exerciseDao.add('旧动作');
    await db.templateDao.addExercise(3, '旧动作');
    await db.recordDao.upsertRecord(
      oldId,
      '旧动作',
      30,
      DateTime(2026, 1, 1),
    );

    final backupJson = jsonEncode({
      'format': BackupFile.format,
      'version': BackupFile.version,
      'exportedAt': '2026-07-14T12:00:00.000Z',
      'appVersion': '1.2.0+16',
      'data': {
        'exercises': [
          {'id': 10, 'name': '新动作A', 'datasetId': '0001'},
          {'id': 11, 'name': '新动作B', 'datasetId': null},
        ],
        'weekTemplate': [
          {'dayOfWeek': 1, 'exerciseId': 10, 'sortOrder': 0},
        ],
        'trainingRecords': [
          {
            'exerciseId': 10,
            'exerciseName': '新动作A',
            'weight': 80.0,
            'trainedAt': '2026-07-10T08:00:00.000',
          },
        ],
      },
    });

    await service.importFromJsonString(backupJson);

    final exercises = await db.exerciseDao.getAll();
    expect(exercises.map((e) => e.name).toSet(), {'新动作A', '新动作B'});
    expect(exercises.map((e) => e.name), isNot(contains('旧动作')));

    final templates = await db.templateDao.getAll();
    expect(templates.length, 1);
    expect(templates.first.exerciseId, 10);
    expect(templates.first.dayOfWeek, 1);

    final records = await db.recordDao.getAllForBackup();
    expect(records.length, 1);
    expect(records.first.exerciseId, 10);
    expect(records.first.exerciseName, '新动作A');
    expect(records.first.weight, 80.0);

    final catalogAfter = await db.catalogDao.getAll();
    expect(catalogAfter.length, catalogCountBefore);
    expect(
      catalogAfter.map((e) => e.datasetId).toSet(),
      catalogIdsBefore,
    );
  });
}

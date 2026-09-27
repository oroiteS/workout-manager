import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:workout_manager/database/database.dart';

/// 迁移策略：只支持 v3 → v4；更旧的库（v1/v2）给出可读错误而非半途升级。
///
/// setup 回调在 drift 迁移执行前运行（见 drift src/sqlite3/database.dart），
/// 用它写入旧的 user_version 来模拟旧库。
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wm_migration_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  for (final oldVersion in [1, 2]) {
    test('v$oldVersion 数据库拒绝自动升级并给出可读提示', () async {
      final file = File(p.join(tempDir.path, 'v$oldVersion.db'));
      final executor = NativeDatabase(
        file,
        setup: (db) => db.execute('PRAGMA user_version = $oldVersion'),
      );

      final app = AppDatabase.forTestingOn(executor);
      addTearDown(() async {
        try {
          await app.close();
        } catch (_) {}
      });

      await expectLater(
        app.cycleDao.getPlanMode(),
        throwsA(
          predicate(
            (e) => e.toString().contains('过旧') && e.toString().contains('备份'),
            '包含「过旧」与「备份」的可读错误',
          ),
        ),
      );
    });
  }

  test('v3 数据库升级到 v4：建循环表、既有数据保留', () async {
    final file = File(p.join(tempDir.path, 'v3.db'));

    // 先按 v4 建库造数据，再降级为「v3 + 无循环表」。
    final seed = AppDatabase.forTestingOn(NativeDatabase(file));
    final exId = await seed.exerciseDao.add('卧推', datasetId: '0001');
    await seed.templateDao.addExercise(1, '卧推');
    await seed.recordDao.upsertRecord(
        exId, '卧推', 60, DateTime(2026, 7, 1));
    await seed.customStatement('DROP TABLE IF EXISTS cycle_template');
    await seed.customStatement('DROP TABLE IF EXISTS cycle_daily_selection');
    await seed.customStatement('PRAGMA user_version = 3');
    await seed.close();

    // 重新打开触发 3 → 4 升级。
    final app = AppDatabase.forTestingOn(NativeDatabase(file));
    addTearDown(() async {
      try {
        await app.close();
      } catch (_) {}
    });

    // 既有数据保留（含 dataset_id）
    final exercises = await app.exerciseDao.getAll();
    expect(exercises.single.name, '卧推');
    expect(exercises.single.datasetId, '0001');
    expect((await app.recordDao.getAllForBackup()).single.weight, 60.0);
    expect(
      (await app.templateDao.getByDay(1)).map((e) => e.exerciseName),
      ['卧推'],
    );

    // 循环表已创建且可写
    await app.cycleDao.addExercise(2, '划船');
    expect(
      (await app.cycleDao.getByDay(2)).map((e) => e.exerciseName),
      ['划船'],
    );
  });
}

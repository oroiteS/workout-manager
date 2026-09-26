import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;
  late TemplateDao dao;

  setUp(() {
    db = createMemoryDb();
    dao = db.templateDao;
  });

  tearDown(() async => await db.close());

  test('添加动作后可查询到', () async {
    await dao.addExercise(1, '胸推');

    final exercises = await dao.getByDay(1);
    expect(exercises.length, 1);
    expect(exercises.first.exerciseName, '胸推');
    expect(exercises.first.exerciseId, isPositive);
  });

  test('同名动作复用已有 id', () async {
    await dao.addExercise(1, '卷腹');
    await dao.addExercise(2, '卷腹');

    final all = await dao.getAll();
    expect(all.length, 2);
    expect(all[0].exerciseId, all[1].exerciseId);
    expect(all[0].exerciseName, all[1].exerciseName);
  });

  test('删除动作后查询为空', () async {
    await dao.addExercise(1, '胸推');
    final added = await dao.getByDay(1);
    await dao.deleteExercise(1, added.first.exerciseId);

    final exercises = await dao.getByDay(1);
    expect(exercises.isEmpty, true);
  });

  test('按 sort_order 排序返回', () async {
    await dao.addExercise(1, '动作C');
    await dao.addExercise(1, '动作A');
    final all = await dao.getByDay(1);
    await dao.updateSortOrder(all.first.exerciseId, 1, 0);
    await dao.updateSortOrder(all.last.exerciseId, 1, 1);

    final ordered = await dao.getByDay(1);
    expect(ordered[0].sortOrder, 0);
    expect(ordered[1].sortOrder, 1);
  });

  test('获取所有模板（7天全部）', () async {
    await dao.addExercise(1, '周一动作');
    await dao.addExercise(3, '周三动作');

    final all = await dao.getAll();
    expect(all.length, 2);
  });

  group('replaceAll', () {
    test('整周替换并按给定顺序写入 sort_order', () async {
      await dao.addExercise(5, '旧动作');

      await dao.replaceAll({
        1: ['动作B', '动作A'],
        3: ['卷腹'],
      });

      final mon = await dao.getByDay(1);
      expect(mon.map((e) => e.exerciseName), ['动作B', '动作A']);
      expect(mon.map((e) => e.sortOrder), [0, 1]);
      expect((await dao.getByDay(3)).map((e) => e.exerciseName), ['卷腹']);
      expect(await dao.getByDay(5), isEmpty);
    });

    test('不删除任何训练记录', () async {
      await dao.addExercise(1, '卧推');
      final benchId = (await dao.getByDay(1)).first.exerciseId;
      await db.recordDao.upsertRecord(
          benchId, '卧推', 60, DateTime(2026, 1, 1));
      await db.recordDao.upsertRecord(
          benchId, '卧推', 65, DateTime(2026, 1, 2));

      await dao.replaceAll({
        1: ['深蹲'],
        2: ['硬拉'],
      });

      final records = await db.recordDao.getAllForBackup();
      expect(records.length, 2);
      expect(records.every((r) => r.exerciseName == '卧推'), true);
      expect(records.every((r) => r.exerciseId == benchId), true);
      expect((await dao.getByDay(1)).map((e) => e.exerciseName), ['深蹲']);
    });

    test('保留已有动作 id，记录仍能对上', () async {
      await dao.addExercise(1, '卧推');
      final benchId = (await dao.getByDay(1)).first.exerciseId;
      await db.recordDao.upsertRecord(
          benchId, '卧推', 60, DateTime(2026, 1, 1));

      await dao.replaceAll({1: ['卧推'], 4: ['飞鸟']});

      expect((await dao.getByDay(1)).first.exerciseId, benchId);
      final exercises = await db.exerciseDao.getAll();
      expect(exercises.firstWhere((e) => e.name == '卧推').id, benchId);
      expect((await db.recordDao.getAllForBackup()).length, 1);
    });

    test('库内同名动作绑定 datasetId 以显示示意图', () async {
      await db.catalogDao.importCatalog({
        'catalog_version': 1,
        'exercises': [
          {'dataset_id': 'd1', 'name_zh': '杠铃卧推'},
        ],
      });

      await dao.replaceAll({1: ['杠铃卧推']});

      final exerciseId = (await dao.getByDay(1)).first.exerciseId;
      final exercise = await db.exerciseDao.getById(exerciseId);
      expect(exercise?.datasetId, 'd1');
    });
  });
}

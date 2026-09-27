import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;
  late CycleDao dao;

  setUp(() {
    db = createMemoryDb();
    dao = db.cycleDao;
  });

  tearDown(() async => await db.close());

  group('计划模式与循环天数', () {
    test('默认为计划模式、3 天循环', () async {
      expect(await dao.getPlanMode(), PlanMode.weekly);
      expect(await dao.getDayCount(), CycleDao.defaultDayCount);
    });

    test('设置并读回循环模式', () async {
      await dao.setPlanMode(PlanMode.cycle);
      expect(await dao.getPlanMode(), PlanMode.cycle);
      await dao.setPlanMode(PlanMode.weekly);
      expect(await dao.getPlanMode(), PlanMode.weekly);
    });

    test('设置循环天数后读回', () async {
      await dao.setDayCount(5);
      expect(await dao.getDayCount(), 5);
    });

    test('缩短天数时删除超出范围的循环动作', () async {
      await dao.addExercise(1, '胸推');
      await dao.addExercise(3, '划船');
      await dao.addExercise(5, '硬拉');

      await dao.setDayCount(3);

      final all = await dao.getAll();
      expect(all.map((e) => e.dayOfWeek), [1, 3]);
      expect((await dao.getByDay(5)), isEmpty);
    });

    test('clearSettings 不影响其他 meta', () async {
      await db.catalogDao.importCatalog({
        'catalog_version': 7,
        'exercises': <Map<String, dynamic>>[],
      });
      await dao.setPlanMode(PlanMode.cycle);
      await dao.setDayCount(4);

      await dao.clearSettings();

      expect(await dao.getPlanMode(), PlanMode.weekly);
      expect(await dao.getDayCount(), CycleDao.defaultDayCount);
      expect(await db.catalogDao.getCatalogVersion(), 7);
    });
  });

  group('循环动作', () {
    test('添加后按天查询', () async {
      await dao.addExercise(1, '胸推');
      await dao.addExercise(1, '飞鸟');
      await dao.addExercise(2, '划船');

      expect(
        (await dao.getByDay(1)).map((e) => e.exerciseName),
        ['胸推', '飞鸟'],
      );
      expect((await dao.getByDay(2)).map((e) => e.exerciseName), ['划船']);
      expect((await dao.getAll()).length, 3);
    });

    test('同名动作复用已有 id', () async {
      await dao.addExercise(1, '卷腹');
      await dao.addExercise(2, '卷腹');

      final all = await dao.getAll();
      expect(all[0].exerciseId, all[1].exerciseId);
    });

    test('删除动作后查询为空', () async {
      await dao.addExercise(1, '胸推');
      final added = await dao.getByDay(1);
      await dao.deleteExercise(1, added.first.exerciseId);

      expect(await dao.getByDay(1), isEmpty);
    });

    group('replaceAll', () {
      test('整体替换并按给定顺序写入 sort_order', () async {
        await dao.addExercise(1, '旧动作');

        await dao.replaceAll({
          1: ['动作B', '动作A'],
          2: ['划船'],
        });

        expect(
          (await dao.getByDay(1)).map((e) => e.exerciseName),
          ['动作B', '动作A'],
        );
        expect((await dao.getByDay(1)).map((e) => e.sortOrder), [0, 1]);
        expect((await dao.getByDay(2)).map((e) => e.exerciseName), ['划船']);
        expect(await dao.getByDay(3), isEmpty);
      });

      test('不删除训练记录，保留已有动作 id', () async {
        await dao.addExercise(1, '卧推');
        final benchId = (await dao.getByDay(1)).first.exerciseId;
        await db.recordDao.upsertRecord(
            benchId, '卧推', 60, DateTime(2026, 1, 1));

        await dao.replaceAll({1: ['卧推'], 2: ['深蹲']});

        expect((await dao.getByDay(1)).first.exerciseId, benchId);
        final records = await db.recordDao.getAllForBackup();
        expect(records.length, 1);
        expect(records.first.exerciseId, benchId);
      });

      test('每日选择不受影响', () async {
        await dao.setSelection(const CycleSelection(
          date: '2026-07-01',
          kind: CycleSelectionKind.day,
          dayIndex: 1,
        ));

        await dao.replaceAll({2: ['划船']});

        expect(
          (await dao.getSelection('2026-07-01'))?.dayIndex,
          1,
        );
      });
    });
  });

  group('每日选择', () {
    test('写入并读回训练日选择', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-07-01',
        kind: CycleSelectionKind.day,
        dayIndex: 2,
      ));

      final sel = await dao.getSelection('2026-07-01');
      expect(sel?.kind, CycleSelectionKind.day);
      expect(sel?.dayIndex, 2);
    });

    test('同一天重复选择覆盖旧值', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-07-01',
        kind: CycleSelectionKind.day,
        dayIndex: 2,
      ));
      await dao.setSelection(const CycleSelection(
        date: '2026-07-01',
        kind: CycleSelectionKind.cardio,
      ));

      final sel = await dao.getSelection('2026-07-01');
      expect(sel?.kind, CycleSelectionKind.cardio);
      expect(sel?.dayIndex, isNull);
    });

    test('有氧与休息可读回', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-07-02',
        kind: CycleSelectionKind.rest,
      ));
      expect(
        (await dao.getSelection('2026-07-02'))?.kind,
        CycleSelectionKind.rest,
      );
    });

    test('无选择返回 null', () async {
      expect(await dao.getSelection('2026-07-03'), isNull);
    });
  });

  group('循环建议（进度）', () {
    test('dateKeyOf 补零为 yyyy-MM-dd', () {
      expect(dateKeyOf(DateTime(2026, 7, 1)), '2026-07-01');
      expect(dateKeyOf(DateTime(2026, 11, 23)), '2026-11-23');
      expect(dateKeyOf(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('无历史 → 第 1 天', () async {
      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 1);
    });

    test('昨天选了第 1 天 → 今天建议第 2 天', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 1,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 2);
    });

    test('最后一天之后回绕到第 1 天', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 3,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 1);
    });

    test('只看最近一次训练日选择', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-06-28',
        kind: CycleSelectionKind.day,
        dayIndex: 3,
      ));
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 1,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 2);
    });

    test('有氧/休息不推进循环', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 1,
      ));
      await dao.setSelection(const CycleSelection(
        date: '2026-07-01',
        kind: CycleSelectionKind.cardio,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 2),
        dayCount: 3,
      );
      expect(next, 2);
    });

    test('今天已选不影响今天的建议', () async {
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 1,
      ));
      await dao.setSelection(const CycleSelection(
        date: '2026-07-01',
        kind: CycleSelectionKind.day,
        dayIndex: 2,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 2);
    });

    test('缩短天数后越界的陈旧选择不参与建议', () async {
      // 模拟：曾有 5 天循环并在 6-28 选了第 1 天、6-30 选了第 5 天，
      // 后来循环缩短为 3 天——第 5 天的选择应被跳过，从第 1 天推进。
      await dao.setSelection(const CycleSelection(
        date: '2026-06-28',
        kind: CycleSelectionKind.day,
        dayIndex: 1,
      ));
      await dao.setSelection(const CycleSelection(
        date: '2026-06-30',
        kind: CycleSelectionKind.day,
        dayIndex: 5,
      ));

      final next = await dao.recommendDayIndex(
        DateTime(2026, 7, 1),
        dayCount: 3,
      );
      expect(next, 2);
    });
  });
}

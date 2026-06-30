import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;
  late RecordDao dao;

  setUp(() {
    db = createMemoryDb();
    dao = db.recordDao;
  });

  tearDown(() async => await db.close());

  test('upsert 插入新记录', () async {
    final now = DateTime.now();
    await dao.upsertRecord('胸推', 50.0, now);

    final history = await dao.getHistory('胸推', limit: 20);
    expect(history.length, 1);
    expect(history.first.weight, 50.0);
  });

  test('upsert 更新同天同动作记录', () async {
    final today = DateTime.now();
    await dao.upsertRecord('胸推', 50.0, today);
    await dao.upsertRecord('胸推', 55.0, today); // same day, should update

    final history = await dao.getHistory('胸推', limit: 20);
    expect(history.length, 1); // still 1 record
    expect(history.first.weight, 55.0); // weight updated
  });

  test('upsert 不更新不同天的记录', () async {
    await dao.upsertRecord('胸推', 50.0, DateTime(2025, 6, 1));
    await dao.upsertRecord('胸推', 55.0, DateTime(2025, 6, 2)); // different day

    final history = await dao.getHistory('胸推', limit: 20);
    expect(history.length, 2); // 2 separate records
  });

  test('getLastWeight 返回最近一次重量', () async {
    final d1 = DateTime(2025, 6, 1);
    final d2 = DateTime(2025, 6, 8);
    await dao.upsertRecord('胸推', 50.0, d1);
    await dao.upsertRecord('胸推', 55.0, d2);

    final last = await dao.getLastWeight('胸推');
    expect(last, 55.0);
  });

  test('getLastWeight 无记录时返回 null', () async {
    final last = await dao.getLastWeight('不存在的动作');
    expect(last, isNull);
  });

  test('getHistory 按日期降序返回', () async {
    await dao.upsertRecord('深蹲', 80.0, DateTime(2025, 6, 1));
    await dao.upsertRecord('深蹲', 85.0, DateTime(2025, 6, 15));

    final history = await dao.getHistory('深蹲', limit: 20);
    expect(history.length, 2);
    expect(history.first.weight, 85.0);
  });

  test('limit 生效', () async {
    for (var i = 0; i < 25; i++) {
      await dao.upsertRecord('硬拉', 100.0 + i, DateTime(2025, 6, i + 1));
    }
    final history = await dao.getHistory('硬拉', limit: 20);
    expect(history.length, 20);
  });

  test('删除记录', () async {
    final now = DateTime.now();
    await dao.upsertRecord('胸推', 50.0, now);
    final records = await dao.getRecordsGroupedByDate();
    expect(records.length, 1);

    await dao.deleteById(records.first.id);
    final after = await dao.getRecordsGroupedByDate();
    expect(after.length, 0);
  });

  test('getRecordsGroupedByDate 返回所有记录', () async {
    await dao.upsertRecord('胸推', 50.0, DateTime(2025, 6, 1));
    await dao.upsertRecord('深蹲', 80.0, DateTime(2025, 6, 2));

    final all = await dao.getRecordsGroupedByDate();
    expect(all.length, 2);
  });

  test('updateWeight 更新指定记录重量', () async {
    final now = DateTime.now();
    await dao.upsertRecord('胸推', 50.0, now);
    final records = await dao.getRecordsGroupedByDate();
    final id = records.first.id;

    await dao.updateWeight(id, 75.0);
    final updated = await dao.getHistory('胸推');
    expect(updated.length, 1);
    expect(updated.first.weight, 75.0);
  });
}

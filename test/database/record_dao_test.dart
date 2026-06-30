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

  test('插入记录后可查询', () async {
    final now = DateTime.now();
    await dao.insertRecord('胸推', 50.0, now);

    final history = await dao.getHistory('胸推', limit: 20);
    expect(history.length, 1);
    expect(history.first.weight, 50.0);
  });

  test('getLastWeight 返回最近一次重量', () async {
    final d1 = DateTime(2025, 6, 1);
    final d2 = DateTime(2025, 6, 8);
    await dao.insertRecord('胸推', 50.0, d1);
    await dao.insertRecord('胸推', 55.0, d2);

    final last = await dao.getLastWeight('胸推');
    expect(last, 55.0);
  });

  test('getLastWeight 无记录时返回 null', () async {
    final last = await dao.getLastWeight('不存在的动作');
    expect(last, isNull);
  });

  test('getHistory 按日期降序返回', () async {
    await dao.insertRecord('深蹲', 80.0, DateTime(2025, 6, 1));
    await dao.insertRecord('深蹲', 85.0, DateTime(2025, 6, 15));

    final history = await dao.getHistory('深蹲', limit: 20);
    expect(history.length, 2);
    expect(history.first.weight, 85.0);
  });

  test('limit 生效', () async {
    for (var i = 0; i < 25; i++) {
      await dao.insertRecord('硬拉', 100.0 + i, DateTime(2025, 6, i + 1));
    }
    final history = await dao.getHistory('硬拉', limit: 20);
    expect(history.length, 20);
  });
}

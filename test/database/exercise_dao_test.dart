import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createMemoryDb();
  });

  tearDown(() async => await db.close());

  test('ensureExercise 新建并写入 datasetId', () async {
    final id = await db.exerciseDao.ensureExercise(
      name: '杠铃卧推',
      datasetId: '0001',
    );
    final e = await db.exerciseDao.getById(id);
    expect(e!.name, '杠铃卧推');
    expect(e.datasetId, '0001');
  });

  test('ensureExercise 同名已存在则复用并补全 datasetId', () async {
    final id1 = await db.exerciseDao.ensureExercise(name: '深蹲', datasetId: null);
    final id2 =
        await db.exerciseDao.ensureExercise(name: '深蹲', datasetId: '0002');
    expect(id1, id2);
    expect((await db.exerciseDao.getById(id1))!.datasetId, '0002');
  });

  test('ensureExercise 自定义无 datasetId', () async {
    final id =
        await db.exerciseDao.ensureExercise(name: '我的动作', datasetId: null);
    expect((await db.exerciseDao.getById(id))!.datasetId, isNull);
  });

  test('template addExercise 带 datasetId', () async {
    await db.templateDao.addExercise(1, '杠铃卧推', datasetId: '0001');
    final day = await db.templateDao.getByDay(1);
    expect(day.length, 1);
    expect(day.first.exerciseName, '杠铃卧推');
    final ex = await db.exerciseDao.getById(day.first.exerciseId);
    expect(ex!.datasetId, '0001');
  });
}

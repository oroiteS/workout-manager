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
  });

  test('删除动作后查询为空', () async {
    await dao.addExercise(1, '胸推');
    await dao.deleteExercise(1, '胸推');

    final exercises = await dao.getByDay(1);
    expect(exercises.isEmpty, true);
  });

  test('按 sort_order 排序返回', () async {
    await dao.addExercise(1, '动作C');
    await dao.addExercise(1, '动作A');
    final all = await dao.getByDay(1);
    await dao.updateSortOrder(all.first.exerciseName, 1, 0);
    await dao.updateSortOrder(all.last.exerciseName, 1, 1);

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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/screens/template_screen.dart';
import 'package:workout_manager/screens/today_training_screen.dart';

Widget _wrap(AppDatabase db, Widget child) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('今日训练 · 循环模式', () {
    late AppDatabase db;

    setUp(() {
      db = createMemoryDb();
    });

    tearDown(() async => await db.close());

    testWidgets('未选择时显示循环开练与自主选择', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await db.cycleDao.setDayCount(3);
      await db.cycleDao.addExercise(1, '卧推');
      await db.cycleDao.addExercise(2, '划船');

      await tester.pumpWidget(_wrap(db, const TodayTrainingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('循环模式 · 共 3 天'), findsOneWidget);
      expect(find.text('今天建议：第1天'), findsOneWidget);
      expect(find.textContaining('循环开练'), findsOneWidget);
      expect(find.text('自主选择今天的内容'), findsOneWidget);
      expect(find.text('保存训练记录'), findsNothing);
    });

    testWidgets('循环开练选中建议日并显示动作与保存按钮', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await db.cycleDao.setDayCount(3);
      await db.cycleDao.addExercise(1, '卧推');
      await db.cycleDao.addExercise(2, '划船');

      await tester.pumpWidget(_wrap(db, const TodayTrainingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('循环开练'));
      await tester.pumpAndSettle();

      expect(find.text('今日安排：第1天'), findsOneWidget);
      expect(find.text('卧推'), findsOneWidget);
      expect(find.text('保存训练记录'), findsOneWidget);

      final selection =
          await db.cycleDao.getSelection(dateKeyOf(DateTime.now()));
      expect(selection?.kind, CycleSelectionKind.day);
      expect(selection?.dayIndex, 1);
    });

    testWidgets('自主选择可切换到有氧并隐藏保存按钮', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await db.cycleDao.setDayCount(3);
      await db.cycleDao.addExercise(1, '卧推');

      await tester.pumpWidget(_wrap(db, const TodayTrainingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('自主选择今天的内容'));
      await tester.pumpAndSettle();

      expect(find.text('选择今天的内容'), findsOneWidget);
      expect(find.text('第1天'), findsOneWidget);
      expect(find.text('第2天'), findsOneWidget);
      expect(find.text('第3天'), findsOneWidget);
      expect(find.text('推荐'), findsOneWidget);
      expect(find.text('有氧'), findsOneWidget);
      // 动作数副标题：冷启动首开也应显示真实数量（第1天 1 个，其余暂无）
      expect(find.text('1 个动作'), findsOneWidget);
      expect(find.text('暂无动作'), findsNWidgets(2));
      expect(find.text('休息'), findsOneWidget);

      await tester.tap(find.text('有氧'));
      await tester.pumpAndSettle();

      expect(find.text('今日安排：有氧'), findsOneWidget);
      expect(find.text('今天练有氧'), findsOneWidget);
      expect(find.text('保存训练记录'), findsNothing);

      final selection =
          await db.cycleDao.getSelection(dateKeyOf(DateTime.now()));
      expect(selection?.kind, CycleSelectionKind.cardio);
    });

    testWidgets('选择休息后可通过更换切回训练日', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await db.cycleDao.setDayCount(3);
      await db.cycleDao.addExercise(3, '卷腹');

      await tester.pumpWidget(_wrap(db, const TodayTrainingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('自主选择今天的内容'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('休息'));
      await tester.pumpAndSettle();

      expect(find.text('今日安排：休息'), findsOneWidget);
      expect(find.text('保存训练记录'), findsNothing);

      await tester.tap(find.text('更换'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('第3天'));
      await tester.pumpAndSettle();

      expect(find.text('今日安排：第3天'), findsOneWidget);
      expect(find.text('卷腹'), findsOneWidget);
      expect(find.text('保存训练记录'), findsOneWidget);
    });

    testWidgets('有历史选择时建议自动推进到下一天', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await db.cycleDao.setDayCount(3);
      await db.cycleDao.addExercise(1, '卧推');
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await db.cycleDao.setSelection(CycleSelection(
        date: dateKeyOf(yesterday),
        kind: CycleSelectionKind.day,
        dayIndex: 2,
      ));

      await tester.pumpWidget(_wrap(db, const TodayTrainingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('今天建议：第3天'), findsOneWidget);
      expect(find.textContaining('循环开练 · 第3天'), findsOneWidget);
    });
  });

  group('周模板 · 模式切换', () {
    late AppDatabase db;

    setUp(() {
      db = createMemoryDb();
    });

    tearDown(() async => await db.close());

    testWidgets('默认显示计划模式的 7 天周模板', (tester) async {
      await tester.pumpWidget(_wrap(db, const TemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.text('周训练模板'), findsOneWidget);
      expect(find.text('周一'), findsOneWidget);
      expect(find.text('循环天数'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('周日'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('周日'), findsOneWidget);
    });

    testWidgets('切换到循环模式后显示循环天数与第 N 天卡片', (tester) async {
      await tester.pumpWidget(_wrap(db, const TemplateScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('循环模式'));
      await tester.pumpAndSettle();

      expect(find.text('循环模板'), findsOneWidget);
      expect(find.text('循环天数'), findsOneWidget);
      expect(find.text('3 天'), findsOneWidget);
      expect(find.text('第1天'), findsOneWidget);
      expect(find.text('第3天'), findsOneWidget);
      expect(find.text('第4天'), findsNothing);
      expect(find.text('周一'), findsNothing);

      expect(await db.cycleDao.getPlanMode(), PlanMode.cycle);
    });

    testWidgets('切换回计划模式后恢复周模板', (tester) async {
      await db.cycleDao.setPlanMode(PlanMode.cycle);
      await tester.pumpWidget(_wrap(db, const TemplateScreen()));
      await tester.pumpAndSettle();

      expect(find.text('循环模板'), findsOneWidget);

      await tester.tap(find.text('计划模式'));
      await tester.pumpAndSettle();

      expect(find.text('周训练模板'), findsOneWidget);
      expect(find.text('周一'), findsOneWidget);
      expect(await db.cycleDao.getPlanMode(), PlanMode.weekly);
    });
  });
}

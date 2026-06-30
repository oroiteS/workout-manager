// test/widgets/exercise_input_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/widgets/exercise_input_card.dart';

void main() {
  testWidgets('显示动作名称', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseInputCard(
              exerciseName: '胸推',
              lastWeight: null,
              lastDate: null,
              onWeightChanged: (v) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('胸推'), findsOneWidget);
  });

  testWidgets('显示上次训练重量和日期', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseInputCard(
              exerciseName: '硬拉',
              lastWeight: 80.0,
              lastDate: DateTime(2025, 6, 23),
              onWeightChanged: (v) {},
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('80'), findsOneWidget);
    expect(find.textContaining('6月23日'), findsOneWidget);
  });

  testWidgets('输入重量后回调被调用', (tester) async {
    double? changedValue;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseInputCard(
              exerciseName: '深蹲',
              lastWeight: null,
              lastDate: null,
              onWeightChanged: (v) => changedValue = v,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '60.5');
    expect(changedValue, 60.5);
  });

  testWidgets('空输入时回调 null', (tester) async {
    double? changedValue = -1;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseInputCard(
              exerciseName: '深蹲',
              lastWeight: null,
              lastDate: null,
              onWeightChanged: (v) => changedValue = v,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '50');
    await tester.enterText(find.byType(TextFormField), '');
    expect(changedValue, isNull);
  });

  testWidgets('动作名区域可点击（有 chevron_right 图标指示可导航）', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {
            '/chart': (_) => const Scaffold(body: Text('图表页面')),
          },
          home: Scaffold(
            body: ExerciseInputCard(
              exerciseName: '飞鸟',
              lastWeight: null,
              lastDate: null,
              onWeightChanged: (v) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.text('飞鸟'));
    await tester.pumpAndSettle();
    expect(find.text('图表页面'), findsOneWidget);
  });
}

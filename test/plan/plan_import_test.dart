import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/plan/plan_import.dart';

void main() {
  group('parsePlanCsv', () {
    test('表头 + 多天解析，行序即当天动作顺序', () {
      final plan = parsePlanCsv('day,exercise\n'
          '1,杠铃深蹲\n'
          '1,腿举\n'
          '1,腿弯举\n'
          '2,杠铃卧推\n');

      expect(plan.exercisesByDay.keys, [1, 2]);
      expect(plan.exercisesByDay[1], ['杠铃深蹲', '腿举', '腿弯举']);
      expect(plan.exercisesByDay[2], ['杠铃卧推']);
      expect(plan.exerciseCount, 4);
      expect(plan.missingDays, [3, 4, 5, 6, 7]);
    });

    test('天数接受 1-7、周X、星期X', () {
      final plan = parsePlanCsv(
        '1,动作一\n'
        '周二,动作二\n'
        '星期三,动作三\n'
        '4,动作四\n'
        '7,动作七\n',
      );

      expect(plan.exercisesByDay.keys, [1, 2, 3, 4, 7]);
      expect(plan.exercisesByDay[2], ['动作二']);
      expect(plan.exercisesByDay[3], ['动作三']);
      expect(plan.exercisesByDay[4], ['动作四']);
    });

    test('首行不是表头时按数据处理', () {
      final plan = parsePlanCsv('1,卧推\n2,深蹲\n');
      expect(plan.exercisesByDay.keys, [1, 2]);
    });

    test('兼容 BOM 与 CRLF 换行', () {
      const bom = '\uFEFF';
      final plan =
          parsePlanCsv('${bom}day,exercise\r\n1,卧推\r\n2,深蹲\r\n');
      expect(plan.exercisesByDay[1], ['卧推']);
      expect(plan.exercisesByDay[2], ['深蹲']);
    });

    test('引号字段支持内嵌逗号与转义引号', () {
      final plan = parsePlanCsv(
        'day,exercise\n'
        '1,"卧推, 上斜"\n'
        '1,"杠铃 ""大重量"" 组"\n',
      );
      expect(plan.exercisesByDay[1], ['卧推, 上斜', '杠铃 "大重量" 组']);
    });

    test('忽略空行与行尾多余逗号', () {
      final plan = parsePlanCsv('day,exercise,\n\n1,卧推,\n\n');
      expect(plan.exercisesByDay[1], ['卧推']);
    });

    test('同日重复动作去重，保留首次出现', () {
      final plan = parsePlanCsv('1,卧推\n1,卧推\n1,飞鸟\n');
      expect(plan.exercisesByDay[1], ['卧推', '飞鸟']);
    });

    test('动作名首尾空白被裁剪', () {
      final plan = parsePlanCsv(' 1 , 卧推 \n');
      expect(plan.exercisesByDay[1], ['卧推']);
    });

    test('非法天数报错并带原始行号', () {
      expect(
        () => parsePlanCsv('day,exercise\n1,卧推\n8,跑步\n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', contains('第 3 行')),
        ),
      );
    });

    test('空行不打乱报错行号', () {
      expect(
        () => parsePlanCsv('day,exercise\n\n\nxxx,卧推\n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', contains('第 4 行')),
        ),
      );
    });

    test('空文件报错', () {
      expect(
        () => parsePlanCsv('   \n\n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', 'CSV 为空'),
        ),
      );
    });

    test('只有表头报错', () {
      expect(
        () => parsePlanCsv('day,exercise\n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', contains('没有数据行')),
        ),
      );
    });

    test('列式（每天一列）格式报错', () {
      expect(
        () => parsePlanCsv('周一,周二,周三\n卧推,深蹲,硬拉\n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', contains('两列')),
        ),
      );
    });

    test('动作名为空报错', () {
      expect(
        () => parsePlanCsv('1,   \n'),
        throwsA(
          isA<PlanCsvException>()
              .having((e) => e.message, 'message', contains('动作名为空')),
        ),
      );
    });
  });

  group('buildPlanDiff', () {
    final current = [
      (dayOfWeek: 1, exerciseName: '卧推'),
      (dayOfWeek: 1, exerciseName: '飞鸟'),
      (dayOfWeek: 2, exerciseName: '深蹲'),
    ];

    test('区分新增 / 移除 / 保留', () {
      final diff = buildPlanDiff(
        current,
        parsePlanCsv('day,exercise\n1,卧推\n1,硬拉\n3,卷腹\n'),
      );

      expect(diff.hasChanges, true);
      expect(diff.days.map((d) => d.day), [1, 2, 3]);

      final day1 = diff.days.firstWhere((d) => d.day == 1);
      expect(day1.added, ['硬拉']);
      expect(day1.removed, ['飞鸟']);
      expect(day1.kept, ['卧推']);
      expect(day1.cleared, false);

      expect(diff.totalAdded, 2);
      expect(diff.totalRemoved, 2);
      expect(diff.exerciseCount, 3);
    });

    test('CSV 未覆盖的天标记为清空', () {
      final diff = buildPlanDiff(
        current,
        parsePlanCsv('1,卧推\n1,飞鸟\n'),
      );

      expect(diff.clearedDays, [2]);
      expect(diff.days.firstWhere((d) => d.day == 2).cleared, true);
    });

    test('内容完全一致时无变化', () {
      final diff = buildPlanDiff(
        current,
        parsePlanCsv('1,卧推\n1,飞鸟\n2,深蹲\n'),
      );

      expect(diff.hasChanges, false);
      expect(diff.days, isEmpty);
    });

    test('仅顺序变化视为无变化', () {
      final diff = buildPlanDiff(
        current,
        parsePlanCsv('1,飞鸟\n1,卧推\n2,深蹲\n'),
      );

      expect(diff.hasChanges, false);
    });
  });
}

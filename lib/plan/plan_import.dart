// 周计划 CSV 解析与差异计算（纯逻辑，不依赖数据库）。
//
// CSV 格式：行式两列 `day,exercise`，一天可有多行，行序即当天动作顺序。
// 例：
//   day,exercise
//   1,杠铃深蹲
//   1,腿举
//   2,杠铃卧推
// `day` 接受 `1`-`7`、`周一`-`周日`、`星期一`-`星期日`。

class PlanCsvException implements Exception {
  final String message;
  const PlanCsvException(this.message);

  @override
  String toString() => message;
}

/// 解析结果：day(1-7) → 动作名列表（按文件行序，同日去重保留首次出现）。
class ParsedPlan {
  final Map<int, List<String>> exercisesByDay;

  const ParsedPlan(this.exercisesByDay);

  int get exerciseCount =>
      exercisesByDay.values.fold(0, (sum, names) => sum + names.length);

  Set<int> get days => exercisesByDay.keys.toSet();

  /// CSV 未覆盖的天（整周替换语义下会被清空）。
  List<int> get missingDays =>
      [for (var d = 1; d <= 7; d++) if (!exercisesByDay.containsKey(d)) d];
}

ParsedPlan parsePlanCsv(String raw) {
  var input = raw;
  if (input.startsWith('\uFEFF')) {
    input = input.substring(1);
  }

  final rows = _parseCsvRows(input);
  if (rows.isEmpty) {
    throw const PlanCsvException('CSV 为空');
  }

  var dataRows = rows;
  if (_parseDay(rows.first.fields[0]) == null) {
    // 首行 day 列无法识别为天数 → 视为表头并跳过
    dataRows = rows.skip(1).toList();
    if (dataRows.isEmpty) {
      throw const PlanCsvException('CSV 中没有数据行');
    }
  }

  final byDay = <int, List<String>>{};
  for (final row in dataRows) {
    if (row.fields.length != 2) {
      throw PlanCsvException(
        '第 ${row.line} 行有 ${row.fields.length} 列，只支持两列 day,exercise 格式',
      );
    }
    final day = _parseDay(row.fields[0]);
    if (day == null) {
      throw PlanCsvException(
        '第 ${row.line} 行无法识别天数「${row.fields[0].trim()}」，'
        '应为 1-7 或 周一-周日',
      );
    }
    final name = row.fields[1].trim();
    if (name.isEmpty) {
      throw PlanCsvException('第 ${row.line} 行动作名为空');
    }
    final list = byDay.putIfAbsent(day, () => <String>[]);
    if (!list.contains(name)) {
      list.add(name);
    }
  }

  if (byDay.isEmpty) {
    throw const PlanCsvException('CSV 中没有动作行');
  }

  final sorted = <int, List<String>>{};
  for (var d = 1; d <= 7; d++) {
    if (byDay.containsKey(d)) sorted[d] = byDay[d]!;
  }
  return ParsedPlan(sorted);
}

/// 解析天数：`1`-`7` / `周一`-`周日` / `星期一`-`星期日`。
int? _parseDay(String cell) {
  final t = cell.trim();
  if (t.isEmpty) return null;
  final n = int.tryParse(t);
  if (n != null) return (n >= 1 && n <= 7) ? n : null;

  const week = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '日': 7, '天': 7};
  for (final prefix in ['星期', '周']) {
    if (t.length == prefix.length + 1 && t.startsWith(prefix)) {
      return week[t[prefix.length]];
    }
  }
  return null;
}

class _CsvRow {
  final int line;
  final List<String> fields;
  const _CsvRow(this.line, this.fields);
}

/// 极简 RFC4180 解析：支持引号包裹、双引号转义、CRLF/LF 换行。
/// 返回带原始文件行号（1 起）的数据行；空行不产出，但行号仍准确。
List<_CsvRow> _parseCsvRows(String input) {
  final rows = <_CsvRow>[];
  final fields = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var line = 1;
  var rowStartLine = 1;
  var hasContent = false;

  void endField() {
    fields.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(_CsvRow(rowStartLine, List.of(fields)));
    fields.clear();
    rowStartLine = line;
    hasContent = false;
  }

  var i = 0;
  while (i < input.length) {
    final c = input[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
      } else {
        if (c == '\n') line++;
        field.write(c);
        i++;
      }
      continue;
    }

    if (c == '"' && field.isEmpty) {
      inQuotes = true;
      hasContent = true;
      i++;
    } else if (c == ',') {
      endField();
      hasContent = true;
      i++;
    } else if (c == '\r' || c == '\n') {
      if (c == '\r' && i + 1 < input.length && input[i + 1] == '\n') i++;
      i++;
      line++;
      if (hasContent || fields.isNotEmpty || field.isNotEmpty) {
        endRow();
      } else {
        // 空行：只推进行号，不产出数据行
        rowStartLine = line;
      }
    } else {
      field.write(c);
      hasContent = true;
      i++;
    }
  }
  if (hasContent || fields.isNotEmpty || field.isNotEmpty) {
    endField();
    rows.add(_CsvRow(rowStartLine, fields));
  }

  // 去掉第 3 列起的尾部空列（如 Excel 导出常见的行尾逗号），保留前两列
  return rows.map((r) {
    final f = List.of(r.fields);
    while (f.length > 2 && f.last.trim().isEmpty) {
      f.removeLast();
    }
    return _CsvRow(r.line, f);
  }).where((r) => r.fields.any((e) => e.trim().isNotEmpty)).toList();
}

class DayPlanDiff {
  final int day;
  final List<String> added;
  final List<String> removed;
  final List<String> kept;

  const DayPlanDiff({
    required this.day,
    required this.added,
    required this.removed,
    required this.kept,
  });

  bool get changed => added.isNotEmpty || removed.isNotEmpty;

  /// 当天动作被全部移除（CSV 未覆盖该天，或覆盖为空）。
  bool get cleared => added.isEmpty && kept.isEmpty && removed.isNotEmpty;
}

class PlanDiff {
  final List<DayPlanDiff> days; // 仅含有变化的天，按 1-7 排序
  final int exerciseCount;

  const PlanDiff({required this.days, required this.exerciseCount});

  bool get hasChanges => days.isNotEmpty;

  List<int> get clearedDays =>
      days.where((d) => d.cleared).map((d) => d.day).toList();

  int get totalAdded =>
      days.fold(0, (sum, d) => sum + d.added.length);

  int get totalRemoved =>
      days.fold(0, (sum, d) => sum + d.removed.length);
}

PlanDiff buildPlanDiff(
  List<({int dayOfWeek, String exerciseName})> current,
  ParsedPlan next,
) {
  final currentByDay = <int, List<String>>{};
  for (final row in current) {
    currentByDay.putIfAbsent(row.dayOfWeek, () => <String>[])
        .add(row.exerciseName);
  }

  final dayDiffs = <DayPlanDiff>[];
  for (var day = 1; day <= 7; day++) {
    final before = currentByDay[day] ?? const <String>[];
    final after = next.exercisesByDay[day] ?? const <String>[];
    final beforeSet = before.toSet();
    final afterSet = after.toSet();

    final added = [for (final n in after) if (!beforeSet.contains(n)) n];
    final removed = [for (final n in before) if (!afterSet.contains(n)) n];
    final kept = [for (final n in after) if (beforeSet.contains(n)) n];

    final diff = DayPlanDiff(
      day: day,
      added: added,
      removed: removed,
      kept: kept,
    );
    if (diff.changed) dayDiffs.add(diff);
  }

  return PlanDiff(days: dayDiffs, exerciseCount: next.exerciseCount);
}

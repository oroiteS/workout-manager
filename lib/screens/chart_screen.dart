import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)!.settings.arguments as ({int exerciseId, String exerciseName});
    final exerciseId = args.exerciseId;
    final exerciseName = args.exerciseName;
    final historyAsync = ref.watch(exerciseHistoryProvider(exerciseId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$exerciseName · 重量趋势'),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (_, ref, __) => IconButton(
              icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode, size: 20),
              onPressed: () => ref.read(themeModeProvider.notifier).update(
                (s) => s == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              ),
              tooltip: '切换主题',
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('v1.0.7', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Text(
                '暂无记录',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            );
          }

          final sorted = history.reversed.toList();
          final weights = sorted.map((s) => s.weight);
          final minW = weights.reduce(m.min);
          final maxW = weights.reduce(m.max);
          final firstDate = _dateOnly(sorted.first.trainedAt);
          final lastDate = _dateOnly(sorted.last.trainedAt);

          if (history.length >= 2) {
            return _buildWithChart(context, ref, exerciseId, sorted, minW, maxW, firstDate, lastDate);
          } else {
            return _buildListOnly(context, ref, exerciseId, sorted);
          }
        },
      ),
    );
  }

  Widget _buildWithChart(
    BuildContext context,
    WidgetRef ref,
    int exerciseId,
    List<TrainingRecordData> sorted,
    double minW,
    double maxW,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    final firstDay = _dateOnly(sorted.first.trainedAt);
    final spots = <FlSpot>[];
    for (final r in sorted) {
      final dayOffset = _dateOnly(r.trainedAt).difference(firstDay).inDays.toDouble();
      spots.add(FlSpot(dayOffset, r.weight));
    }

    final margin = m.max((maxW - minW) * 0.15, 2.5);
    final yMin = (minW - margin).floorToDouble();
    final yMax = (maxW + margin).ceilToDouble();
    final yInterval = _niceInterval(yMin, yMax);

    final first = sorted.first.weight;
    final last = sorted.last.weight;
    final change = last - first;
    final isUp = change > 0;
    final isDown = change < 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              minY: yMin,
              maxY: yMax,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withAlpha(40),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('日期', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  axisNameSize: 16,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _calcXInterval(firstDay, lastDate),
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      final date = firstDay.add(Duration(days: idx));
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('M/d').format(date),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('kg', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  axisNameSize: 16,
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: yInterval,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) => Text(
                      value == value.roundToDouble()
                          ? '${value.toInt()}'
                          : value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.withAlpha(80)),
                  bottom: BorderSide(color: Colors.grey.withAlpha(80)),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: Colors.blue,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) =>
                        FlDotCirclePainter(radius: 3, color: Colors.blue),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withAlpha(25),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} kg',
                        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildStats(
          sorted.length,
          maxW,
          minW,
          sorted.last.trainedAt,
          change: change,
          isUp: isUp,
          isDown: isDown,
        ),
        const SizedBox(height: 8),
        Text(
          '最近 ${sorted.length} 次训练 · ${DateFormat('M月d日').format(sorted.first.trainedAt)} → ${DateFormat('M月d日').format(sorted.last.trainedAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        Text('历史记录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        ...sorted.map((r) => GestureDetector(
          onLongPress: () => _showDeleteDialog(context, ref, exerciseId, r),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              title: Text('${r.weight} kg'),
              trailing: Text(
                DateFormat('yyyy-MM-dd').format(r.trainedAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              dense: true,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildListOnly(BuildContext context, WidgetRef ref, int exerciseId, List<TrainingRecordData> sorted) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStats(sorted.length, sorted.first.weight, sorted.first.weight, sorted.first.trainedAt),
        const SizedBox(height: 16),
        Text('历史记录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        ...sorted.map((r) => GestureDetector(
          onLongPress: () => _showDeleteDialog(context, ref, exerciseId, r),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 2),
            child: ListTile(
              title: Text('${r.weight} kg'),
              trailing: Text(
                DateFormat('yyyy-MM-dd').format(r.trainedAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              dense: true,
            ),
          ),
        )),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int exerciseId, TrainingRecordData record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定要删除 ${record.exerciseName} ${record.weight}kg 的记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(databaseProvider).recordDao.deleteById(record.id);
              ref.invalidate(exerciseHistoryProvider(exerciseId));
              ref.invalidate(recordsGroupedByDateProvider);
              ref.invalidate(recordDatesProvider);
              ref.invalidate(recordsForDateProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    int total,
    double maxWeight,
    double minWeight,
    DateTime lastTrained, {
    double? change,
    bool isUp = false,
    bool isDown = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (change != null) ...[
              Row(
                children: [
                  Text(
                    isUp
                        ? '\u{1F4C8} 增长了 ${change.toStringAsFixed(1)}kg'
                        : isDown
                            ? '\u{1F4C9} 下降了 ${(-change).toStringAsFixed(1)}kg'
                            : '\u{27A1}\u{FE0F} 重量保持不变',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isUp
                          ? Colors.green[700]
                          : isDown
                              ? Colors.red[700]
                              : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                _statItem('总次数', '$total'),
                _statItem('最大', '$maxWeight kg'),
                _statItem('最小', '$minWeight kg'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '最近训练：${DateFormat('M月d日').format(lastTrained)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

double _niceInterval(double min, double max) {
  final rough = (max - min) / 5;
  if (rough <= 0.5) return 0.5;
  if (rough <= 1) return 1;
  if (rough <= 2) return 2;
  if (rough <= 2.5) return 2.5;
  if (rough <= 5) return 5;
  if (rough <= 10) return 10;
  if (rough <= 25) return 25;
  return ((rough / 10).ceil() * 10).toDouble();
}

double _calcXInterval(DateTime firstDay, DateTime lastDay) {
  final totalDays = lastDay.difference(firstDay).inDays;
  if (totalDays <= 0) return 1;
  final ideal = totalDays / 6;
  return ideal <= 1 ? 1 : ideal.ceilToDouble();
}

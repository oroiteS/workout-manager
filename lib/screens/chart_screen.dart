// lib/screens/chart_screen.dart
import 'dart:math' as m;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:workout_manager/providers/workout_providers.dart';

class ChartScreen extends ConsumerWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseName = ModalRoute.of(context)!.settings.arguments as String;
    final historyAsync = ref.watch(exerciseHistoryProvider(exerciseName));

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
          if (history.length < 2) {
            return Center(
              child: Text(
                history.isEmpty ? '暂无记录' : '需要至少2次记录才能生成趋势',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            );
          }

          // earliest first
          final sorted = history.reversed.toList();

          // use days since first record as x, not array index
          final firstDay = _dateOnly(sorted.first.trainedAt);
          final spots = <FlSpot>[];
          for (final r in sorted) {
            final dayOffset =
                _dateOnly(r.trainedAt).difference(firstDay).inDays.toDouble();
            spots.add(FlSpot(dayOffset, r.weight));
          }

          // y-axis: dynamic range with padding
          final weights = sorted.map((s) => s.weight);
          final minW = weights.reduce(m.min);
          final maxW = weights.reduce(m.max);
          final margin = m.max((maxW - minW) * 0.15, 2.5);
          final yMin = (minW - margin).floorToDouble();
          final yMax = (maxW + margin).ceilToDouble();

          // y interval: ~5 grid lines
          final yInterval = _niceInterval(yMin, yMax);

          // Change summary
          final first = sorted.first.weight;
          final last = sorted.last.weight;
          final change = last - first;
          final isUp = change > 0;
          final isDown = change < 0;

          final lastDay = _dateOnly(sorted.last.trainedAt);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
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
                            interval: _calcXInterval(firstDay, lastDay),
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              // map day offset back to date
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUp
                        ? Colors.green.withAlpha(20)
                        : isDown
                            ? Colors.red.withAlpha(20)
                            : Colors.grey.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isUp
                            ? '📈 增长了 ${change.toStringAsFixed(1)}kg'
                            : isDown
                                ? '📉 下降了 ${(-change).toStringAsFixed(1)}kg'
                                : '➡️ 重量保持不变',
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
                ),
                const SizedBox(height: 8),
                Text(
                  '最近 ${sorted.length} 次训练 · ${DateFormat('M月d日').format(sorted.first.trainedAt)} → ${DateFormat('M月d日').format(sorted.last.trainedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// calculate a nice round interval for y-axis (e.g. 2.5, 5, 10)
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

// x-axis: at most ~7 ticks
double _calcXInterval(DateTime firstDay, DateTime lastDay) {
  final totalDays = lastDay.difference(firstDay).inDays;
  if (totalDays <= 0) return 1;
  final ideal = totalDays / 6;
  return ideal <= 1 ? 1 : ideal.ceilToDouble();
}

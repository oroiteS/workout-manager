// lib/screens/chart_screen.dart
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

          // Reverse: earliest first (chart goes left to right)
          final sorted = history.reversed.toList();
          final spots = <FlSpot>[];
          for (var i = 0; i < sorted.length; i++) {
            spots.add(FlSpot(i.toDouble(), sorted[i].weight));
          }

          // Calculate change
          final first = sorted.first.weight;
          final last = sorted.last.weight;
          final change = last - first;
          final isUp = change > 0;
          final isDown = change < 0;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Chart
                Expanded(
                  flex: 3,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < sorted.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    DateFormat('M/d').format(sorted[idx].trainedAt),
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 22,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) =>
                                FlDotCirclePainter(radius: 3, color: Colors.blue),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withAlpha(30),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots
                              .map((s) => LineTooltipItem(
                                    '${s.y} kg',
                                    const TextStyle(color: Colors.white, fontSize: 12),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Change summary
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
                            ? '📈 增长了 ${change.toStringAsFixed(1)}kg！'
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

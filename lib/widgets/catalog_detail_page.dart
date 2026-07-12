import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/catalog/filter_labels.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/catalog_browser.dart';

class CatalogDetailPage extends ConsumerWidget {
  final CatalogExercise exercise;
  final CatalogBrowserMode mode;
  final int? dayOfWeek;
  final void Function(CatalogExercise ex)? onAdded;

  const CatalogDetailPage({
    super.key,
    required this.exercise,
    this.mode = CatalogBrowserMode.browse,
    this.dayOfWeek,
    this.onAdded,
  });

  List<String> _decodeSteps(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  List<String> _decodeSecondary(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<void> _addToTemplate(BuildContext context, WidgetRef ref) async {
    final day = dayOfWeek;
    if (day == null) return;
    try {
      final db = ref.read(databaseProvider);
      await db.templateDao.addExercise(
        day,
        exercise.nameZh,
        datasetId: exercise.datasetId,
      );
      ref.invalidate(templateProvider);
      ref.invalidate(templateByDayProvider(day));
      ref.invalidate(todayExercisesProvider);
      onAdded?.call(exercise);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加「${exercise.nameZh}」')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = _decodeSteps(exercise.instructionStepsZh);
    final secondary = _decodeSecondary(exercise.secondaryMuscles);
    final meta =
        '${labelBodyPart(exercise.bodyPart)} · ${labelEquipment(exercise.equipment)} · ${labelTarget(exercise.target)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.nameZh),
        centerTitle: true,
      ),
      floatingActionButton: mode == CatalogBrowserMode.pick
          ? FloatingActionButton.extended(
              onPressed: () => _addToTemplate(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('加入模板'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                exercise.gifAsset,
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 280,
                  height: 280,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Text('无', style: TextStyle(color: Colors.grey[500])),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.nameZh,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (exercise.nameEn.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              exercise.nameEn,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 8),
          Text(meta, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '次要肌群：${secondary.map(labelTarget).join('、')}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          if (exercise.instructionsZh.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '说明',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(exercise.instructionsZh),
          ],
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              '步骤',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...List.generate(steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(steps[i])),
                  ],
                ),
              );
            }),
          ],
          if (mode == CatalogBrowserMode.pick) const SizedBox(height: 72),
        ],
      ),
    );
  }
}

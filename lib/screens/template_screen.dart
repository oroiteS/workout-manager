// lib/screens/template_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/day_template_card.dart';

const _dayLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

class TemplateScreen extends ConsumerWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(templateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('周训练模板'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('v1.0.3', style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
        ],
      ),
      body: templateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (allTemplates) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = index + 1;
              final dayExercises = allTemplates
                  .where((t) => t.dayOfWeek == day)
                  .map((t) => t.exerciseName)
                  .toList();

              return DayTemplateCard(
                dayLabel: _dayLabels[index],
                dayOfWeek: day,
                exercises: dayExercises,
                onAdd: () async {
                  final controller = TextEditingController();
                  final name = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('为${_dayLabels[index]}添加动作'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: '动作名称',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final text = controller.text.trim();
                            if (text.isNotEmpty) Navigator.pop(ctx, text);
                          },
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                  );
                  controller.dispose();
                  if (name != null && name.isNotEmpty) {
                    try {
                      final db = ref.read(databaseProvider);
                      await db.templateDao.addExercise(day, name);
                      ref.invalidate(templateProvider);
                      ref.invalidate(templateByDayProvider(day));
                      ref.invalidate(todayExercisesProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  }
                },
                onDelete: (name) async {
                  try {
                    final db = ref.read(databaseProvider);
                    await db.templateDao.deleteExercise(day, name);
                    ref.invalidate(templateProvider);
                    ref.invalidate(templateByDayProvider(day));
                    ref.invalidate(todayExercisesProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

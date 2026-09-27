import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/catalog_browser.dart';
import 'package:workout_manager/widgets/catalog_browser_mode.dart';
import 'package:workout_manager/widgets/pick_target.dart';

/// 通用「添加动作」流程：动作库选择或自定义名称，写入 [pickTarget] 指向的模板。
Future<void> showAddExerciseFlow(
  BuildContext context,
  WidgetRef ref, {
  required PickTarget pickTarget,
  required String dayLabel,
}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('从动作库选择'),
            onTap: () => Navigator.pop(ctx, 'catalog'),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('自定义名称'),
            onTap: () => Navigator.pop(ctx, 'custom'),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return;

  if (choice == 'catalog') {
    final previousQuery = ref.read(catalogQueryProvider);
    ref.read(catalogQueryProvider.notifier).state = CatalogQuery.empty();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('从动作库选择'),
          ),
          body: CatalogBrowser(
            mode: CatalogBrowserMode.pick,
            pickTarget: pickTarget,
          ),
        ),
      ),
    );
    ref.read(catalogQueryProvider.notifier).state = previousQuery;
    return;
  }

  if (choice == 'custom') {
    await _addCustom(context, ref, pickTarget, dayLabel);
  }
}

Future<void> _addCustom(
  BuildContext context,
  WidgetRef ref,
  PickTarget pickTarget,
  String dayLabel,
) async {
  String prefill = '';
  while (true) {
    if (!context.mounted) return;
    final controller = TextEditingController(text: prefill);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('为$dayLabel添加动作'),
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
    if (name == null || name.isEmpty || !context.mounted) return;

    try {
      final db = ref.read(databaseProvider);
      final hit = await db.catalogDao.findByNameZh(name);
      if (hit != null) {
        if (!context.mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('合并动作'),
            content: Text('库中已有「$name」，合并并显示示意图？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('合并'),
              ),
            ],
          ),
        );
        if (ok != true) {
          prefill = name;
          continue;
        }
        await addExerciseToTarget(
          ref,
          pickTarget,
          hit.nameZh,
          datasetId: hit.datasetId,
        );
      } else {
        await addExerciseToTarget(ref, pickTarget, name);
      }
      return;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
        );
      }
      return;
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/catalog/filter_labels.dart';
import 'package:workout_manager/database/database.dart';
import 'package:workout_manager/providers/workout_providers.dart';
import 'package:workout_manager/widgets/catalog_detail_page.dart';
import 'package:workout_manager/widgets/catalog_filter_sheets.dart';

enum CatalogBrowserMode { browse, pick }

class CatalogBrowser extends ConsumerStatefulWidget {
  final CatalogBrowserMode mode;
  final int? dayOfWeek;
  final void Function(CatalogExercise ex)? onAdded;

  const CatalogBrowser({
    super.key,
    this.mode = CatalogBrowserMode.browse,
    this.dayOfWeek,
    this.onAdded,
  });

  @override
  ConsumerState<CatalogBrowser> createState() => _CatalogBrowserState();
}

class _CatalogBrowserState extends ConsumerState<CatalogBrowser> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = ref.read(catalogQueryProvider);
      if (q.search == value) return;
      ref.read(catalogQueryProvider.notifier).state = q.copyWith(search: value);
    });
  }

  Future<void> _openFilter() async {
    final db = ref.read(databaseProvider);
    final bodyParts = await db.catalogDao.distinctBodyParts();
    final equipments = await db.catalogDao.distinctEquipments();
    final targets = await db.catalogDao.distinctTargets();
    if (!mounted) return;
    final current = ref.read(catalogQueryProvider);
    final result = await showCatalogFilterSheet(
      context,
      current,
      bodyParts: bodyParts,
      equipments: equipments,
      targets: targets,
    );
    if (result != null && mounted) {
      ref.read(catalogQueryProvider.notifier).state = result.copyWith(
        search: ref.read(catalogQueryProvider).search,
      );
    }
  }

  Future<void> _addExercise(CatalogExercise ex) async {
    final day = widget.dayOfWeek;
    if (day == null) return;
    try {
      final db = ref.read(databaseProvider);
      await db.templateDao.addExercise(day, ex.nameZh, datasetId: ex.datasetId);
      ref.invalidate(templateProvider);
      ref.invalidate(templateByDayProvider(day));
      ref.invalidate(todayExercisesProvider);
      widget.onAdded?.call(ex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已添加「${ex.nameZh}」')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openDetail(CatalogExercise ex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogDetailPage(
          exercise: ex,
          mode: widget.mode,
          dayOfWeek: widget.dayOfWeek,
          onAdded: widget.onAdded,
        ),
      ),
    );
  }

  Widget _errorView(Object error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(catalogBootstrapProvider);
    final results = ref.watch(catalogResultsProvider);
    final query = ref.watch(catalogQueryProvider);

    if (bootstrap.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bootstrap.hasError) {
      return _errorView(bootstrap.error!, () {
        ref.invalidate(catalogBootstrapProvider);
        ref.invalidate(catalogResultsProvider);
      });
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '搜索动作',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Badge(
                  isLabelVisible: query.bodyParts.isNotEmpty ||
                      query.equipments.isNotEmpty ||
                      query.targets.isNotEmpty,
                  child: const Icon(Icons.filter_list),
                ),
                tooltip: '筛选',
                onPressed: _openFilter,
              ),
            ],
          ),
        ),
        if (query.bodyParts.isNotEmpty ||
            query.equipments.isNotEmpty ||
            query.targets.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...query.bodyParts.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(labelBodyPart(k)),
                      onDeleted: () {
                        final next = {...query.bodyParts}..remove(k);
                        ref.read(catalogQueryProvider.notifier).state =
                            query.copyWith(bodyParts: next);
                      },
                    ),
                  ),
                ),
                ...query.equipments.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(labelEquipment(k)),
                      onDeleted: () {
                        final next = {...query.equipments}..remove(k);
                        ref.read(catalogQueryProvider.notifier).state =
                            query.copyWith(equipments: next);
                      },
                    ),
                  ),
                ),
                ...query.targets.map(
                  (k) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(labelTarget(k)),
                      onDeleted: () {
                        final next = {...query.targets}..remove(k);
                        ref.read(catalogQueryProvider.notifier).state =
                            query.copyWith(targets: next);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: results.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorView(e, () {
              ref.invalidate(catalogResultsProvider);
            }),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    '没有匹配的动作',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final ex = list[index];
                  final subtitle =
                      '${labelBodyPart(ex.bodyPart)} · ${labelEquipment(ex.equipment)} · ${labelTarget(ex.target)}';
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        ex.gifAsset,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Text(
                            '无',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: Text(ex.nameZh),
                    subtitle: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: widget.mode == CatalogBrowserMode.pick
                        ? IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: '加入模板',
                            onPressed: () => _addExercise(ex),
                          )
                        : const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _openDetail(ex),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

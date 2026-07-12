import 'dart:convert';

import 'package:drift/drift.dart';
import 'database.dart';

part 'catalog_dao.g.dart';

@DriftAccessor(tables: [CatalogExercises, AppMeta])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.attachedDatabase);

  static const versionKey = 'catalog_version';

  Future<int> getCatalogVersion() async {
    final row = await (select(appMeta)..where((t) => t.key.equals(versionKey)))
        .getSingleOrNull();
    if (row == null) return 0;
    return int.tryParse(row.value) ?? 0;
  }

  Future<void> _setCatalogVersion(int version) async {
    await into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion.insert(key: versionKey, value: '$version'),
    );
  }

  Future<int> countRows() async {
    final rows = await select(catalogExercises).get();
    return rows.length;
  }

  Future<void> importCatalog(Map<String, dynamic> root) async {
    final version = (root['catalog_version'] as num?)?.toInt() ?? 1;
    final list = (root['exercises'] as List<dynamic>? ?? const []);

    await transaction(() async {
      await delete(catalogExercises).go();
      for (final raw in list) {
        final m = Map<String, dynamic>.from(raw as Map);
        final secondary = m['secondary_muscles'] ?? const [];
        final steps = m['instruction_steps_zh'] ?? const [];
        await into(catalogExercises).insert(
          CatalogExercisesCompanion.insert(
            datasetId: m['dataset_id'] as String,
            nameEn: m['name_en'] as String? ?? '',
            nameZh: m['name_zh'] as String? ?? '',
            bodyPart: m['body_part'] as String? ?? '',
            equipment: m['equipment'] as String? ?? '',
            target: m['target'] as String? ?? '',
            muscleGroup: m['muscle_group'] as String? ?? '',
            secondaryMuscles: jsonEncode(secondary),
            instructionsZh: m['instructions_zh'] as String? ?? '',
            instructionStepsZh: jsonEncode(steps),
            gifAsset: m['gif_asset'] as String? ?? '',
          ),
        );
      }
      await _setCatalogVersion(version);
    });
  }

  Future<List<CatalogExercise>> getAll() {
    return (select(catalogExercises)
          ..orderBy([(t) => OrderingTerm.asc(t.nameZh)]))
        .get();
  }

  Future<CatalogExercise?> getByDatasetId(String id) {
    return (select(catalogExercises)..where((t) => t.datasetId.equals(id)))
        .getSingleOrNull();
  }

  Future<CatalogExercise?> findByNameZh(String name) async {
    final rows = await (select(catalogExercises)
          ..where((t) => t.nameZh.equals(name))
          ..orderBy([(t) => OrderingTerm.asc(t.datasetId)]))
        .get();
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<CatalogExercise>> query({
    required String search,
    required Set<String> bodyParts,
    required Set<String> equipments,
    required Set<String> targets,
  }) async {
    final all = await getAll();
    final q = search.trim().toLowerCase();
    return all.where((e) {
      if (bodyParts.isNotEmpty && !bodyParts.contains(e.bodyPart)) return false;
      if (equipments.isNotEmpty && !equipments.contains(e.equipment)) {
        return false;
      }
      if (targets.isNotEmpty && !targets.contains(e.target)) return false;
      if (q.isEmpty) return true;
      return e.nameZh.toLowerCase().contains(q) ||
          e.nameEn.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<String>> distinctBodyParts() async {
    final rows = await getAll();
    return rows.map((e) => e.bodyPart).where((e) => e.isNotEmpty).toSet().toList()
      ..sort();
  }

  Future<List<String>> distinctEquipments() async {
    final rows = await getAll();
    return rows.map((e) => e.equipment).where((e) => e.isNotEmpty).toSet().toList()
      ..sort();
  }

  Future<List<String>> distinctTargets() async {
    final rows = await getAll();
    return rows.map((e) => e.target).where((e) => e.isNotEmpty).toSet().toList()
      ..sort();
  }
}

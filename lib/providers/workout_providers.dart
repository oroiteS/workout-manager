import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_manager/database/database.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final catalogBootstrapProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  final raw = await rootBundle.loadString('assets/exercises/catalog.json');
  final root = jsonDecode(raw) as Map<String, dynamic>;
  final assetVersion = (root['catalog_version'] as num?)?.toInt() ?? 1;
  final dbVersion = await db.catalogDao.getCatalogVersion();
  final count = await db.catalogDao.countRows();
  if (dbVersion < assetVersion || count == 0) {
    await db.catalogDao.importCatalog(root);
  }
});

class CatalogQuery {
  final String search;
  final Set<String> bodyParts;
  final Set<String> equipments;
  final Set<String> targets;

  const CatalogQuery({
    this.search = '',
    this.bodyParts = const {},
    this.equipments = const {},
    this.targets = const {},
  });

  factory CatalogQuery.empty() => const CatalogQuery();

  CatalogQuery copyWith({
    String? search,
    Set<String>? bodyParts,
    Set<String>? equipments,
    Set<String>? targets,
  }) {
    return CatalogQuery(
      search: search ?? this.search,
      bodyParts: bodyParts ?? this.bodyParts,
      equipments: equipments ?? this.equipments,
      targets: targets ?? this.targets,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CatalogQuery &&
        other.search == search &&
        _setEquals(other.bodyParts, bodyParts) &&
        _setEquals(other.equipments, equipments) &&
        _setEquals(other.targets, targets);
  }

  @override
  int get hashCode => Object.hash(
        search,
        Object.hashAllUnordered(bodyParts),
        Object.hashAllUnordered(equipments),
        Object.hashAllUnordered(targets),
      );
}

bool _setEquals(Set<String> a, Set<String> b) {
  if (a.length != b.length) return false;
  for (final e in a) {
    if (!b.contains(e)) return false;
  }
  return true;
}

final catalogQueryProvider =
    StateProvider<CatalogQuery>((_) => CatalogQuery.empty());

final catalogResultsProvider = FutureProvider<List<CatalogExercise>>((ref) async {
  await ref.watch(catalogBootstrapProvider.future);
  final q = ref.watch(catalogQueryProvider);
  return ref.watch(databaseProvider).catalogDao.query(
        search: q.search,
        bodyParts: q.bodyParts,
        equipments: q.equipments,
        targets: q.targets,
      );
});

final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.exerciseDao.getAll();
});

final todayExercisesProvider = FutureProvider<List<TemplateWithExercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  final weekday = DateTime.now().weekday;
  return db.templateDao.getByDay(weekday);
});

final lastWeightsProvider = FutureProvider.family<double?, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastWeight(exerciseId);
});

final lastTrainedDateProvider = FutureProvider.family<DateTime?, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getLastTrainedAt(exerciseId);
});

final templateProvider = FutureProvider<List<TemplateWithExercise>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getAll();
});

final templateByDayProvider = FutureProvider.family<List<TemplateWithExercise>, int>((ref, day) async {
  final db = ref.watch(databaseProvider);
  return db.templateDao.getByDay(day);
});

final saveRecordsProvider = FutureProvider.family<void, Map<int, ({String name, double weight})>>((ref, records) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  for (final entry in records.entries) {
    await db.recordDao.upsertRecord(entry.key, entry.value.name, entry.value.weight, now);
  }
  ref.invalidate(lastWeightsProvider);
  ref.invalidate(lastTrainedDateProvider);
  ref.invalidate(exerciseHistoryProvider);
  ref.invalidate(recordsGroupedByDateProvider);
  ref.invalidate(recordDatesProvider);
  ref.invalidate(recordsForDateProvider);
});

final deleteRecordProvider = FutureProvider.family<void, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  await db.recordDao.deleteById(id);
  ref.invalidate(exerciseHistoryProvider);
  ref.invalidate(recordsGroupedByDateProvider);
  ref.invalidate(recordDatesProvider);
  ref.invalidate(recordsForDateProvider);
});

final recordsGroupedByDateProvider = FutureProvider<List<TrainingRecordData>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordsGroupedByDate(limit: 50);
});

final exerciseHistoryProvider =
    FutureProvider.family<List<TrainingRecordData>, int>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getHistory(exerciseId, limit: 20);
});

final recordDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordDates();
});

final recordsForDateProvider = FutureProvider.family<List<TrainingRecordData>, DateTime>((ref, date) async {
  final db = ref.watch(databaseProvider);
  return db.recordDao.getRecordsForDate(date);
});

final saveRecordsForDateProvider =
    FutureProvider.family<void, ({DateTime date, Map<int, ({String name, double weight})> records})>(
  (ref, params) async {
    final db = ref.watch(databaseProvider);
    for (final entry in params.records.entries) {
      await db.recordDao.upsertRecord(entry.key, entry.value.name, entry.value.weight, params.date);
    }
    ref.invalidate(lastWeightsProvider);
    ref.invalidate(lastTrainedDateProvider);
    ref.invalidate(exerciseHistoryProvider);
    ref.invalidate(recordsGroupedByDateProvider);
    ref.invalidate(recordDatesProvider);
    ref.invalidate(recordsForDateProvider);
  },
);

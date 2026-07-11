import 'package:flutter_test/flutter_test.dart';
import 'package:workout_manager/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createMemoryDb();
  });

  tearDown(() async => await db.close());

  Map<String, dynamic> sampleCatalog() => {
        'catalog_version': 1,
        'exercises': [
          {
            'dataset_id': '0001',
            'name_en': 'Bench Press',
            'name_zh': '杠铃卧推',
            'body_part': 'chest',
            'equipment': 'barbell',
            'target': 'pectorals',
            'muscle_group': 'chest',
            'secondary_muscles': ['triceps', 'delts'],
            'instructions_zh': '说明',
            'instruction_steps_zh': ['步骤1', '步骤2'],
            'gif_asset': 'assets/exercises/gifs/0001.gif',
          },
          {
            'dataset_id': '0002',
            'name_en': 'Squat',
            'name_zh': '深蹲',
            'body_part': 'upper legs',
            'equipment': 'barbell',
            'target': 'quads',
            'muscle_group': 'quads',
            'secondary_muscles': ['glutes'],
            'instructions_zh': '说明2',
            'instruction_steps_zh': ['a'],
            'gif_asset': 'assets/exercises/gifs/0002.gif',
          },
        ],
      };

  test('importCatalog 写入全部条目与 version', () async {
    await db.catalogDao.importCatalog(sampleCatalog());
    final all = await db.catalogDao.getAll();
    expect(all.length, 2);
    expect(await db.catalogDao.getCatalogVersion(), 1);
    expect(all.first.nameZh, anyOf('杠铃卧推', '深蹲'));
    expect(all.map((e) => e.nameZh), containsAll(['杠铃卧推', '深蹲']));
  });

  test('search contains name_zh', () async {
    await db.catalogDao.importCatalog(sampleCatalog());
    final r = await db.catalogDao.query(
      search: '卧推',
      bodyParts: {},
      equipments: {},
      targets: {},
    );
    expect(r.length, 1);
    expect(r.first.datasetId, '0001');
  });

  test('filters AND 叠加', () async {
    await db.catalogDao.importCatalog(sampleCatalog());
    final r = await db.catalogDao.query(
      search: '',
      bodyParts: {'chest'},
      equipments: {'barbell'},
      targets: {'pectorals'},
    );
    expect(r.map((e) => e.datasetId), ['0001']);
  });

  test('findByNameZh 精确匹配', () async {
    await db.catalogDao.importCatalog(sampleCatalog());
    final hit = await db.catalogDao.findByNameZh('深蹲');
    expect(hit?.datasetId, '0002');
    expect(await db.catalogDao.findByNameZh('不存在'), isNull);
  });
}

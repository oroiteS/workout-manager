# Exercise Catalog & Diagram Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 exercises-dataset 以 assets 打包进 App，catalog 导入 SQLite，新增「示意图」Tab 与周模板「现有/自定义」选动作流程（含 GIF、筛选、C1 同名合并）。

**Architecture:** 本地脚本从 `exercises-dataset/` 生成 `assets/exercises/catalog.json` + 全量 GIF；App 首次启动把 catalog 写入 `catalog_exercises` 表；用户动作表 `exercises` 增加可空 `datasetId`；百科与「现有」共用 `CatalogBrowser`（browse/pick 模式）。

**Tech Stack:** Flutter + Drift ^2.24 + Riverpod ^2.6 + 现有 Material 3；资源生成用 Python3；中文名离线写入 catalog。

**Spec:** `docs/superpowers/specs/2026-07-11-exercise-catalog-design.md`

---

## File Structure

| Path | Responsibility |
|------|----------------|
| `tool/prepare_exercise_assets.py` | 从 dataset 生成 catalog.json + 拷贝 gifs |
| `tool/names_zh.json` | `dataset_id → 中文名`（离线生成，脚本合并） |
| `tool/filter_labels_zh.json` | body_part/equipment/target 英文→中文 |
| `assets/exercises/catalog.json` | 运行时导入源（含 catalog_version） |
| `assets/exercises/gifs/{id}.gif` | 全量 GIF |
| `lib/database/database.dart` | 表：`CatalogExercises`、`AppMeta`；`Exercises.datasetId`；schemaVersion=3 |
| `lib/database/catalog_dao.dart` | 导入 + 搜索/筛选查询 |
| `lib/database/exercise_dao.dart` | ensure/bind datasetId |
| `lib/database/template_dao.dart` | `addExercise` 支持 datasetId |
| `lib/catalog/filter_labels.dart` | 筛选项中文标签 |
| `lib/providers/workout_providers.dart` | catalog 导入触发、查询 providers |
| `lib/widgets/catalog_browser.dart` | 共用列表+搜索+筛选入口 |
| `lib/widgets/catalog_filter_sheets.dart` | 一级/二级筛选弹窗 |
| `lib/widgets/catalog_detail_page.dart` | 详情（GIF+步骤） |
| `lib/screens/catalog_screen.dart` | 示意图 Tab |
| `lib/screens/template_screen.dart` | + 现有/自定义 + C1 |
| `lib/main.dart` | 第 4 Tab |
| `pubspec.yaml` | assets + version |
| `.gitignore` | `exercises-dataset/` |
| `test/database/catalog_dao_test.dart` | 导入/筛选/搜索 |
| `test/database/exercise_dao_test.dart` | ensure + C1 绑定 |

---

### Task 1: 资源管线脚本 + 中文名与标签

**Files:**
- Create: `tool/prepare_exercise_assets.py`
- Create: `tool/filter_labels_zh.json`
- Create: `tool/names_zh.json`（1324 条；实现时 subagent/批量生成）
- Create: `assets/exercises/`（由脚本输出）
- Modify: `.gitignore`

- [ ] **Step 1: 修正 `.gitignore`**

将错误的 `exercise-dataset/` 改为（或追加）正确路径：

```
# 原始动作库 clone（不进主仓；使用处理后的 assets/exercises）
exercises-dataset/
```

保留已跟踪的 `docs/superpowers/**` 不受影响（`docs/` 虽 ignore，spec/plan 用 `git add -f`）。

- [ ] **Step 2: 写入 `tool/filter_labels_zh.json`**

完整映射（body_part 10 + equipment 全部 + target 全部），至少包含：

```json
{
  "body_part": {
    "upper arms": "上臂",
    "upper legs": "大腿",
    "back": "背部",
    "waist": "腰腹",
    "chest": "胸部",
    "shoulders": "肩部",
    "lower legs": "小腿",
    "lower arms": "前臂",
    "cardio": "有氧",
    "neck": "颈部"
  },
  "equipment": {
    "body weight": "自重",
    "dumbbell": "哑铃",
    "cable": "绳索",
    "barbell": "杠铃",
    "leverage machine": "杠杆器械",
    "band": "弹力带",
    "smith machine": "史密斯机",
    "kettlebell": "壶铃",
    "weighted": "负重",
    "stability ball": "稳定球",
    "ez barbell": "弯杆杠铃",
    "assisted": "辅助",
    "sled machine": "雪橇机",
    "medicine ball": "药球",
    "rope": "绳",
    "roller": "滚筒",
    "resistance band": "阻力带",
    "bosu ball": "BOSU 球",
    "olympic barbell": "奥杆",
    "wheel roller": "健腹轮",
    "upper body ergometer": "上肢功率车",
    "skierg machine": "滑雪机",
    "hammer": "锤",
    "stationary bike": "固定单车",
    "tire": "轮胎",
    "trap bar": "六角杠",
    "elliptical machine": "椭圆机",
    "stepmill machine": "台阶机"
  },
  "target": {
    "abs": "腹肌",
    "pectorals": "胸肌",
    "biceps": "肱二头肌",
    "glutes": "臀肌",
    "delts": "三角肌",
    "triceps": "肱三头肌",
    "upper back": "上背",
    "lats": "背阔肌",
    "calves": "小腿",
    "quads": "股四头肌",
    "forearms": "前臂",
    "cardiovascular system": "心血管系统",
    "hamstrings": "腘绳肌",
    "spine": "脊柱",
    "traps": "斜方肌",
    "adductors": "内收肌",
    "serratus anterior": "前锯肌",
    "abductors": "外展肌",
    "levator scapulae": "肩胛提肌"
  }
}
```

未映射的值 UI 回退显示英文原文。

- [ ] **Step 3: 生成 `tool/names_zh.json`**

格式：

```json
{
  "0001": "3/4 仰卧起坐",
  "0002": "……"
}
```

要求：
- 覆盖 `exercises-dataset/data/exercises.json` 全部 `id`
- 用 subagent **分批**翻译（建议每批 80–100 条），合并为一份 JSON
- 健身术语优先常用中文（卧推、硬拉、划船、深蹲等）
- 生成后脚本校验：`len(names)==len(exercises)` 且无空字符串

若某次会话无法一次生成全部，允许提交「英文回退」临时名（`name_zh = name_en`），但必须在后续任务补全前在 PR/提交说明中标注；**理想状态是 Task 1 结束时 1324 条均有中文**。

- [ ] **Step 4: 编写并运行 `tool/prepare_exercise_assets.py`**

脚本行为：
1. 读 `exercises-dataset/data/exercises.json`
2. 读 `tool/names_zh.json`、`tool/filter_labels_zh.json`（labels 仅校验用，可复制进 catalog 可选字段）
3. 输出 `assets/exercises/catalog.json`：

```json
{
  "catalog_version": 1,
  "exercises": [
    {
      "dataset_id": "0001",
      "name_en": "3/4 sit-up",
      "name_zh": "3/4 仰卧起坐",
      "body_part": "waist",
      "equipment": "body weight",
      "target": "abs",
      "muscle_group": "hip flexors",
      "secondary_muscles": ["hip flexors", "lower back"],
      "instructions_zh": "……",
      "instruction_steps_zh": ["……"],
      "gif_asset": "assets/exercises/gifs/0001.gif"
    }
  ]
}
```

4. 将 `exercises-dataset/videos/{id}-*.gif` 复制为 `assets/exercises/gifs/{id}.gif`（按 id 前缀匹配）
5. 打印统计：条数、缺失 gif、缺失中文名

运行：

```bash
python3 tool/prepare_exercise_assets.py
```

Expected: `catalog.json` 约 1324 条；`assets/exercises/gifs/` 约 1324 个文件。

- [ ] **Step 5: Commit 脚本与生成物（assets 体积大，可分 commit）**

```bash
git add -f tool/prepare_exercise_assets.py tool/filter_labels_zh.json tool/names_zh.json
git add -f assets/exercises/catalog.json
# gifs 可能很大，确认后再 add
git add -f assets/exercises/gifs
git add .gitignore
git commit -m "chore: add exercise catalog assets pipeline and generated assets"
```

---

### Task 2: pubspec assets + 版本占位

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 声明 assets**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/exercises/catalog.json
    - assets/exercises/gifs/
```

- [ ] **Step 2: 版本升到 `1.1.0+11`（功能版本）**

```yaml
version: 1.1.0+11
```

（四个旧 screen + 新 catalog screen 的 AppBar `v1.1.0` 在 Task 10 一并改，避免中途 UI 半更新。）

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: register exercise catalog assets and bump version base"
```

---

### Task 3: Drift 表结构 schemaVersion=3

**Files:**
- Modify: `lib/database/database.dart`
- Regenerate: `lib/database/*.g.dart`

- [ ] **Step 1: 扩展表定义**

在 `database.dart` 中：

```dart
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get datasetId => text().nullable()();
}

class CatalogExercises extends Table {
  TextColumn get datasetId => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameZh => text()();
  TextColumn get bodyPart => text()();
  TextColumn get equipment => text()();
  TextColumn get target => text()();
  TextColumn get muscleGroup => text()();
  TextColumn get secondaryMuscles => text()(); // JSON array string
  TextColumn get instructionsZh => text()();
  TextColumn get instructionStepsZh => text()(); // JSON array string
  TextColumn get gifAsset => text()();

  @override
  Set<Column> get primaryKey => {datasetId};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

`@DriftDatabase(tables: [Exercises, WeekTemplate, TrainingRecord, CatalogExercises, AppMeta])`  
`schemaVersion => 3`  
getter：`catalogDao`。

- [ ] **Step 2: 运行代码生成**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 成功生成 `catalog_dao.g.dart` 等（DAO 文件可先空壳再生成，或先写 DAO 再生成）。

- [ ] **Step 3: 修复因 `ExercisesCompanion.insert` 签名变化导致的编译错误**

`ExercisesCompanion.insert(name: x)` 仍合法；`datasetId` 可空默认不传。

- [ ] **Step 4: Commit**

```bash
git add lib/database/
git commit -m "feat(db): add catalog_exercises, app_meta, exercises.datasetId (v3)"
```

---

### Task 4: CatalogDao — 导入与查询（TDD）

**Files:**
- Create: `lib/database/catalog_dao.dart`
- Create: `test/database/catalog_dao_test.dart`
- Modify: `lib/database/database.dart`（export / getter）

- [ ] **Step 1: 写失败测试**

```dart
// test/database/catalog_dao_test.dart
import 'dart:convert';
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
    expect(all.first.nameZh, '杠铃卧推');
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
```

- [ ] **Step 2: 运行测试确认失败**

```bash
flutter test test/database/catalog_dao_test.dart
```

Expected: FAIL（CatalogDao 不存在或方法缺失）

- [ ] **Step 3: 实现 CatalogDao**

关键 API：

```dart
@DriftAccessor(tables: [CatalogExercises, AppMeta])
class CatalogDao extends DatabaseAccessor<AppDatabase> with _$CatalogDaoMixin {
  CatalogDao(super.db);

  static const versionKey = 'catalog_version';

  Future<int> getCatalogVersion() async { /* AppMeta 读 int，缺省 0 */ }

  Future<void> importCatalog(Map<String, dynamic> root) async {
    // transaction: delete all catalog; insert each; upsert meta version
  }

  Future<List<CatalogExercise>> getAll() => select(catalogExercises).get();

  Future<CatalogExercise?> getByDatasetId(String id);

  Future<CatalogExercise?> findByNameZh(String name);

  /// search: trim 后对 nameZh / nameEn 做 like '%q%'（或 Dart 侧 contains）
  /// 集合空 = 该维度不限制；多值同一维度用 OR，维度间 AND
  Future<List<CatalogExercise>> query({
    required String search,
    required Set<String> bodyParts,
    required Set<String> equipments,
    required Set<String> targets,
  });

  Future<List<String>> distinctBodyParts();
  Future<List<String>> distinctEquipments();
  Future<List<String>> distinctTargets();
}
```

`secondaryMuscles` / `instructionStepsZh` 入库时 `jsonEncode`。

- [ ] **Step 4: build_runner + 测试通过**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/database/catalog_dao_test.dart
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/database/catalog_dao.dart lib/database/catalog_dao.g.dart lib/database/database.dart lib/database/database.g.dart test/database/catalog_dao_test.dart
git commit -m "feat(db): catalog import and filtered query DAO"
```

---

### Task 5: ExerciseDao / TemplateDao 绑定 datasetId（TDD）

**Files:**
- Modify: `lib/database/exercise_dao.dart`
- Modify: `lib/database/template_dao.dart`
- Create: `test/database/exercise_dao_test.dart`
- Modify: `test/database/template_dao_test.dart`（若签名变）

- [ ] **Step 1: 写 ExerciseDao 测试**

```dart
test('ensureLinked 新建并写入 datasetId', () async {
  final id = await db.exerciseDao.ensureExercise(
    name: '杠铃卧推',
    datasetId: '0001',
  );
  final e = await db.exerciseDao.getById(id);
  expect(e!.name, '杠铃卧推');
  expect(e.datasetId, '0001');
});

test('ensureLinked 同名已存在则复用并补全 datasetId', () async {
  final id1 = await db.exerciseDao.ensureExercise(name: '深蹲', datasetId: null);
  final id2 = await db.exerciseDao.ensureExercise(name: '深蹲', datasetId: '0002');
  expect(id1, id2);
  expect((await db.exerciseDao.getById(id1))!.datasetId, '0002');
});

test('ensure 自定义无 datasetId', () async {
  final id = await db.exerciseDao.ensureExercise(name: '我的动作', datasetId: null);
  expect((await db.exerciseDao.getById(id))!.datasetId, isNull);
});
```

规则：
- 按 **精确 name** 查找
- 不存在 → insert
- 存在且传入非空 `datasetId` → 若行上 `datasetId` 为空则 update 绑定；若已有不同 datasetId，保持已有 id（C1 下同名不应指向两个库条目；以 name 为准）

- [ ] **Step 2: TemplateDao.addExercise 扩展**

```dart
Future<void> addExercise(
  int dayOfWeek,
  String exerciseName, {
  String? datasetId,
}) async {
  final exerciseId = await attachedDatabase.exerciseDao.ensureExercise(
    name: exerciseName,
    datasetId: datasetId,
  );
  await into(weekTemplate).insert(
    WeekTemplateCompanion.insert(dayOfWeek: dayOfWeek, exerciseId: exerciseId),
    mode: InsertMode.insertOrReplace,
  );
}
```

- [ ] **Step 3: 测试通过 + Commit**

```bash
flutter test test/database/exercise_dao_test.dart test/database/template_dao_test.dart
git add lib/database/exercise_dao.dart lib/database/template_dao.dart lib/database/*.g.dart test/database/
git commit -m "feat(db): ensure exercise with optional datasetId for templates"
```

---

### Task 6: 启动时导入 catalog + Providers

**Files:**
- Modify: `lib/providers/workout_providers.dart`
- Modify: `lib/main.dart`（确保导入完成后再进主页，或主页 watch 导入状态）
- Create: `lib/catalog/filter_labels.dart`

- [ ] **Step 1: `filter_labels.dart`**

从 `tool/filter_labels_zh.json` 内容硬编码为 Dart `const` map（或 `rootBundle` 加载同一 json 若复制到 assets）。推荐 **Dart const** 避免多一次 IO：

```dart
String labelBodyPart(String en) => kBodyPartZh[en] ?? en;
// equipment / target 同理
```

- [ ] **Step 2: catalogBootstrapProvider**

```dart
final catalogBootstrapProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  // 1. load asset catalog.json via rootBundle
  // 2. parse version
  // 3. if db version < asset version OR catalog empty -> catalogDao.importCatalog
});
```

测试环境：单元测试不走 bootstrap；widget 测试可 override。

- [ ] **Step 3: 查询 providers**

```dart
class CatalogQuery {
  final String search;
  final Set<String> bodyParts;
  final Set<String> equipments;
  final Set<String> targets;
  // == hashCode
}

final catalogQueryProvider = StateProvider<CatalogQuery>((_) => CatalogQuery.empty());

final catalogResultsProvider = FutureProvider<List<CatalogExercise>>((ref) async {
  await ref.watch(catalogBootstrapProvider.future);
  final q = ref.watch(catalogQueryProvider);
  return ref.watch(databaseProvider).catalogDao.query(...);
});
```

- [ ] **Step 4: Main/App 等待 bootstrap（失败可重试）**

`MainScreen` 或 `WorkoutApp` 对 `catalogBootstrapProvider`：loading 显示简单 splash；error 显示「动作库加载失败」+ 重试（invalidate）。

- [ ] **Step 5: Commit**

```bash
git add lib/providers/workout_providers.dart lib/catalog/filter_labels.dart lib/main.dart
git commit -m "feat: bootstrap catalog import from assets on launch"
```

---

### Task 7: CatalogBrowser + 筛选弹窗 + 详情页

**Files:**
- Create: `lib/widgets/catalog_filter_sheets.dart`
- Create: `lib/widgets/catalog_browser.dart`
- Create: `lib/widgets/catalog_detail_page.dart`

- [ ] **Step 1: 筛选弹窗**

`showCatalogFilterSheet(context, currentQuery) → CatalogQuery?`

- 一级：`部位` / `器械` / `目标肌群` 列表 Tile  
- 点维度 → 二级：多选 Checkbox 列表（中文 label），确认返回一级  
- 底部：已选摘要 +「完成」  
- 条件写入 `CatalogQuery` 的对应 Set（英文原值，与 DB 一致）

- [ ] **Step 2: CatalogBrowser**

```dart
enum CatalogBrowserMode { browse, pick }

class CatalogBrowser extends ConsumerWidget {
  final CatalogBrowserMode mode;
  final int? dayOfWeek; // pick 时必填
  final void Function(CatalogExercise ex)? onAdded; // 可选回调
}
```

布局：
- `TextField` 搜索（onChanged 更新 `catalogQueryProvider.search`，可 debounce 300ms）
- `IconButton` 筛选 → sheet
- 已选条件 `Chip` 可删
- `ListView`：`Image.asset(ex.gifAsset, width: 56, height: 56, errorBuilder: …「无」)`
  - 标题 `nameZh`，副标题 `labelBodyPart · labelEquipment · labelTarget`
  - `mode==pick` 时 trailing `IconButton(Icons.add)` → `templateDao.addExercise(day, ex.nameZh, datasetId: ex.datasetId)` + SnackBar
  - 点行主体 → push `CatalogDetailPage`

- [ ] **Step 3: CatalogDetailPage**

- 大图 GIF `Image.asset`
- 名称、元数据、分步 `instructionStepsZh` decode
- `mode==pick` 时 FAB/按钮「加入模板」同添加逻辑

- [ ] **Step 4: 手动/简单 widget 烟测（可选）**

若写 widget 测试，用 `ProviderScope(overrides: [databaseProvider.overrideWithValue(memDb), catalogBootstrapProvider.overrideWith((ref) async {})])` 并预先 importCatalog。

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/catalog_*.dart
git commit -m "feat(ui): shared CatalogBrowser, filters, and detail page"
```

---

### Task 8: 示意图 Tab + 主导航

**Files:**
- Create: `lib/screens/catalog_screen.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: CatalogScreen**

```dart
Scaffold(
  appBar: AppBar(
    title: Text('示意图'),
    actions: [/* theme toggle 可复用 */ , Text('v1.1.0')],
  ),
  body: CatalogBrowser(mode: CatalogBrowserMode.browse),
);
```

- [ ] **Step 2: MainScreen 增加第 4 destination**

```dart
_screens = [Today..., Template..., History..., CatalogScreen()];
// NavigationDestination: Icons.menu_book / label 示意图
```

- [ ] **Step 3: Commit**

```bash
git add lib/screens/catalog_screen.dart lib/main.dart
git commit -m "feat(ui): add diagram catalog tab"
```

---

### Task 9: 周模板 + 现有/自定义 + C1

**Files:**
- Modify: `lib/screens/template_screen.dart`
- Modify: `lib/widgets/day_template_card.dart`（若需改 onAdd 签名）

- [ ] **Step 1: 改造 onAdd**

点 + 后 `showModalBottomSheet`：

1. ListTile「从动作库选择」→ `Navigator` 全屏/路由打开 `CatalogBrowser(mode: pick, dayOfWeek: day)`（可用 `showModalBottomSheet` 高度 90% 或 `MaterialPageRoute`）
2. ListTile「自定义名称」→ 原 Dialog 输入框

- [ ] **Step 2: 自定义 C1**

提交名称 `trimmed` 后：

```dart
final hit = await db.catalogDao.findByNameZh(trimmed);
if (hit != null) {
  final ok = await showDialog<bool>(/* 库中已有「$trimmed」，合并并显示示意图？ 合并/取消 */);
  if (ok != true) return; // 取消：不写库，用户可再开对话框改名
  await db.templateDao.addExercise(day, hit.nameZh, datasetId: hit.datasetId);
} else {
  await db.templateDao.addExercise(day, trimmed, datasetId: null);
}
```

- [ ] **Step 3: invalidate 相关 providers**（template / todayExercises）

- [ ] **Step 4: Commit**

```bash
git add lib/screens/template_screen.dart lib/widgets/day_template_card.dart
git commit -m "feat(ui): template add from catalog or custom with C1 merge"
```

---

### Task 10: 全屏版本号 + 回归测试

**Files:**
- Modify: `lib/screens/today_training_screen.dart`（v1.1.0）
- Modify: `lib/screens/template_screen.dart`
- Modify: `lib/screens/history_screen.dart`
- Modify: `lib/screens/chart_screen.dart`
- Modify: `lib/screens/catalog_screen.dart`
- Modify: `pubspec.yaml`（确认 1.1.0+11）

- [ ] **Step 1: 所有 AppBar 版本文本改为 `v1.1.0`**

- [ ] **Step 2: 全量测试与分析**

```bash
flutter test
flutter analyze
```

Expected: 测试通过；analyze 无 error（info/warning 按项目惯例处理）。

- [ ] **Step 3: 最终 Commit**

```bash
git add lib/screens pubspec.yaml
git commit -m "chore: bump display version to v1.1.0 and finish catalog feature"
```

---

## Spec Coverage Checklist

| Spec 项 | Task |
|---------|------|
| 路径 A assets 提交 | 1–2 |
| catalog 入 SQLite + 版本导入 | 3–4, 6 |
| exercises.datasetId | 3, 5 |
| 示意图纯查阅 Tab | 8 |
| 共用 Browser browse/pick | 7–9 |
| 筛选弹窗叠加 AND | 7 |
| contains 搜索 | 4, 7 |
| 列表添加 + 点进详情 | 7 |
| 自定义 C1 | 9 |
| 全量 GIF | 1 |
| 中文名离线 | 1 |
| 版本号 5 处（+新屏） | 2, 10 |
| 不做：上传图/模糊搜/百科加模板 | 无对应任务 |

## Placeholder / Consistency Notes

- Drift 生成类名以 build_runner 为准（`CatalogExercise` / `CatalogExercisesData` 等）；实现时与 `.g.dart` 对齐。
- `Image.asset` 路径必须与 `pubspec` assets 前缀一致（`assets/exercises/gifs/0001.gif`）。
- 内存库测试不加载真实 1324 GIF；UI 真机/模拟器再验动画。
- 仓库增大与 APK 变大是预期结果。

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-11-exercise-catalog-plan.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — 每任务新 subagent，任务间审查  
2. **Inline Execution** — 本会话按 executing-plans 连续执行  

Which approach?

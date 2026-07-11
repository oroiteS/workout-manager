# 动作库与示意图 — 设计说明

**日期：** 2026-07-11  
**状态：** 已确认；实现计划见 docs/superpowers/plans/2026-07-11-exercise-catalog-plan.md  
**关联：** 现有 Workout Manager（v1.0.9）+ 本地 `exercises-dataset` 素材

---

## 1. 背景与目标

当前 App 仅支持用户手写动作名，无动作目录、无示意图。现引入 `exercises-dataset` 的结构化动作库与 GIF，实现：

1. **周模板**：可「从动作库选择」或「自定义名称」添加动作  
2. **示意图 Tab**：纯查阅百科（搜索 + 筛选 + GIF + 说明）  
3. **同名合一**：同一用户动作实体全局唯一，训练记录与图表合并  
4. **资源路径 A**：处理后的 assets 提交进 git；原始 `exercises-dataset/` 不进主仓  
5. **数据方案 2**：首次启动将 catalog 导入 SQLite；GIF 仍从 Flutter assets 加载  

**非目标（本版不做）：**

- 自定义动作上传示意图  
- 模糊/拼音搜索  
- 在示意图 Tab 内加入周模板  
- 云同步、账号、动作库子集裁剪  
- 运行时机器翻译  
- 许可合规处理（自用）

---

## 2. 用户流程

### 2.1 底部导航

| 顺序 | Tab | 行为 |
|------|-----|------|
| 1 | 今日训练 | 不变 |
| 2 | 周模板 | `+` 改为「现有 / 自定义」 |
| 3 | 记录 | 不变 |
| 4 | 示意图 | 新建，纯百科 |

### 2.2 周模板添加动作

```
点 +
  → 选择【从动作库选择】或【自定义名称】

【从动作库选择】
  → CatalogBrowser(mode: pick, dayOfWeek)
  → 列表项右侧「添加」：按 name_zh 找/建 exercises，写入 dataset_id，加入 week_template
  → 点缩略图/名称：进详情（详情内也可「加入模板」）

【自定义名称】
  → 单行输入名称
  → 若与某 catalog.name_zh 完全一致（C1）：
       提示「库中已有同名，合并并显示示意图？」
       [合并] → 使用/创建该 exercises 行并绑定 dataset_id
       [取消] → 返回修改名称（不创建冲突行）
  → 若无同名：创建 exercises(dataset_id = null)，加入模板
```

### 2.3 示意图（百科）

- 与「现有」**共用同一套** CatalogBrowser UI  
- 差异：无列表「添加」按钮；详情无「加入模板」  
- 仅查阅：搜索、筛选、看 GIF 与步骤  

### 2.4 同名规则（C1）

- `exercises.name` **全局 UNIQUE**  
- 同名只能有一行用户动作实体  
- 自定义与库内中文名完全一致时：只能「合并绑定」或「改名」，不能「同名但不关联」  
- 训练记录始终挂 `exercise_id`；图表按 id 聚合  

---

## 3. 资源管线

### 3.1 目录结构（提交 git）

```
assets/exercises/
  catalog.json                 # 精简目录 + name_zh + catalog_version
  gifs/{dataset_id}.gif        # 全量 GIF，如 0001.gif
tool/
  prepare_exercise_assets.*    # 从 exercises-dataset 生成上述资源
  # 中文名可由 subagent 批量生成后合并进 catalog.json
```

### 3.2 不提交

- `exercises-dataset/` 原始 clone → `.gitignore` 使用正确路径 `exercises-dataset/`  
- 修正现有错误项 `exercise-dataset/`（可选保留兼容）

### 3.3 catalog.json 记录字段（逻辑模型）

每条至少包含：

| 字段 | 说明 |
|------|------|
| `dataset_id` | 原 id，如 `"0001"` |
| `name_en` | 英文名 |
| `name_zh` | 中文名（离线生成） |
| `body_part` | 部位（与原 category 同值） |
| `equipment` | 器械 |
| `target` | 目标肌群 |
| `muscle_group` | 协同肌群描述 |
| `secondary_muscles` | 字符串数组 |
| `instruction_steps_zh` | 中文分步数组 |
| `instructions_zh` | 中文全文（可选，可由 steps 拼接） |
| `gif_asset` | `assets/exercises/gifs/{dataset_id}.gif` |

文件级：`catalog_version`（整数或 semver 字符串），用于决定是否重建导入。

### 3.4 中文名

- 使用 subagent / 批量离线翻译生成 `name_zh`  
- 写入 `catalog.json`，App **不**在运行时翻译  
- 筛选项枚举（部位/器械/target 等）使用静态中文映射表（条目远少于 1324）

### 3.5 CI

- 无需 GitHub Release 下载资源  
- `actions/checkout` 后直接 `flutter pub get` → build；APK 体积会显著增大（全量 GIF）

---

## 4. 数据模型（Drift）

### 4.1 新表 `catalog_exercises`

| 列 | 类型 | 说明 |
|----|------|------|
| `dataset_id` | TEXT PK | 库 id |
| `name_en` | TEXT | |
| `name_zh` | TEXT | |
| `body_part` | TEXT | |
| `equipment` | TEXT | |
| `target` | TEXT | |
| `muscle_group` | TEXT | |
| `secondary_muscles` | TEXT | JSON 数组文本 |
| `instructions_zh` | TEXT | |
| `instruction_steps_zh` | TEXT | JSON 数组文本 |
| `gif_asset` | TEXT | asset 路径 |

建议索引：`name_zh`、`body_part`、`equipment`、`target`。

### 4.2 扩展 `exercises`

| 列 | 说明 |
|----|------|
| `id` | 自增 PK（不变） |
| `name` | UNIQUE 展示名 |
| `dataset_id` | TEXT 可空；非空表示已绑定库内动作并可解析 GIF |

### 4.3 不变

- `week_template`、`training_record` 仍只引用 `exercises.id`  
- `training_record.exercise_name` 冗余字段策略保持：upsert 时同时写 id 与 name  

### 4.4 Schema

- `schemaVersion` 递增  
- 与现项目一致：**无迁移脚本，清空重建**  
- 实现说明/发布说明中注明本地旧数据会丢失（自用可接受）

### 4.5 导入

1. App 打开 DB 后检查 catalog 是否为空，或 `catalog_version`（可用简单 meta 表/键值）是否低于资源版本  
2. 需要时：清空 `catalog_exercises`，从 `catalog.json` 批量插入  
3. **不**用 catalog 覆盖用户 `exercises` / 模板 / 记录  
4. 导入失败：百科/选择器显示错误与重试；用户训练数据读写不受阻  

---

## 5. UI 设计

### 5.1 共用组件 `CatalogBrowser`

```
[ 搜索框                         ] [筛选]
[ Chip: 已选条件… ]  [清空]
────────────────────────────────
列表项：
  [GIF]  name_zh
         部位 · 器械 · 目标          [添加?]  // 仅 pick 模式
```

**搜索：** 对 `name_zh`（可选同时 `name_en`）做 **子串 contains**，不支持模糊。  

**筛选：**

- 按钮打开一级弹窗：维度列表（`body_part`、`equipment`、`target`；以及数据集中适合作为筛选项的其它字段，取值过散的可排除）  
- 点维度 → 二级弹窗：仅该维度的可选值（中文标签）  
- 可返回一级继续选；条件 **AND 叠加**  
- 已选条件以 Chip 展示，可单独移除  
- 筛选不占用常驻大块布局  

**模式：**

| | `browse`（示意图） | `pick`（周模板现有） |
|--|-------------------|---------------------|
| 列表「添加」 | 无 | 有 |
| 点图/名 | 详情 | 详情 |
| 详情「加入模板」 | 无 | 有 |

### 5.2 详情页

- GIF 大图（`Image.asset`）；资源缺失时显示「无」  
- 中文名；可附英文副标题  
- 部位 / 器械 / 目标 / 次要肌群  
- `instruction_steps_zh` 分步列表  

### 5.3 用户动作无库绑定

- `exercises.dataset_id == null` 时，凡需示意处显示「无」  
- 本版示意图集中在 Tab4 + 选择器；今日训练/记录/图表 **首版不强制** 嵌 GIF  

### 5.4 版本展示

- 新示意图屏 AppBar 显示 `vX.Y.Z`，与其它 screen 同步升级  

---

## 6. 分层与代码落点

```
assets/exercises/*          资源
tool/prepare_*              资源生成
lib/database/
  database.dart             表定义 + schemaVersion
  catalog_dao.dart          catalog 查询/导入
  exercise_dao.dart         扩展 dataset_id；找名/建/绑
lib/providers/
  workout_providers.dart    catalog 导入触发、查询 providers
lib/widgets/
  catalog_browser.dart      共用浏览
  catalog_filter_sheets.dart 筛选弹窗
  catalog_detail.dart       详情
lib/screens/
  catalog_screen.dart       示意图 Tab
  template_screen.dart      + 流程改造
  main.dart                 第 4 Tab
```

---

## 7. 测试要点

- 导入条数与 JSON 一致；抽查 id ↔ gif_asset  
- 筛选 AND、contains 搜索  
- 库选添加：`dataset_id` 有值且模板可见  
- 自定义新名：`dataset_id` 空  
- 自定义同名 C1：合并 / 取消改名  
- 同名训练记录图表同一 `exercise_id`  
- browse 无添加；pick 有添加  
- `flutter analyze` / 相关 widget 与 dao 测试  

---

## 8. 实现顺序

1. 资源管线 + 中文名生成 + assets + pubspec + gitignore  
2. Drift：`catalog_exercises`、`exercises.dataset_id`、导入、DAO  
3. CatalogBrowser + 筛选弹窗 + 详情  
4. 示意图 Tab 接入 MainScreen  
5. 周模板 `+`：现有 / 自定义 + C1  
6. 版本号、测试、analyze  

---

## 9. 决策记录

| 项 | 选择 |
|----|------|
| 资源分发 | 路径 A：处理后 assets 提交 git |
| 数据方案 | 方案 2：catalog 入 SQLite + GIF assets |
| 示意图角色 | 纯查阅百科 |
| 添加入口 | 周模板 `+`：先选现有/自定义 |
| 浏览器复用 | 百科与现有完全同一套 UI |
| 列表添加 | 右侧「添加」；点名/图进详情 |
| 同名策略 | C1：全局唯一，确认即合并绑库 |
| 筛选维度 | 部位 + 器械 + 目标肌群（及适宜字段） |
| 筛选 UI | 按钮 → 级联弹窗，条件可叠加 |
| 搜索 | contains，非模糊 |
| 中文名 | 离线 subagent 翻译写入 catalog |
| GIF | 全量打包 |
| 许可 | 自用忽略 |

---

## 10. 成功标准

- 用户可从库筛选/搜索并加入周模板，也可自定义  
- 示意图 Tab 可筛选搜索并播放库内 GIF  
- 绑定库的动作有图；未绑定显示「无」  
- 同名动作训练与图表合并  
- CI 无需外链资源即可打出带动作库的 APK  

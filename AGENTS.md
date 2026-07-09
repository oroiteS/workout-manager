# Workout Manager — Agent Instructions

## 项目概述

极简健身重量记录工具，跨平台 Flutter 应用。主功能：周模板管理每日动作 → 今日训练输入重量 → 历史记录查看/编辑/补录 → 动作重量趋势图表。

## 技术栈

- **Flutter** (Dart SDK >= 3.4.0), **Drift** ^2.24.0 (SQLite ORM), **Riverpod** ^2.6.1
- fl_chart (图表), table_calendar (日历), intl (中文国际化)
- UI 语言：中文

## 关键命令

```bash
dart run build_runner build --delete-conflicting-outputs  # DB 表结构变更后必须运行
flutter analyze                                           # lint 检查
flutter test                                              # 20 个测试
```

## 数据库架构

3 个表，无迁移脚本（清空重建，schemaVersion 直接递增）：

| 表 | 用途 |
|---|---|
| `exercises` | 全局唯一动作（id, name UNIQUE） |
| `week_template` | 天-动作关联（day_of_week, exercise_id FK） |
| `training_record` | 训练记录（exercise_id, exercise_name 冗余, weight, trained_at） |

**规则：**
- 修改 `database.dart` 中的表定义后，必须运行 `build_runner` 重新生成 `.g.dart`
- `training_record.exercise_name` 是冗余字段，`upsertRecord` 时需同时传入 exerciseId 和 exerciseName
- 模板添加动作时自动去重：同名动作复用已有 `exercises` 行

## 分层架构

```
database.dart (表定义) → *.g.dart (生成) → *_dao.dart (数据访问)
→ workout_providers.dart (Riverpod) → screens/ + widgets/ (UI)
```

- `ExerciseDao` — 动作 CRUD，`deleteById` 级联删除模板和记录
- `TemplateDao` — 返回 `TemplateWithExercise`（JOIN exercises），`addExercise` 自动去重
- `RecordDao` — `upsertRecord` 按天去重（同天同动作只保留一条）

## 版本号规则

**每次改动必须更新版本号**，共 5 处：
- `pubspec.yaml`: `version: X.Y.Z+N`（Flutter 构建号）
- 4 个 screen AppBar 中的 `vX.Y.Z` 显示文本：
  - `today_training_screen.dart`
  - `template_screen.dart`
  - `history_screen.dart`
  - `chart_screen.dart`

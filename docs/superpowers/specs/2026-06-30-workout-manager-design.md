# 健身训练记录 App — 设计规格

**日期**：2026-06-30  
**状态**：已确认  
**构建目标**：Android APK（Flutter + GitHub Actions）

---

## 1. 产品定位

一款极简的健身重量记录工具。用户自定义训练动作和对应重量，以周为模板，每次训练自动加载当天动作，填写重量后保存为历史记录。通过折线图追踪每个动作的重量变化趋势。

**不做什么**：不内置任何健身动作库、不联网同步、不需要登录、不上架应用商店。

---

## 2. 核心流程

```
打开 App → 自动判断今天星期几
       → 从 week_template 表加载今天的动作
       → 对每个动作查询上次训练重量（引导提示）
       → 用户填入重量 → 保存到 training_record 表
       → 随时可以查看某个动作的历史重量折线图
```

管理流程：

```
模板页 → 按周一到周日编辑每天的动作列表
       → 增删动作、拖拽排序
```

---

## 3. 界面结构

底部导航 2 个 Tab + 1 个子页面：

| 页面 | 路由 | 导航方式 | 说明 |
|------|------|----------|------|
| **今日训练** | `/` | 底部 Tab 1 | 主屏。自动加载今天该练的动作，显示重量输入框 + 上次重量提示。底部"保存训练记录"按钮 |
| **周模板** | `/template` | 底部 Tab 2 | 周一到周日 7 个区块，每天可添加/删除动作（排序为 stretch goal） |
| **趋势图** | `/chart/:exerciseName` | Push 导航 | 从训练页或模板页点击动作名进入。单个动作的历史重量折线图（最近 20 次）。底部涨跌摘要 |

视觉风格：极简，无装饰元素，纯功能驱动。

---

## 4. 数据模型

数据库：SQLite（使用 drift 库）

### 表 1：week_template（周训练模板）

| 列名 | 类型 | 说明 |
|------|------|------|
| `day_of_week` | INTEGER | 1-7（周一至周日） |
| `exercise_name` | TEXT | 用户自定义动作名 |
| `sort_order` | INTEGER | 排序序号 |

- 主键：(day_of_week, exercise_name)

### 表 2：training_record（训练记录）

| 列名 | 类型 | 说明 |
|------|------|------|
| `id` | INTEGER | 自增主键 |
| `exercise_name` | TEXT | 动作名称 |
| `weight` | REAL | 重量（公斤） |
| `trained_at` | DATETIME | 训练日期 |

- 索引：(exercise_name, trained_at) 用于快速查询历史

### 设计决策

- **不设"动作字典表"**：动作名完全由用户自定义，不存在预设列表，符合极简定位
- **重量单位**：固定为公斤（kg），不做单位切换
- **数据类型**：重量用 REAL 以支持小数（如 82.5kg）

---

## 5. 技术栈

| 层 | 选型 | 理由 |
|----|------|------|
| **UI 框架** | Flutter 3.x | 跨平台、Material Design 天然契合 |
| **数据库** | drift (SQLite) | 类型安全、支持复杂查询、Flutter 生态最成熟的 SQLite 方案 |
| **状态管理** | Riverpod | 轻量、无样板代码、可扩展 |
| **图表** | fl_chart | 开源免费、曲线图够用 |
| **打包** | GitHub Actions | flutter/actions/setup-flutter@v3 + flutter build apk |

---

## 6. 架构分层

```
UI 层（Screens + Widgets）
  ↕ 依赖
状态层（Riverpod Providers）
  ↕ 依赖
数据层（drift DAO + 数据库表）
```

### 6.1 UI 层文件

| 文件 | 职责 |
|------|------|
| `screens/today_training_screen.dart` | 今日训练记录页 |
| `screens/template_screen.dart` | 周模板编辑页 |
| `screens/chart_screen.dart` | 动作趋势图页 |
| `widgets/exercise_input_card.dart` | 单个动作的输入卡片组件 |
| `widgets/day_template_card.dart` | 模板页中一天的动作编辑卡片 |
| `main.dart` | 入口 + 2-Tab 底部导航 + 路由 |

### 6.2 状态层

| Provider | 职责 |
|----------|------|
| `todayExercisesProvider` | 加载今天该练的动作 + 上次重量 |
| `templateProvider` | 周模板的 CRUD |
| `exerciseHistoryProvider(exerciseName)` | 单个动作的历史记录 |
| `saveRecordProvider` | 保存训练记录 |

### 6.3 数据层

- `database.dart` — drift 数据库定义、建表语句
- `template_dao.dart` — 模板的增删改查
- `record_dao.dart` — 训练记录的插入、历史查询

---

## 7. GitHub Actions 打包

```yaml
触发器：push 到 main
步骤：
  1. checkout 代码
  2. subosbo/flutter-action@v2 安装 Flutter
  3. flutter pub get
  4. flutter build apk --release
  5. upload-artifact 上传 APK
```

产物：`build/app/outputs/flutter-apk/app-release.apk`，可从 Actions Artifact 下载。

**APK 签名**：初期使用 debug keystore（可直接安装），后续需要时再配置正式签名。

---

## 8. Stretch Goals（未来可加，本期不做）

- 拖拽排序模板中的动作（本期用简单的上移/下移或删除重加）
- 正式 APK 签名（初期用 debug 签名可直接安装）
- 数据导出（JSON/CSV）

---

## 9. 不做的事（明确排除）

- ❌ 不内置健身动作库
- ❌ 不联网、不同步、不需要账号
- ❌ 不上架 Google Play
- ❌ 不切换单位（固定 kg）
- ❌ 不做训练计划推送提醒
- ❌ 不做组数/次数记录（仅记录单次重量）

---

## 10. 测试策略

- **单元测试**：DAO 层数据库操作
- **Widget 测试**：核心输入卡片和表单验证
- **不要求**：集成测试（小 App 手工验证即可）

---

## 11. 文件结构总览

```
lib/
├── main.dart
├── database/
│   ├── database.dart
│   ├── template_dao.dart
│   └── record_dao.dart
├── models/
│   └── (drift 生成的模型类)
├── providers/
│   └── workout_providers.dart
├── screens/
│   ├── today_training_screen.dart
│   ├── template_screen.dart
│   └── chart_screen.dart
└── widgets/
    ├── exercise_input_card.dart
    └── day_template_card.dart
```

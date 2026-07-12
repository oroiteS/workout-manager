# Workout Manager — 极简健身重量记录

跨平台 Flutter 应用，用最少步骤记录每次训练重量，并附带本地动作库与示意图。

当前版本：`1.1.3+14`

## 功能

| 模块 | 说明 |
|------|------|
| **今日训练** | 按周模板自动列出当天动作，输入重量并保存 |
| **周模板** | 按周一至周日配置动作；可从动作库选择，也可自定义名称 |
| **记录** | 按日期查看、编辑历史；支持补录 |
| **图表** | 查看动作重量趋势与近期统计 |
| **示意图** | 本地动作百科：搜索、筛选、GIF 演示与中文步骤说明 |

其他约定：

- 同名动作全局唯一：自定义名称若与库内中文名完全一致，可合并绑定库动作并显示示意图
- 数据本地 SQLite 存储，无账号、无云同步
- 界面中文；支持浅色 / 深色主题

## 动作库数据来源

动作目录与示意图 GIF 来自开源数据集：

- **[hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)**

本仓库仅提交处理后的资源（`assets/exercises/`：精简 `catalog.json` + GIF），中文名称与分步说明由本地脚本离线整理后写入；原始 clone 目录 `exercises-dataset/` 不纳入版本库。

**致谢：** 感谢 [hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset) 提供结构化动作数据与演示素材。若你二次分发本应用或其中资源，请自行核对该数据集的许可条款。

## 技术栈

- Flutter（Dart SDK `>=3.4.0`）
- Drift（SQLite）
- Riverpod
- fl_chart / table_calendar / intl

## 开发

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 表结构变更后必须
flutter analyze
flutter test
flutter run
```

重新从原始数据集生成资源（需本地存在 `exercises-dataset/`）：

```bash
python3 tool/prepare_exercise_assets.py
```

## CI

推送到 `main` 或打 `v*` tag 时，GitHub Actions 会运行测试并构建 release APK（资源已在仓库内，无需额外下载）。

## License

见 [LICENSE](LICENSE)。动作库素材版权与许可以 [exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset) 为准。

# Workout Manager — 极简健身重量记录

跨平台 Flutter 应用，用最少步骤记录每次训练重量，并附带本地动作库与示意图。

当前版本：`1.3.0+17`

## 功能

| 模块 | 说明 |
|------|------|
| **今日训练** | 按周模板自动列出当天动作，输入重量并保存；支持导出 / 导入 JSON 备份 |
| **周模板** | 按周一至周日配置动作；可从动作库选择，也可自定义名称；支持从 CSV 导入整周计划 |
| **记录** | 按日期查看、编辑历史；支持补录 |
| **图表** | 查看动作重量趋势与近期统计 |
| **示意图** | 本地动作百科：搜索、筛选、GIF 演示与中文步骤说明 |

其他约定：

- 同名动作全局唯一：自定义名称若与库内中文名完全一致，可合并绑定库动作并显示示意图
- 数据本地 SQLite 存储，无账号、无云同步
- 界面中文；支持浅色 / 深色主题
- **备份（JSON v1）**：在「今日训练」页导出 / 导入；文件含 `version: 1`、`exportedAt`、`appVersion` 与 `data`（`exercises` / `weekTemplate` / `trainingRecords`）。导入会**整库覆盖**当前训练数据，不可撤销。导出优先自选路径；失败时可分享备份文件
- **周计划 CSV 导入**：仅替换周模板，**不动任何训练记录**；导入前展示每日增删预览，确认后才生效。详见下方「周计划 CSV 格式」

## 周计划 CSV 格式

「周模板」页右上角上传图标 → 选择 `.csv` 文件 → 查看 diff 预览 → 确认导入。

- **语义为整周替换**：CSV 即完整的新计划，CSV 中**未出现的天会被清空**（预览中会明确列出）；与当前计划完全一致时不会执行导入
- **只改计划，不删数据**：历史训练记录、动作库均不受影响；同名动作复用原 id（已有记录仍能对上），名称与动作库中文名完全一致时自动绑定示意图

文件为两列行式 CSV（可从 Excel / Numbers 直接编辑）：

```csv
day,exercise
1,杠铃卧推
1,哑铃上斜卧推
2,深蹲
2,硬拉
```

- 每行一个动作；**同一天写多行**，行序即当天动作的显示顺序
- `day` 接受 `1`-`7`（周一为 1）、`周一`-`周日`、`星期一`-`星期日`
- 首行可为表头（`day,exercise`，也可省略）；兼容 BOM、CRLF 换行、引号包裹字段（含内嵌逗号）
- 动作名必填且同日内去重（保留首次出现）；解析错误会提示原始行号

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

## Android release 签名

正式包使用固定 release 签名，才能在设备上**覆盖安装**并保留应用数据。密钥与密码**不得提交到 git**（`android/.gitignore` 已忽略 `key.properties`、`*.jks`、`*.keystore`）。

### 1. 生成 release keystore

```bash
keytool -genkeypair -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass <storePassword> \
  -keypass <keyPassword> \
  -dname "CN=Workout Manager, OU=Personal, O=Self, L=Local, S=Local, C=CN"
```

请自行保管密码；生产环境应使用自己的密钥与强密码，不要使用他人仓库中的本地开发密钥。

### 2. 配置 `android/key.properties`（本地，不进 git）

在 `android/key.properties` 写入：

```properties
storePassword=<storePassword>
keyPassword=<keyPassword>
keyAlias=upload
storeFile=../upload-keystore.jks
```

说明：

- `key.properties` 位于 `android/`（Gradle `rootProject.file("key.properties")`）
- `storeFile` 相对路径相对于 `android/app/` 模块解析，因此 keystore 放在 `android/upload-keystore.jks` 时写 `../upload-keystore.jks`
- 若 keystore 在项目外，可写绝对路径

缺少 `key.properties` 时，release 构建会回退到 **debug 签名**，并在构建日志打印 WARNING：该包**不能**用于正式覆盖安装。

### 3. 本地构建

```bash
flutter build apk --debug    # 始终使用 debug 签名
flutter build apk --release  # 有 key.properties 时使用 release 签名
```

### 4. GitHub Actions Secrets（CI 签 release APK）

在仓库 **Settings → Secrets and variables → Actions** 配置：

| Name | Value |
|------|-------|
| `KEYSTORE_BASE64` | `base64` 编码后的 `upload-keystore.jks`（例如 `base64 -i android/upload-keystore.jks`） |
| `KEYSTORE_PASSWORD` | storePassword |
| `KEY_PASSWORD` | keyPassword |
| `KEY_ALIAS` | `upload` |
| `STORE_FILE_NAME` | `upload-keystore.jks` |

工作流会在构建前将 keystore 写到 `android/<STORE_FILE_NAME>`，并生成 `android/key.properties`（其中 `storeFile=../<STORE_FILE_NAME>`，与本地布局一致）。**Secrets 需由仓库维护者手动配置**；未配置时 CI 无法正确签 release 包。

### 5. 从旧 debug 包迁移到 release 签名包

旧版若用 debug 签名安装，换 release 签名后**无法覆盖安装**，需卸载重装。迁移步骤：

1. 在旧版「今日训练」页**导出备份**（JSON v1）
2. 卸载旧应用（debug 签名与 release 签名不能覆盖安装）
3. 安装新的 release 签名 APK
4. 在「今日训练」页**导入备份**恢复数据

## CI

推送到 `main` 或打 `v*` tag 时，GitHub Actions 会运行 analyze、测试并构建 release APK（资源已在仓库内，无需额外下载）；打 tag 时还会自动创建 GitHub Release 并上传 APK。签 release 包依赖上方 Secrets。

## License

见 [LICENSE](LICENSE)。动作库素材版权与许可以 [exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset) 为准。

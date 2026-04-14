# Flutter Project Scripts

自动化脚本工具集，用于简化 Flutter 项目的日常开发任务。

## 前置要求

- Dart SDK 3.8.1+
- FVM (Flutter Version Management)
- Flutter 3.35.7

## 安装

首先安装脚本依赖（自动完成，无需手动操作）：

```bash
# 当你运行任何 make 命令时，会自动安装 shell 依赖
make setup
make clean
make codegen

# 或者手动安装 shell 依赖
make shell-deps
```

**注意**：所有 `make` 命令现在都会自动确保 shell 脚本的依赖已安装，无需手动操作。

## 可用脚本

### 1. setup.dart - 项目初始化

一键安装项目所有依赖。

**功能**：
- 配置 FVM Flutter 版本 (3.35.7)
- 安装根目录依赖
- 安装所有 packages 依赖（core, domain, data, features, utls）
- 安装所有 apps 依赖
- 支持针对单个包进行操作

**参数**：

| 参数 | 缩写 | 说明 |
|------|------|------|
| `--package` | `-p` | 指定目标包名 |
| `--help` | `-h` | 显示帮助信息 |

**使用方法**：

```bash
# 安装所有依赖
dart shell/bin/setup.dart

# 安装特定包的依赖
dart shell/bin/setup.dart --package reflection_data
dart shell/bin/setup.dart -p lt_app

# 查看帮助
dart shell/bin/setup.dart --help
```

**输出示例**：

```
🚀 Flutter Project Setup
==================================================
📁 Project root: /path/to/project

📦 Step 1: Setting up FVM...
✓ FVM configured: Flutter 3.35.7

📦 Step 2: Installing root dependencies...
    ⏳ root... ✓

📦 Step 3: Installing package dependencies...
  📂 Processing core packages...
    ⏳ packages/core/network... ✓
    ⏳ packages/core/lt_uicomponent... ✓
  📂 Processing domain packages...
    ⏳ packages/domain/reflection_domain... ✓
    ⏳ packages/domain/user_domain... ✓
    ⏳ packages/domain/wallet_domain... ✓
  📂 Processing data packages...
    ⏳ packages/data/reflection_data... ✓
    ⏳ packages/data/user_data... ✓
    ⏳ packages/data/wallet_data... ✓
  📂 Processing features packages...
    ⏳ packages/features/calendar... ✓
    ⏳ packages/features/thread... ✓
    ⏳ packages/features/add_answer... ✓

📦 Step 4: Installing app dependencies...
    ⏳ apps/lt_app... ✓
    ⏳ apps/algorithm_app... ✓

==================================================
✅ Setup completed successfully!
==================================================
```

### 2. clean.dart - 清理构建产物

清理项目中的所有构建产物和缓存文件。

**功能**：
- 删除 `.dart_tool` 目录
- 删除 `build` 目录
- 删除 `.flutter-plugins` 文件
- 删除 `.flutter-plugins-dependencies` 文件
- 删除 `pubspec.lock` 文件
- 自动跳过 `shell` 目录（保留脚本依赖）
- 支持针对单个包进行操作

**参数**：

| 参数 | 缩写 | 说明 |
|------|------|------|
| `--package` | `-p` | 指定目标包名 |
| `--help` | `-h` | 显示帮助信息 |

**使用方法**：

```bash
# 清理所有包
dart shell/bin/clean.dart

# 清理特定包
dart shell/bin/clean.dart --package reflection_data
dart shell/bin/clean.dart -p lt_app

# 查看帮助
dart shell/bin/clean.dart --help
```

**输出示例**：

```
🧹 Flutter Project Clean
==================================================
📁 Project root: /path/to/project

🧹 Cleaning package directories...
    🗑️  Deleted: .dart_tool
    🗑️  Deleted: build
  ✓ Cleaned 45 package directories

🧹 Cleaning app directories...
    🗑️  Deleted: .dart_tool
    🗑️  Deleted: build
  ✓ Cleaned 2 app directories

🧹 Cleaning root directory...
  ✓ Cleaned root directory

==================================================
✅ Cleaned 48 directories
==================================================
```

### 3. codegen.dart - 代码生成

为所有需要的包运行 build_runner 代码生成。

**功能**：
- 自动检测 `packages/data/`、`packages/features/` 和 `apps/` 下包含 `build_runner` 的包
- 运行代码生成（Riverpod、Freezed、JSON Serializable 等）
- 支持 watch 模式
- 支持控制是否删除冲突文件
- 支持针对单个包进行操作

**参数**：

| 参数 | 缩写 | 默认值 | 说明 |
|------|------|--------|------|
| `--package` | `-p` | — | 指定目标包名 |
| `--watch` | `-w` | `false` | 启用 watch 模式（监听文件变化自动生成） |
| `--delete-conflicting` | — | `true` | 删除冲突的输出文件 |
| `--help` | `-h` | — | 显示帮助信息 |

**使用方法**：

```bash
# 为所有包生成代码
dart shell/bin/codegen.dart

# 为特定包生成代码
dart shell/bin/codegen.dart --package reflection_data
dart shell/bin/codegen.dart -p lt_app

# Watch 模式（监听文件变化自动生成）
dart shell/bin/codegen.dart --watch
dart shell/bin/codegen.dart -w

# 为特定包启用 watch 模式
dart shell/bin/codegen.dart -p user_data -w

# 不删除冲突文件
dart shell/bin/codegen.dart --no-delete-conflicting

# 查看帮助
dart shell/bin/codegen.dart --help
```

**输出示例**：

```
⚙️  Flutter Code Generation
==================================================
📁 Project root: /path/to/project

⚙️  Running build_runner...

Found 12 packages with build_runner

  📦 packages/data/reflection_data
     ✓ Success

  📦 packages/data/user_data
     ✓ Success

  📦 packages/features/calendar
     ✓ Success

  📦 apps/lt_app
     ✓ Success

==================================================
✅ Code generation completed!
==================================================
```

### 4. build_xcframework.dart - 构建 iOS XCFramework

将 Flutter Module 构建为 iOS XCFramework，用于原生 iOS 项目集成。

**功能**：
- 验证目标模块是否为有效的 Flutter Module（检查 `pubspec.yaml` 中的 `flutter.module` 配置）
- 检查构建环境（FVM 安装、Flutter 版本匹配 3.35.7）
- 自动解析依赖（`flutter pub get`）
- 构建 Release 模式的 XCFramework（跳过 debug 和 profile）
- 验证构建产物（`App.xcframework`、`Flutter.xcframework`）
- 列出所有生成的 `.xcframework` 文件

**参数**：

| 参数 | 缩写 | 说明 |
|------|------|------|
| `--module` | `-m` | **必填**，Flutter Module 名称（位于 `apps/` 目录下） |
| `--help` | `-h` | 显示帮助信息 |

**构建步骤**：
1. 模块验证 — 检查 `apps/<module>/pubspec.yaml` 存在且包含 `module:` 配置
2. 环境检查 — 确认 FVM 已安装且 Flutter 版本为 3.35.7
3. 依赖解析 — 在模块目录执行 `fvm flutter pub get`
4. 构建 XCFramework — 执行 `fvm flutter build ios-framework --no-debug --no-profile`
5. 验证产物 — 确认 `App.xcframework` 和 `Flutter.xcframework` 存在

**产物目录**：`apps/<module>/build/ios/xcframework/Release/`

**使用方法**：

```bash
# 构建 answer_detail_module 的 XCFramework
dart shell/bin/build_xcframework.dart -m answer_detail_module
dart shell/bin/build_xcframework.dart --module answer_detail_module

# 查看帮助
dart shell/bin/build_xcframework.dart --help
```

**输出示例**：

```
🔨 Flutter Module XCFramework 构建
==================================================
📁 Project root: /path/to/project
🎯 Target module: answer_detail_module

🔍 验证模块 answer_detail_module...
  ✓ 模块验证通过

🔍 检查构建环境...
  ✓ 环境检查通过 (Flutter 3.35.7)

📦 解析依赖...
  ✓ 依赖解析完成

🔨 构建 XCFramework (Release)...
  ✓ XCFramework 构建完成

🔎 验证构建产物...
  ✓ 产物验证通过

✅ 🎉 answer_detail_module XCFramework 构建成功！
   产物目录: apps/answer_detail_module/build/ios/xcframework/Release
   包含:
     - App.xcframework
     - Flutter.xcframework

==================================================
✅ Build completed successfully!
==================================================
```

### 5. test.dart - 运行单元测试

运行项目中的单元测试，支持指定单个包或运行所有包的测试。

**功能**：
- 自动扫描所有包含 `test/` 目录且有 `_test.dart` 文件的包
- 自动判断纯 Dart 包（`fvm dart test`）和 Flutter 包（`fvm flutter test`）
- 运行测试并汇总结果
- 支持针对单个包进行操作

**参数**：

| 参数 | 缩写 | 说明 |
|------|------|------|
| `--package` | `-p` | 指定目标包名 |
| `--help` | `-h` | 显示帮助信息 |

**使用方法**：

```bash
# 运行所有包的测试
dart shell/bin/test.dart

# 运行特定包的测试
dart shell/bin/test.dart --package reflection_domain
dart shell/bin/test.dart -p reflection_data

# 查看帮助
dart shell/bin/test.dart --help
```

**输出示例**：

```
🧪 Flutter Project Test
==================================================
📁 Project root: /path/to/project

🧪 Discovering packages with tests...

Found 5 packages with tests

  📦 packages/domain/reflection_domain
     ✓ All tests passed

  📦 packages/data/reflection_data
     ✓ All tests passed

  📦 apps/algorithm_app
     ✓ All tests passed

📊 Results: 3 passed, 0 failed, 3 total

==================================================
✅ Test completed!
==================================================
```

## 常见工作流

### 首次克隆项目

```bash
# 1. 克隆项目
git clone <repository>
cd <project>

# 2. 运行初始化脚本
dart shell/bin/setup.dart

# 3. 运行代码生成
dart shell/bin/codegen.dart
```

### 清理并重新安装

```bash
# 1. 清理所有构建产物
dart shell/bin/clean.dart

# 2. 重新安装依赖
dart shell/bin/setup.dart

# 3. 重新生成代码
dart shell/bin/codegen.dart
```

### 针对单个包的操作

```bash
# 清理特定包
dart shell/bin/clean.dart -p reflection_data

# 安装特定包的依赖
dart shell/bin/setup.dart -p reflection_data

# 为特定包生成代码
dart shell/bin/codegen.dart -p reflection_data

# 为特定包启用 watch 模式
dart shell/bin/codegen.dart -p reflection_data -w

# 运行特定包的测试
dart shell/bin/test.dart -p reflection_domain
```

### 开发模式

```bash
# 在一个终端运行 watch 模式
dart shell/bin/codegen.dart --watch

# 在另一个终端运行应用
cd apps/lt_app
fvm flutter run
```

### 构建 iOS XCFramework

```bash
# 构建 answer_detail_module 的 XCFramework
dart shell/bin/build_xcframework.dart -m answer_detail_module

# 产物位于 apps/answer_detail_module/build/ios/xcframework/Release/
# 将生成的 .xcframework 文件集成到原生 iOS 项目中
```

## Makefile 命令

项目已包含 Makefile，支持以下命令：

### 全局操作

```bash
make setup              # 安装所有依赖（FVM + 所有包）
make clean              # 清理所有构建产物
make codegen            # 为所有包运行代码生成
make watch              # 为所有包启用 watch 模式代码生成
make test               # 运行所有包的单元测试
make reset              # 完整重置（clean → setup → codegen）
make shell-deps         # 仅安装 shell 脚本依赖
make help               # 显示帮助信息
```

### 针对特定包的操作

```bash
make setup PACKAGE=reflection_data      # 安装特定包的依赖
make clean PACKAGE=lt_app               # 清理特定包
make codegen PACKAGE=user_data          # 为特定包生成代码
make watch PACKAGE=reflection_data      # 为特定包启用 watch 模式
make test PACKAGE=reflection_domain     # 运行特定包的测试
```

### XCFramework 构建

```bash
make xcframework MODULE=answer_detail_module   # 构建指定模块的 XCFramework
```

> **注意**：`MODULE` 参数为必填项，未提供时会提示错误。

## 故障排除

### FVM 未安装

如果看到 FVM 相关错误，请先安装 FVM：

```bash
# macOS
brew install fvm

# 或使用 pub
dart pub global activate fvm
```

### 权限问题

如果遇到权限问题，确保脚本有执行权限：

```bash
chmod +x shell/bin/*.dart
```

### 依赖冲突

如果遇到依赖冲突，尝试清理后重新安装：

```bash
dart shell/bin/clean.dart
dart shell/bin/setup.dart
```

### XCFramework 构建失败

- 确认目标模块是 Flutter Module（`pubspec.yaml` 中包含 `flutter.module` 配置）
- 确认 Flutter 版本为 3.35.7（`fvm list` 查看）
- 确认 FVM 已正确安装（`which fvm`）
- 尝试先清理再构建：`dart shell/bin/clean.dart -p <module_name>`

## 扩展脚本

可以在 `shell/bin/` 目录下添加更多自动化脚本，例如：

- `analyze.dart` - 运行代码分析
- `format.dart` - 格式化代码
- `deploy.dart` - 部署脚本

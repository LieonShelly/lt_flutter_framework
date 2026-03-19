# Flutter Project Scripts

自动化脚本工具集，用于简化 Flutter 项目的日常开发任务。

## 前置要求

- Dart SDK 3.8.1+
- FVM (Flutter Version Management)
- Flutter 3.35.7

## 安装

首先安装脚本依赖：

```bash
cd shell
dart pub get
```

## 可用脚本

### 1. setup.dart - 项目初始化

一键安装项目所有依赖。

**功能**：
- 配置 FVM Flutter 版本 (3.35.7)
- 安装根目录依赖
- 安装所有 packages 依赖（core, domain, data, features, utls）
- 安装所有 apps 依赖

**使用方法**：

```bash
# 从项目根目录运行
dart shell/bin/setup.dart

# 或从 shell 目录运行
cd shell
dart bin/setup.dart
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

**使用方法**：

```bash
# 从项目根目录运行
dart shell/bin/clean.dart

# 或从 shell 目录运行
cd shell
dart bin/clean.dart
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
- 自动检测包含 build_runner 的包
- 运行代码生成（Riverpod、Freezed、JSON Serializable 等）
- 支持 watch 模式

**使用方法**：

```bash
# 一次性生成
dart shell/bin/codegen.dart

# Watch 模式（监听文件变化自动生成）
dart shell/bin/codegen.dart --watch
dart shell/bin/codegen.dart -w

# 不删除冲突文件
dart shell/bin/codegen.dart --no-delete-conflicting
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

### 开发模式

```bash
# 在一个终端运行 watch 模式
dart shell/bin/codegen.dart --watch

# 在另一个终端运行应用
cd apps/lt_app
fvm flutter run
```

## 创建快捷命令（可选）

可以在项目根目录创建 Makefile 或 shell 脚本来简化命令：

### Makefile

```makefile
.PHONY: setup clean codegen watch

setup:
	dart shell/bin/setup.dart

clean:
	dart shell/bin/clean.dart

codegen:
	dart shell/bin/codegen.dart

watch:
	dart shell/bin/codegen.dart --watch

reset: clean setup codegen
```

使用：

```bash
make setup
make clean
make codegen
make watch
make reset
```

### Shell 脚本

创建 `scripts.sh`：

```bash
#!/bin/bash

case "$1" in
  setup)
    dart shell/bin/setup.dart
    ;;
  clean)
    dart shell/bin/clean.dart
    ;;
  codegen)
    dart shell/bin/codegen.dart
    ;;
  watch)
    dart shell/bin/codegen.dart --watch
    ;;
  reset)
    dart shell/bin/clean.dart
    dart shell/bin/setup.dart
    dart shell/bin/codegen.dart
    ;;
  *)
    echo "Usage: $0 {setup|clean|codegen|watch|reset}"
    exit 1
    ;;
esac
```

使用：

```bash
chmod +x scripts.sh
./scripts.sh setup
./scripts.sh clean
./scripts.sh codegen
./scripts.sh watch
./scripts.sh reset
```

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

## 扩展脚本

可以在 `shell/bin/` 目录下添加更多自动化脚本，例如：

- `test.dart` - 运行所有测试
- `analyze.dart` - 运行代码分析
- `format.dart` - 格式化代码
- `deploy.dart` - 部署脚本

## 贡献

欢迎添加更多有用的自动化脚本！

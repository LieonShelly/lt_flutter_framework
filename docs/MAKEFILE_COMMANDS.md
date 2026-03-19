# Makefile 命令参考

## 概述

项目提供了一套 Makefile 命令来简化日常开发任务。所有命令都会自动确保 shell 脚本依赖已安装。

## 基本命令

### make setup
安装所有依赖（FVM + 所有包）

```bash
make setup
```

**作用**：
1. 自动安装 shell 脚本依赖
2. 配置 FVM (Flutter 3.35.7)
3. 安装根目录依赖
4. 安装所有 packages 依赖
5. 安装所有 apps 依赖

### make clean
清理所有构建产物

```bash
make clean
```

**清理内容**：
- `.dart_tool` 目录
- `build` 目录
- `.flutter-plugins*` 文件
- `pubspec.lock` 文件

### make codegen
运行代码生成

```bash
make codegen
```

**作用**：
- 自动检测包含 build_runner 的包
- 运行 Riverpod、Freezed、JSON Serializable 生成器

### make watch
监听模式代码生成

```bash
make watch
```

**作用**：
- 监听文件变化
- 自动运行代码生成

### make reset
完整重置（清理 + 安装 + 生成）

```bash
make reset
```

**执行顺序**：
1. 安装 shell 依赖
2. 清理所有构建产物
3. 重新安装 shell 依赖（因为 workspace clean 会清理依赖解析）
4. 安装所有依赖
5. 运行代码生成

**适用场景**：
- 依赖冲突时
- 切换分支后
- 构建错误时
- 完全重置项目状态

**注意**：代码生成可能需要几分钟时间完成。

### make shell-deps
安装 shell 脚本依赖

```bash
make shell-deps
```

**说明**：通常不需要手动运行，所有其他命令会自动执行此步骤。

### make help
显示帮助信息

```bash
make help
```

## 包特定命令

所有基本命令都支持 `PACKAGE` 参数，用于针对特定包进行操作。

### 语法

```bash
make <command> PACKAGE=<package_name>
```

### 示例

#### 安装特定包的依赖

```bash
make setup PACKAGE=reflection_data
make setup PACKAGE=lt_app
```

#### 清理特定包

```bash
make clean PACKAGE=user_data
make clean PACKAGE=calendar
```

#### 为特定包生成代码

```bash
make codegen PACKAGE=reflection_data
make codegen PACKAGE=lt_app
```

#### 为特定包启用 watch 模式

```bash
make watch PACKAGE=reflection_data
make watch PACKAGE=add_answer
```

## 常见使用场景

### 场景 1：首次克隆项目

```bash
# 一键安装所有依赖并生成代码
make setup
make codegen
```

### 场景 2：依赖冲突

```bash
# 完整重置
make reset
```

### 场景 3：开发模式

```bash
# 启用 watch 模式
make watch

# 在另一个终端运行应用
cd apps/lt_app
fvm flutter run
```

### 场景 4：只更新某个包

```bash
# 只清理和重新安装某个包
make clean PACKAGE=reflection_data
make setup PACKAGE=reflection_data
make codegen PACKAGE=reflection_data
```

### 场景 5：切换分支后

```bash
# 重新安装依赖
make setup
```

### 场景 6：添加新依赖后

```bash
# 重新安装依赖
make setup
```

### 场景 7：修改 Model 后

```bash
# 重新生成代码
make codegen
```

## 命令执行时间参考

| 命令 | 预计时间 | 说明 |
|------|---------|------|
| `make shell-deps` | 5-10秒 | 首次运行较慢，后续很快 |
| `make setup` | 1-3分钟 | 取决于网络速度 |
| `make clean` | 5-15秒 | 取决于项目大小 |
| `make codegen` | 30秒-2分钟 | 取决于需要生成的包数量 |
| `make watch` | 持续运行 | 后台监听 |
| `make reset` | 2-5分钟 | 完整流程 |

## 故障排除

### 问题 1：make reset 报错找不到 args 或 path

**原因**：workspace clean 会清理 shell 的包解析配置

**解决方案**：
```bash
# 已修复：reset 命令会在 clean 后自动重新安装 shell 依赖
make reset
```

**技术说明**：由于项目使用 workspace 配置，clean 操作会清理根目录的 `.dart_tool`，这会影响 shell 包的依赖解析。现在 `make reset` 会在 clean 后自动重新安装 shell 依赖，确保后续脚本能正常运行。

### 问题 2：权限错误

**解决方案**：
```bash
chmod +x shell/bin/*.dart
```

### 问题 3：FVM 未找到

**解决方案**：
```bash
# macOS
brew install fvm

# 或使用 pub
dart pub global activate fvm
```

### 问题 4：某个包安装失败

**解决方案**：
```bash
# 单独处理该包
make clean PACKAGE=problem_package
make setup PACKAGE=problem_package
```

### 问题 5：代码生成失败

**解决方案**：
```bash
# 清理后重新生成
make clean
make codegen
```

## 与直接使用 Dart 脚本的对比

### 使用 Makefile（推荐）

```bash
make setup
make clean
make codegen
```

**优势**：
- ✅ 简短易记
- ✅ 自动处理 shell 依赖
- ✅ 统一的命令接口
- ✅ 支持包特定操作

### 直接使用 Dart 脚本

```bash
dart shell/bin/setup.dart
dart shell/bin/clean.dart
dart shell/bin/codegen.dart
```

**适用场景**：
- 需要传递特殊参数
- 调试脚本
- CI/CD 环境

## 在 CI/CD 中使用

### GitHub Actions 示例

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.7'
      
      - name: Install dependencies
        run: make setup
      
      - name: Generate code
        run: make codegen
      
      - name: Run tests
        run: flutter test
```

### GitLab CI 示例

```yaml
stages:
  - setup
  - build
  - test

setup:
  stage: setup
  script:
    - make setup
    - make codegen

test:
  stage: test
  script:
    - flutter test
```

## 最佳实践

### 1. 每日开发流程

```bash
# 早上开始工作
git pull
make setup  # 如果有依赖更新

# 开发时
make watch  # 在后台运行

# 提交前
make codegen  # 确保代码生成是最新的
```

### 2. 遇到问题时

```bash
# 第一步：尝试重新安装
make setup

# 第二步：如果还有问题，完整重置
make reset

# 第三步：如果特定包有问题
make reset PACKAGE=problem_package
```

### 3. 性能优化

```bash
# 只操作需要的包，而不是整个项目
make codegen PACKAGE=reflection_data  # 快
make codegen                          # 慢（所有包）
```

## 相关文档

- [自动化脚本文档](../shell/README.md)
- [Workspace 配置指南](./WORKSPACE_GUIDE.md)
- [项目 README](../README.md)

## 总结

Makefile 提供了简洁统一的命令接口：

✅ **自动化** - 自动处理依赖安装
✅ **简洁** - 短命令易记
✅ **灵活** - 支持全局和单包操作
✅ **可靠** - 自动确保前置条件满足

推荐在日常开发中使用 `make` 命令，提高开发效率！

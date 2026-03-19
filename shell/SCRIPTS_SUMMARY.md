# 自动化脚本工具总结

## 已实现的脚本

### 1. setup.dart - 项目初始化脚本

**功能**：一键安装项目所有依赖

**执行步骤**：
1. 配置 FVM Flutter 版本 (3.35.7)
2. 安装根目录依赖（如果存在）
3. 安装所有 packages 依赖
   - core 包（network, lt_uicomponent 等）
   - domain 包（reflection_domain, user_domain, wallet_domain）
   - data 包（reflection_data, user_data, wallet_data）
   - features 包（calendar, thread, add_answer 等）
   - utls 包（lt_annotation, date_utl）
4. 安装所有 apps 依赖
   - lt_app
   - algorithm_app

**使用场景**：
- 首次克隆项目后
- 切换分支后
- 依赖更新后
- CI/CD 环境初始化

### 2. clean.dart - 清理脚本

**功能**：清理项目中的所有构建产物和缓存

**清理内容**：
- `.dart_tool` 目录
- `build` 目录
- `.flutter-plugins` 文件
- `.flutter-plugins-dependencies` 文件
- `pubspec.lock` 文件

**使用场景**：
- 依赖冲突时
- 构建错误时
- 释放磁盘空间
- 重置项目状态

### 3. codegen.dart - 代码生成脚本

**功能**：为所有需要的包运行 build_runner

**支持的代码生成**：
- Riverpod Provider 生成
- Freezed 数据类生成
- JSON Serializable 序列化代码
- 自定义注解处理器

**特性**：
- 自动检测包含 build_runner 的包
- 支持 watch 模式（监听文件变化）
- 支持删除冲突文件选项

**使用场景**：
- 修改 Provider 后
- 修改数据模型后
- 添加新的注解后
- 开发模式（watch）

## 技术实现

### 架构设计

```
shell/
├── bin/
│   ├── setup.dart      # 依赖安装脚本
│   ├── clean.dart      # 清理脚本
│   └── codegen.dart    # 代码生成脚本
├── pubspec.yaml        # 脚本依赖
└── README.md           # 使用文档
```

### 核心技术

1. **Dart Process API**：执行 shell 命令
2. **Path 包**：跨平台路径处理
3. **IO 包**：文件系统操作
4. **Args 包**：命令行参数解析

### 设计原则

1. **自动检测**：自动发现需要处理的包
2. **错误处理**：友好的错误提示和恢复
3. **进度显示**：清晰的执行进度反馈
4. **跨平台**：支持 macOS、Linux、Windows
5. **可扩展**：易于添加新脚本

## 使用方式

### 方式 1：Makefile（推荐）

```bash
make setup      # 安装依赖
make clean      # 清理
make codegen    # 代码生成
make watch      # 监听模式
make reset      # 完整重置
```

### 方式 2：直接运行 Dart 脚本

```bash
dart shell/bin/setup.dart
dart shell/bin/clean.dart
dart shell/bin/codegen.dart
dart shell/bin/codegen.dart --watch
```

### 方式 3：添加到 PATH（可选）

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export PATH="$PATH:/path/to/project/shell/bin"

# 然后可以直接运行
setup.dart
clean.dart
codegen.dart
```

## 性能优化

### 并行执行

当前实现是串行执行，未来可以优化为并行：

```dart
await Future.wait([
  _runFlutterPubGet(dir1, name1),
  _runFlutterPubGet(dir2, name2),
  _runFlutterPubGet(dir3, name3),
]);
```

### 增量检测

可以添加增量检测，跳过已经是最新的包：

```dart
bool _needsUpdate(String directory) {
  final lockFile = File(path.join(directory, 'pubspec.lock'));
  final pubspecFile = File(path.join(directory, 'pubspec.yaml'));
  
  if (!lockFile.existsSync()) return true;
  
  return pubspecFile.lastModifiedSync()
      .isAfter(lockFile.lastModifiedSync());
}
```

## 扩展建议

### 1. test.dart - 测试脚本

```dart
// 运行所有测试
void main() async {
  await _runTestsForPackages();
  await _runTestsForApps();
}
```

### 2. analyze.dart - 代码分析脚本

```dart
// 运行 flutter analyze
void main() async {
  await _analyzeAllPackages();
  await _checkFormatting();
}
```

### 3. format.dart - 代码格式化脚本

```dart
// 格式化所有 Dart 代码
void main() async {
  await _formatAllDartFiles();
}
```

### 4. version.dart - 版本管理脚本

```dart
// 更新所有包的版本号
void main(List<String> args) async {
  final newVersion = args[0];
  await _updateAllVersions(newVersion);
}
```

### 5. deploy.dart - 部署脚本

```dart
// 构建和部署应用
void main() async {
  await _buildRelease();
  await _uploadToStore();
}
```

## 最佳实践

### 1. 首次使用

```bash
# 1. 克隆项目
git clone <repository>
cd <project>

# 2. 安装脚本依赖
cd shell
dart pub get
cd ..

# 3. 运行初始化
make setup

# 4. 运行代码生成
make codegen
```

### 2. 日常开发

```bash
# 开启 watch 模式
make watch

# 在另一个终端运行应用
cd apps/lt_app
fvm flutter run
```

### 3. 遇到问题时

```bash
# 完整重置
make reset

# 或分步执行
make clean
make setup
make codegen
```

### 4. CI/CD 集成

```yaml
# .github/workflows/ci.yml
steps:
  - name: Setup project
    run: dart shell/bin/setup.dart
    
  - name: Generate code
    run: dart shell/bin/codegen.dart
    
  - name: Run tests
    run: dart shell/bin/test.dart
```

## 故障排除

### 问题 1：FVM 未找到

**解决方案**：
```bash
# macOS
brew install fvm

# 或使用 pub
dart pub global activate fvm
```

### 问题 2：权限错误

**解决方案**：
```bash
chmod +x shell/bin/*.dart
```

### 问题 3：依赖冲突

**解决方案**：
```bash
make reset
```

### 问题 4：代码生成失败

**解决方案**：
```bash
# 清理后重新生成
make clean
make codegen
```

## 总结

这套自动化脚本工具大大简化了 Flutter 项目的日常开发任务：

✅ **节省时间**：一键完成复杂的多步骤操作
✅ **减少错误**：自动化避免手动操作失误
✅ **统一流程**：团队成员使用相同的工作流
✅ **易于维护**：使用 Dart 编写，与项目技术栈一致
✅ **可扩展**：易于添加新的自动化任务

未来可以继续扩展更多实用的脚本工具，进一步提升开发效率。

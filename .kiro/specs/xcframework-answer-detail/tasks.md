# 实施计划：answer_detail 模块编译为 XCFramework

## 概述

将 `answer_detail` 模块及其全部依赖编译为 iOS XCFramework 二进制产物。实施步骤按照依赖顺序排列：先创建 Flutter Module 工程结构，再编写入口文件和路由，然后编写构建脚本，接着编写集成文档，最后更新 Makefile 并验证整体流程。

## 任务

- [x] 1. 创建 Flutter Module 工程结构
  - [x] 1.1 创建 `apps/answer_detail_module/` 目录及 `pubspec.yaml`
    - 创建 `apps/answer_detail_module/pubspec.yaml`，声明 `name: answer_detail_module`
    - 配置 `resolution: workspace` 和 `environment.sdk: ^3.8.1`
    - 在 `dependencies` 中声明 `answer_detail` 及全部传递依赖（`feature_core`、`lt_uicomponent`、`reflection_domain`、`reflection_data`、`lt_network`、`lt_annotation`）的路径引用
    - 声明外部依赖：`flutter_riverpod`、`go_router`、`intl`
    - 配置 `flutter.module` 节，包含 `androidX`、`androidPackage`、`iosBundleIdentifier`
    - _需求: 1.1, 1.2, 1.3, 1.4_

  - [x] 1.2 注册到根 `pubspec.yaml` 的 workspace 列表
    - 在根 `pubspec.yaml` 的 `workspace:` 列表的 Apps 区域添加 `- apps/answer_detail_module`
    - _需求: 1.3_

  - [x] 1.3 创建 `apps/answer_detail_module/lib/` 和 `apps/answer_detail_module/test/` 目录结构
    - 创建空的 `test/` 目录（放置占位文件 `.gitkeep`）
    - _需求: 1.1_

- [x] 2. 实现 Dart 入口与路由注册
  - [x] 2.1 编写 `apps/answer_detail_module/lib/main.dart` 入口文件
    - 使用 `@pragma('vm:entry-point')` 注解标记 `main()` 函数
    - 初始化 `ProviderScope` 作为根 Widget
    - 配置 `GoRouter` 实例，注册三个路由：
      - `/` — 默认路由，展示加载占位界面
      - `/answer_detail` — `AnswerDetailPage`，通过 `state.extra` 接收 `AnswerEntity`
      - `/iconEditor` — `ExternalTextureEditor`，通过 `state.extra` 接收 `imagePath`
    - 使用 `MaterialApp.router` 包装 `GoRouter`
    - _需求: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3. 检查点 — 验证依赖解析
  - 在 `apps/answer_detail_module/` 目录下执行 `fvm flutter pub get`，确保全部依赖成功解析且无版本冲突
  - 确认所有测试通过，如有问题请询问用户
  - _需求: 1.5_

- [x] 4. 编写自动化构建脚本
  - [x] 4.1 创建 `shell/build_xcframework.sh` 构建脚本
    - 使用 `set -euo pipefail` 确保错误立即终止
    - 实现 Step 1：检查 FVM 安装及 Flutter 版本（3.35.7）
    - 实现 Step 2：在 `apps/answer_detail_module/` 下执行 `fvm flutter pub get`
    - 实现 Step 3：执行 `fvm flutter build ios-framework --no-debug --no-profile --output=build/ios/xcframework`
    - 实现 Step 4：验证 `App.xcframework` 和 `Flutter.xcframework` 产物存在
    - 每个步骤失败时输出明确的步骤名称和错误信息，以非零退出码终止
    - 设置脚本可执行权限（`chmod +x`）
    - _需求: 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2_

- [x] 5. 编写 Host App 集成指南
  - [x] 5.1 创建 `apps/answer_detail_module/INTEGRATION.md` 集成文档
    - 编写 XCFramework 产物说明章节：列出 `App.xcframework`、`Flutter.xcframework` 及插件 XCFramework
    - 编写 Xcode 工程配置步骤章节：如何将 XCFramework 添加到 Xcode 工程
    - 编写 FlutterEngine 初始化章节：Swift 代码示例，创建和启动 FlutterEngine
    - 编写展示 Flutter 页面章节：使用 FlutterViewController 展示 Flutter 界面
    - 编写 Platform Channel 注册章节：
      - `plugin.metal_overlay_view` UiKitView 原生视图工厂注册
      - `metal_texture_channel` MethodChannel 处理器（`initializeTexture`、`updateColor`）
      - `color_overlayer_{id}` 动态 MethodChannel 处理器（`updateColor`）
    - 编写数据传递章节：通过 FlutterEngine 的 `initialRoute` 或 MethodChannel 传递 `AnswerEntity` JSON 数据
    - _需求: 6.1, 6.2, 6.3, 6.4, 6.5, 5.5_

- [x] 6. 更新 Makefile
  - [x] 6.1 在 `Makefile` 中添加 `xcframework` 目标
    - 添加 `.PHONY` 声明
    - `xcframework` 目标调用 `bash shell/build_xcframework.sh`
    - _需求: 7.1, 7.2_

  - [x] 6.2 更新 `Makefile` 的 `help` 目标
    - 在 help 输出中添加 `make xcframework` 命令说明
    - _需求: 7.3_

- [x] 7. 最终检查点 — 验证整体流程
  - 确认 `apps/answer_detail_module/` 目录结构完整（`pubspec.yaml`、`lib/main.dart`、`INTEGRATION.md`）
  - 确认 `shell/build_xcframework.sh` 存在且可执行
  - 确认根 `pubspec.yaml` workspace 列表包含 `apps/answer_detail_module`
  - 确认 `Makefile` 包含 `xcframework` 目标
  - 确认所有测试通过，如有问题请询问用户
  - _需求: 1.1, 1.3, 3.1, 7.1_

## 说明

- 本特性不涉及属性基测试（PBT），核心工作为项目脚手架搭建、构建自动化和文档编写
- Platform Channel 兼容性通过保留现有代码行为来保证，不需要额外的错误处理代码
- 每个任务引用了具体的需求编号，确保需求全覆盖
- 检查点任务用于增量验证，确保每个阶段的产物正确

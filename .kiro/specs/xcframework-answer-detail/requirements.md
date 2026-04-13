# 需求文档：answer_detail 模块编译为 XCFramework

## 简介

将 Flutter monorepo 中的 `packages/features/answer_detail` 模块及其全部依赖编译为 iOS XCFramework，使其能够作为独立二进制产物被外部 iOS 原生工程集成调用。该模块包含答案详情页面、Metal 渲染叠加编辑器、外部纹理编辑器等组件，使用了 Platform Channels 与原生 Metal 渲染交互，依赖 Riverpod 状态管理和 GoRouter 路由。

## 术语表

- **XCFramework**：Apple 提供的多架构二进制分发格式，支持将多个平台（arm64 真机、arm64 模拟器、x86_64 模拟器）的 framework 打包为单一产物
- **Flutter_Module**：一个专门用于 add-to-app 场景的 Flutter 工程，作为 XCFramework 构建的入口工程
- **Host_App**：集成 XCFramework 的外部 iOS 原生工程
- **FlutterEngine**：Flutter 运行时引擎，负责 Dart 代码执行和渲染
- **Platform_Channel**：Flutter 与原生平台之间的通信机制，包括 MethodChannel 和 BasicMessageChannel
- **Build_Script**：自动化构建脚本，负责执行 XCFramework 的完整编译和打包流程
- **Entry_Point**：Flutter 模块的 Dart 入口，负责初始化 Flutter 应用并注册路由
- **Metal_Overlay_View**：通过 UiKitView 嵌入的原生 Metal 渲染视图，viewType 为 `plugin.metal_overlay_view`
- **Metal_Texture_Channel**：通过 MethodChannel（名称 `metal_texture_channel`）与原生 Metal 纹理渲染交互的通道
- **Color_Overlayer_Channel**：通过 MethodChannel（名称 `color_overlayer_{id}`）与原生颜色叠加渲染交互的通道

## 需求

### 需求 1：创建 Flutter Module 入口工程

**用户故事：** 作为 iOS 开发者，我希望有一个专用的 Flutter Module 工程作为 XCFramework 的构建入口，以便将 answer_detail 模块编译为可集成的二进制产物。

#### 验收标准

1. THE Flutter_Module SHALL 以 `flutter create --template module` 的标准结构创建，工程名为 `answer_detail_module`，位于 `apps/answer_detail_module/` 目录下
2. THE Flutter_Module SHALL 在 `pubspec.yaml` 中声明对 `answer_detail` 包及其全部传递依赖（`feature_core`、`lt_uicomponent`、`reflection_domain`、`reflection_data`、`lt_network`、`lt_annotation`）的路径引用
3. THE Flutter_Module SHALL 使用 `resolution: workspace` 并注册到根 `pubspec.yaml` 的 workspace 列表中，以复用 monorepo 统一的依赖版本管理
4. THE Flutter_Module SHALL 声明 `sdk: ^3.8.1` 环境约束，与项目现有 Dart SDK 版本保持一致
5. WHEN `fvm flutter pub get` 在 Flutter_Module 目录下执行时，THE Flutter_Module SHALL 成功解析全部依赖且无版本冲突

### 需求 2：实现 Dart 入口与路由注册

**用户故事：** 作为 iOS 开发者，我希望 Flutter 模块有一个清晰的 Dart 入口，以便 Host_App 能够启动 Flutter 引擎并展示 answer_detail 页面。

#### 验收标准

1. THE Entry_Point SHALL 在 `lib/main.dart` 中定义，使用 `@pragma('vm:entry-point')` 注解标记入口函数
2. THE Entry_Point SHALL 初始化 `ProviderScope`（Riverpod）作为根 Widget
3. THE Entry_Point SHALL 配置 GoRouter 实例，注册 `AnswerDetailRouteConfig` 中定义的全部路由（`/answer_detail` 和 `/iconEditor`）
4. THE Entry_Point SHALL 提供一个默认路由（`/`），展示 `AnswerDetailPage` 或一个占位页面，使 FlutterEngine 启动后有明确的初始界面
5. WHEN Host_App 通过 FlutterEngine 启动 Flutter 模块时，THE Entry_Point SHALL 在 FlutterEngine 初始化完成后渲染出初始界面

### 需求 3：自动化构建脚本

**用户故事：** 作为 iOS 开发者，我希望有一个一键构建脚本，以便能够快速将 Flutter 模块编译为 XCFramework 而无需手动执行多步操作。

#### 验收标准

1. THE Build_Script SHALL 以 shell 脚本形式存在于 `shell/build_xcframework.sh`，支持通过命令行直接执行
2. WHEN Build_Script 执行时，THE Build_Script SHALL 依次完成以下步骤：运行 `fvm flutter pub get`、执行 `fvm flutter build ios-framework --no-debug --no-profile --output=build/ios/xcframework`
3. THE Build_Script SHALL 在构建开始前检查 FVM 是否已安装且 Flutter 版本为 3.35.7，IF FVM 未安装或版本不匹配，THEN THE Build_Script SHALL 输出明确的错误信息并终止执行
4. WHEN 构建成功完成时，THE Build_Script SHALL 在 `apps/answer_detail_module/build/ios/xcframework/Release/` 目录下生成包含 `App.xcframework`、`Flutter.xcframework` 及全部插件 XCFramework 的产物
5. IF 构建过程中任一步骤失败，THEN THE Build_Script SHALL 输出失败步骤的名称和错误信息，并以非零退出码终止

### 需求 4：XCFramework 产物完整性

**用户故事：** 作为 iOS 开发者，我希望生成的 XCFramework 产物包含全部必要组件，以便 Host_App 能够完整运行 Flutter 模块的全部功能。

#### 验收标准

1. THE Build_Script SHALL 生成 `App.xcframework`，其中包含 answer_detail 模块的全部 Dart 编译产物（AOT 编译后的机器码）
2. THE Build_Script SHALL 生成 `Flutter.xcframework`，其中包含 Flutter 引擎运行时
3. WHEN answer_detail 模块依赖的 Flutter 插件包含原生 iOS 代码时，THE Build_Script SHALL 为每个此类插件生成对应的 XCFramework
4. THE XCFramework 产物 SHALL 支持 arm64 架构（iOS 真机），使 Host_App 能够在真机上运行
5. WHEN 全部 XCFramework 产物被集成到 Host_App 的 Xcode 工程中时，THE Host_App SHALL 能够编译通过且无链接错误

### 需求 5：Platform Channel 兼容性

**用户故事：** 作为 iOS 开发者，我希望 XCFramework 中的 Platform Channel 通信机制能够正常工作，以便 Host_App 能够提供 Metal 渲染等原生功能。

#### 验收标准

1. THE Flutter_Module SHALL 保留 `MetalOverlayEditor` 使用的 UiKitView 注册机制，viewType 为 `plugin.metal_overlay_view`，使 Host_App 能够注册对应的原生视图工厂
2. THE Flutter_Module SHALL 保留 `ExternalTextureEditor` 使用的 MethodChannel（名称 `metal_texture_channel`），使 Host_App 能够响应 `initializeTexture` 和 `updateColor` 方法调用
3. THE Flutter_Module SHALL 保留 `MetalOverlayEditor` 使用的动态 MethodChannel（名称模式 `color_overlayer_{id}`），使 Host_App 能够响应 `updateColor` 方法调用
4. WHEN Host_App 未注册对应的 Platform Channel 处理器时，IF Flutter 侧发起 Channel 调用，THEN THE Flutter_Module SHALL 通过 Flutter 标准异常机制抛出 `MissingPluginException`，而非导致应用崩溃
5. THE Flutter_Module SHALL 在集成文档中列出全部 Platform Channel 的名称、方法签名和参数格式，使 Host_App 开发者能够正确实现原生端处理器

### 需求 6：Host App 集成指南

**用户故事：** 作为 iOS 开发者，我希望有一份清晰的集成文档，以便能够将 XCFramework 正确集成到现有 iOS 工程中。

#### 验收标准

1. THE Flutter_Module SHALL 提供一份 `INTEGRATION.md` 集成文档，位于 `apps/answer_detail_module/` 目录下
2. THE 集成文档 SHALL 包含以下章节：XCFramework 产物说明、Xcode 工程配置步骤、FlutterEngine 初始化代码示例、展示 Flutter 页面的代码示例
3. THE 集成文档 SHALL 说明如何在 Host_App 中注册 `plugin.metal_overlay_view` 原生视图工厂
4. THE 集成文档 SHALL 说明如何在 Host_App 中实现 `metal_texture_channel` 和 `color_overlayer_{id}` 的 MethodChannel 处理器
5. THE 集成文档 SHALL 说明如何通过 FlutterEngine 的初始路由或 MethodChannel 向 Flutter 模块传递 `AnswerEntity` 数据，使 `AnswerDetailPage` 能够接收并展示答案详情

### 需求 7：Makefile 集成

**用户故事：** 作为开发者，我希望 XCFramework 的构建命令集成到项目现有的 Makefile 中，以便与现有工作流保持一致。

#### 验收标准

1. THE Makefile SHALL 新增 `xcframework` 目标，执行 XCFramework 的完整构建流程
2. WHEN `make xcframework` 执行时，THE Makefile SHALL 调用 `shell/build_xcframework.sh` 完成构建
3. THE Makefile SHALL 在 `help` 目标中列出 `xcframework` 命令的说明

# 需求文档：Pigeon Platform Channel

## 简介

使用 Flutter Pigeon 替代 `answer_detail_module` 中手写的 MethodChannel 通信代码，实现 Flutter ↔ iOS 原生端之间类型安全的双向通信。Pigeon 通过 schema 定义自动生成 Dart 和 Swift 两端的通信代码，消除手写方法字符串、手动序列化/反序列化以及接口不同步等问题。

## 术语表

- **Pigeon**：Flutter 官方提供的代码生成工具，通过 Dart schema 文件定义接口，自动生成 Dart 和 Swift（或 Kotlin/ObjC/Java）两端的类型安全通信代码
- **HostApi**：Pigeon 中由原生端实现、Dart 端调用的接口（Flutter → iOS 方向）
- **FlutterApi**：Pigeon 中由 Dart 端实现、原生端调用的接口（iOS → Flutter 方向）
- **Schema**：Pigeon 的接口定义文件（`.dart` 文件），包含数据类和 API 接口声明
- **Answer_Detail_Module**：构建为 iOS XCFramework 的 Flutter Module，位于 `apps/answer_detail_module/`
- **Host_App**：集成 XCFramework 的 iOS 原生应用
- **AnswerEntity**：答案业务实体，包含 id、content、createTms、createYmd、question、icon 等字段
- **QuestionEntity**：问题业务实体，包含 id、title、category、pinned、subCategory 等字段
- **CategoryEntity**：分类业务实体，包含 id、name、color 等字段
- **IconEntity**：图标业务实体，包含 status、url 等字段
- **Pigeon_Message**：Pigeon 自动生成的消息类（数据传输对象），用于跨平台序列化传输

## 需求

### 需求 1：Pigeon Schema 定义

**用户故事：** 作为开发者，我希望在一个 Dart schema 文件中定义 Flutter ↔ iOS 的通信接口和数据结构，以便 Pigeon 自动生成两端的类型安全代码。

#### 验收标准

1. THE Schema SHALL 在 `apps/answer_detail_module/pigeons/answer_detail_api.dart` 路径下定义 Pigeon schema 文件
2. THE Schema SHALL 定义与 AnswerEntity 对应的 Pigeon 消息类，包含 id（String）、content（String）、createTms（String?）、createYmd（String?）、question（PigeonQuestion?）、icon（PigeonIcon?）字段
3. THE Schema SHALL 定义与 QuestionEntity 对应的 Pigeon 消息类，包含 id（String）、title（String）、category（PigeonCategory）、pinned（bool）、subCategory（PigeonCategory?）字段
4. THE Schema SHALL 定义与 CategoryEntity 对应的 Pigeon 消息类，包含 id（String）、name（String）、color（String?）字段
5. THE Schema SHALL 定义与 IconEntity 对应的 Pigeon 消息类，包含 status（String）、url（String）字段
6. THE Schema SHALL 使用 `@ConfigurePigeon` 注解配置 Dart 输出路径为 `lib/src/generated/answer_detail_api.g.dart`，Swift 输出路径为 `ios/answer_detail_api.g.swift`

### 需求 2：iOS → Flutter 数据推送接口（FlutterApi）

**用户故事：** 作为 iOS 开发者，我希望通过类型安全的接口将 Answer 数据推送给 Flutter 端，以便替代手写的 `channel.invokeMethod("setAnswerData", arguments: json)` 调用。

#### 验收标准

1. THE Schema SHALL 定义一个 `AnswerDetailFlutterApi` 接口，使用 `@FlutterApi()` 注解标记
2. THE AnswerDetailFlutterApi SHALL 包含 `setAnswerData(PigeonAnswer answer)` 方法，接收类型安全的 PigeonAnswer 参数
3. WHEN Host_App 调用生成的 Swift 端 `AnswerDetailFlutterApi.setAnswerData` 方法时，THE Answer_Detail_Module SHALL 接收到完整的 PigeonAnswer 对象
4. WHEN Answer_Detail_Module 接收到 PigeonAnswer 数据时，THE Answer_Detail_Module SHALL 将 Pigeon_Message 转换为 AnswerEntity 并导航到 answer_detail 页面

### 需求 3：Flutter → iOS 操作通知接口（HostApi）

**用户故事：** 作为 Flutter 开发者，我希望通过类型安全的接口通知 iOS 原生端执行操作（如关闭页面），以便替代手写的 `channel.invokeMethod("dismiss")` 调用。

#### 验收标准

1. THE Schema SHALL 定义一个 `AnswerDetailHostApi` 接口，使用 `@HostApi()` 注解标记
2. THE AnswerDetailHostApi SHALL 包含 `dismiss()` 方法，用于通知 Host_App 关闭 FlutterViewController
3. WHEN Flutter 端调用生成的 Dart 端 `AnswerDetailHostApi.dismiss()` 方法时，THE Host_App SHALL 接收到关闭通知
4. THE AnswerDetailHostApi 的 `dismiss()` 方法 SHALL 不携带任何参数

### 需求 4：Pigeon 代码生成配置

**用户故事：** 作为开发者，我希望通过标准命令生成 Pigeon 通信代码，以便在开发流程中方便地更新接口定义。

#### 验收标准

1. WHEN 执行 Pigeon 代码生成命令时，THE Pigeon SHALL 在 `apps/answer_detail_module/lib/src/generated/` 目录下生成 Dart 端通信代码
2. WHEN 执行 Pigeon 代码生成命令时，THE Pigeon SHALL 在 `apps/answer_detail_module/ios/` 目录下生成 Swift 端通信代码
3. THE 生成的 Dart 代码 SHALL 包含 PigeonAnswer、PigeonQuestion、PigeonCategory、PigeonIcon 消息类以及 AnswerDetailFlutterApi 和 AnswerDetailHostApi 的 Dart 端实现骨架
4. THE 生成的 Swift 代码 SHALL 包含对应的 Swift 消息类以及 AnswerDetailFlutterApi 和 AnswerDetailHostApi 的 Swift 端协议和实现
5. THE Answer_Detail_Module 的 `pubspec.yaml` SHALL 将 `pigeon` 声明为 `dev_dependencies`

### 需求 5：Pigeon_Message 与 Domain Entity 的转换

**用户故事：** 作为开发者，我希望 Pigeon 生成的消息类能够方便地与现有的 Domain Entity 互相转换，以便在不修改 Domain 层的前提下使用 Pigeon 通信。

#### 验收标准

1. THE Answer_Detail_Module SHALL 提供 PigeonAnswer 到 AnswerEntity 的转换逻辑
2. THE 转换逻辑 SHALL 正确映射所有字段，包括 createTms 和 createYmd 的 String 到 DateTime 转换
3. THE 转换逻辑 SHALL 正确处理可空字段（question、icon、createTms、createYmd、subCategory、color）
4. IF PigeonAnswer 中的 createTms 或 createYmd 字段为 null 或格式无效，THEN THE 转换逻辑 SHALL 将对应的 DateTime 字段设为 null
5. THE 转换逻辑 SHALL 正确映射 IconEntity 的 status 字段（String 到 IconStatus 枚举的转换）

### 需求 6：替换现有 MethodChannel 代码

**用户故事：** 作为开发者，我希望用 Pigeon 生成的代码完全替换 `main.dart` 中手写的 MethodChannel 通信逻辑，以便消除手写字符串和手动类型转换。

#### 验收标准

1. THE Answer_Detail_Module 的 main.dart SHALL 移除手写的 `MethodChannel('answer_detail_data_channel')` 实例
2. THE Answer_Detail_Module 的 main.dart SHALL 移除 `channel.setMethodCallHandler` 回调和 `_castMap` 辅助方法
3. THE Answer_Detail_Module 的 main.dart SHALL 使用 Pigeon 生成的 `AnswerDetailFlutterApi` 实现类接收 iOS 端推送的数据
4. THE Answer_Detail_Module 的 main.dart SHALL 使用 Pigeon 生成的 `AnswerDetailHostApi` 实例调用 dismiss 方法
5. WHEN AnswerDetailPage 的关闭按钮被点击时，THE Answer_Detail_Module SHALL 通过 AnswerDetailHostApi.dismiss() 通知 Host_App，而非通过手写 MethodChannel

### 需求 7：iOS 集成文档更新

**用户故事：** 作为 iOS 开发者，我希望集成文档反映 Pigeon 替代 MethodChannel 后的变化，以便正确集成新的通信接口。

#### 验收标准

1. THE INTEGRATION.md SHALL 更新 Platform Channel 注册章节，说明 Pigeon 生成的 Swift 协议和注册方式
2. THE INTEGRATION.md SHALL 更新数据传递章节，展示使用 Pigeon 生成的 Swift API 替代手写 MethodChannel 的调用方式
3. THE INTEGRATION.md SHALL 包含 Host_App 实现 `AnswerDetailHostApi` Swift 协议的示例代码
4. THE INTEGRATION.md SHALL 包含 Host_App 调用 `AnswerDetailFlutterApi.setAnswerData` 的示例代码

### 需求 8：XCFramework 兼容性

**用户故事：** 作为开发者，我希望 Pigeon 生成的代码在 XCFramework 构建模式下正常工作，以便不影响现有的 iOS 集成方式。

#### 验收标准

1. THE Pigeon 生成的 Swift 代码 SHALL 与 XCFramework 构建产物兼容，不引入额外的动态链接依赖
2. THE Pigeon 生成的 Dart 代码 SHALL 能够通过 `make xcframework MODULE=answer_detail_module` 正常编译为 AOT 产物
3. THE Pigeon 通信 SHALL 基于 Flutter 标准 BinaryMessenger 协议，与现有的 FlutterEngine 初始化流程兼容
4. WHILE Host_App 使用已启动的 FlutterEngine 实例时，THE Pigeon 生成的 API SHALL 能够正常注册和通信

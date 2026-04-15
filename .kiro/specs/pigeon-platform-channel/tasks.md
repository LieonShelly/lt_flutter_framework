# Implementation Plan: Pigeon Platform Channel

## 概述

将 `answer_detail_module` 中手写的 MethodChannel 通信代码替换为 Pigeon 自动生成的类型安全通信代码。按照依赖顺序，先定义 Schema 并生成代码，再实现转换层和 FlutterApi，然后改造 main.dart，最后更新集成文档。

## Tasks

- [x] 1. 添加 Pigeon 依赖并创建 Schema 文件
  - [x] 1.1 在 `apps/answer_detail_module/pubspec.yaml` 的 `dev_dependencies` 中添加 `pigeon` 依赖
    - 添加 `pigeon: ^22.7.4`（或最新稳定版）到 dev_dependencies
    - 运行 `fvm flutter pub get` 确保依赖安装成功
    - _需求: 4.5_
  - [x] 1.2 创建 Pigeon Schema 文件 `apps/answer_detail_module/pigeons/answer_detail_api.dart`
    - 使用 `@ConfigurePigeon` 注解配置 Dart 输出路径 `lib/src/generated/answer_detail_api.g.dart` 和 Swift 输出路径 `ios/answer_detail_api.g.swift`
    - 定义 `PigeonAnswer` 消息类，包含 id(String)、content(String)、createTms(String?)、createYmd(String?)、question(PigeonQuestion?)、icon(PigeonIcon?) 字段
    - 定义 `PigeonQuestion` 消息类，包含 id(String)、title(String)、category(PigeonCategory)、pinned(bool)、subCategory(PigeonCategory?) 字段
    - 定义 `PigeonCategory` 消息类，包含 id(String)、name(String)、color(String?) 字段
    - 定义 `PigeonIcon` 消息类，包含 status(String)、url(String) 字段
    - 定义 `@FlutterApi()` 标记的 `AnswerDetailFlutterApi` 接口，包含 `setAnswerData(PigeonAnswer answer)` 方法
    - 定义 `@HostApi()` 标记的 `AnswerDetailHostApi` 接口，包含 `dismiss()` 方法
    - _需求: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 3.1, 3.2, 3.4_
  - [x] 1.3 执行 Pigeon 代码生成命令
    - 在 `apps/answer_detail_module` 目录下运行 `fvm dart run pigeon --input pigeons/answer_detail_api.dart`
    - 验证生成的 Dart 文件 `lib/src/generated/answer_detail_api.g.dart` 存在且包含 PigeonAnswer、PigeonQuestion、PigeonCategory、PigeonIcon 消息类以及 AnswerDetailFlutterApi、AnswerDetailHostApi 的 Dart 端代码
    - 验证生成的 Swift 文件 `ios/answer_detail_api.g.swift` 存在且包含对应的 Swift 协议和实现
    - _需求: 4.1, 4.2, 4.3, 4.4_

- [x] 2. 实现 Pigeon 消息类与 Domain Entity 的转换层
  - [x] 2.1 创建转换层文件 `apps/answer_detail_module/lib/src/pigeon_converters.dart`
    - 实现 `PigeonAnswerConverter` extension on `PigeonAnswer`，提供 `toAnswerEntity()` 方法
    - 实现 `PigeonQuestionConverter` extension on `PigeonQuestion`，提供 `toQuestionEntity()` 方法
    - 实现 `PigeonCategoryConverter` extension on `PigeonCategory`，提供 `toCategoryEntity()` 方法
    - 实现 `PigeonIconConverter` extension on `PigeonIcon`，提供 `toIconEntity()` 方法，使用 `IconStatus.fromString(status.toUpperCase())` 转换枚举
    - 实现 `_tryParseDateTime(String? value)` 辅助函数，处理 null、空字符串和无效格式，返回 `DateTime?`
    - `QuestionEntity.answers` 字段在转换时设为 `const []`
    - _需求: 5.1, 5.2, 5.3, 5.4, 5.5_
  - [ ]* 2.2 编写转换层属性基测试 — Property 1: PigeonAnswer → AnswerEntity 转换保持数据完整性
    - 在 `apps/answer_detail_module/test/pigeon_converters_property_test.dart` 中编写测试
    - 使用 `glados` 包生成随机 PigeonAnswer 对象（包含各种可空字段组合）
    - 验证转换后 id、content 直接相等，createTms/createYmd 的 String 值经 DateTime.parse 后与转换结果相等，嵌套 question/icon 递归正确映射，可空字段为 null 时转换结果也为 null
    - **Property 1: PigeonAnswer → AnswerEntity 转换保持数据完整性**
    - **Validates: Requirements 2.4, 5.1, 5.2, 5.3, 5.5**
  - [ ]* 2.3 编写转换层属性基测试 — Property 2: 无效 DateTime 字符串的安全处理
    - 在同一测试文件中编写测试
    - 使用 `glados` 包生成随机字符串作为 createTms/createYmd
    - 验证当字段为 null、空字符串或非 ISO 8601 格式时，转换结果的 DateTime 字段为 null，且不抛出异常
    - **Property 2: 无效 DateTime 字符串的安全处理**
    - **Validates: Requirements 5.4**
  - [ ]* 2.4 编写转换层单元测试
    - 在 `apps/answer_detail_module/test/pigeon_converters_test.dart` 中编写测试
    - 测试完整 PigeonAnswer 转换（包含所有字段的标准转换）
    - 测试最小 PigeonAnswer 转换（仅必填字段，可选字段全部为 null）
    - 测试 IconStatus 各枚举值映射（GENERATED/PENDING/FAILED/UNKNOWN 及无效值）
    - 测试 createTms/createYmd 为空字符串和无效格式的情况
    - _需求: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 3. Checkpoint — 确保转换层测试通过
  - 运行 `cd apps/answer_detail_module && fvm flutter test` 确保所有测试通过，如有问题请询问用户。

- [x] 4. 实现 FlutterApi 并改造 main.dart
  - [x] 4.1 创建 FlutterApi 实现类 `apps/answer_detail_module/lib/src/answer_detail_flutter_api_impl.dart`
    - 实现 Pigeon 生成的 `AnswerDetailFlutterApi` 抽象类
    - 构造函数接收 `GoRouter` 实例
    - 在 `setAnswerData` 方法中调用 `answer.toAnswerEntity()` 转换数据，然后通过 `_router.go('/answer_detail', extra: entity)` 导航
    - 使用 try-catch 捕获转换异常，debugPrint 输出错误信息
    - _需求: 2.3, 2.4, 6.3_
  - [x] 4.2 改造 `apps/answer_detail_module/lib/main.dart`
    - 移除 `MethodChannel('answer_detail_data_channel')` 实例声明
    - 移除 `channel.setMethodCallHandler` 回调
    - 移除 `_castMap` 辅助方法
    - 添加 `AnswerDetailHostApi` 实例字段
    - 在 `initState` 中调用 `AnswerDetailFlutterApi.setUp(AnswerDetailFlutterApiImpl(_router))` 注册 FlutterApi 实现
    - 将 `AnswerDetailPage` 的 `onClose` 回调改为调用 `_hostApi.dismiss()`
    - 保留 GoRouter 路由配置和 iconEditor 路由不变
    - _需求: 6.1, 6.2, 6.3, 6.4, 6.5_
  - [ ]* 4.3 编写 main.dart 相关单元测试
    - 在 `apps/answer_detail_module/test/answer_detail_flutter_api_impl_test.dart` 中编写测试
    - 测试 `AnswerDetailFlutterApiImpl.setAnswerData` 正确调用 GoRouter 导航
    - 测试 `setAnswerData` 转换异常时不崩溃
    - _需求: 2.3, 2.4, 6.3_

- [x] 5. Checkpoint — 确保所有代码编译通过且测试通过
  - 运行 `cd apps/answer_detail_module && fvm flutter test` 确保所有测试通过，如有问题请询问用户。

- [x] 6. 更新集成文档
  - [x] 6.1 更新 `apps/answer_detail_module/INTEGRATION.md`
    - 更新 Platform Channel 注册章节（第 5 节），新增 Pigeon 生成的 Swift 协议注册说明，包括 `AnswerDetailHostApiSetup.setUp` 和 `AnswerDetailFlutterApi` 的初始化方式
    - 更新数据传递章节（第 6 节），将手写 MethodChannel 方式替换为 Pigeon 生成的 Swift API 调用方式
    - 添加 Host_App 实现 `AnswerDetailHostApi` Swift 协议的示例代码（实现 `dismiss()` 方法关闭 FlutterViewController）
    - 添加 Host_App 调用 `AnswerDetailFlutterApi.setAnswerData` 的示例代码（构造 PigeonAnswer 对象并推送数据）
    - 更新统一注册入口 `registerPlatformChannels` 函数，加入 Pigeon API 注册调用
    - _需求: 7.1, 7.2, 7.3, 7.4_

- [ ] 7. 最终验证 — 确保编译通过和 XCFramework 兼容
  - 运行 `cd apps/answer_detail_module && fvm flutter test` 确保所有测试通过
  - 运行 `cd apps/answer_detail_module && fvm flutter build ios-framework --no-debug --no-profile` 或等效命令验证 AOT 编译通过（确保 Pigeon 生成的代码不影响 XCFramework 构建）
  - 如有问题请询问用户。
  - _需求: 8.1, 8.2, 8.3, 8.4_

## Notes

- 标记 `*` 的子任务为可选任务，可跳过以加速 MVP 交付
- 每个任务引用了具体的需求编号，确保可追溯性
- Checkpoint 任务确保增量验证，及时发现问题
- 属性基测试使用 `glados` 包验证转换层的通用正确性属性
- 单元测试验证具体示例和边界情况
- Pigeon 生成的代码（`.g.dart` 和 `.g.swift`）应提交到仓库，与项目现有的代码生成策略一致

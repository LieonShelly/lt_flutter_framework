# 实现计划：FFI 图像处理器

## 概述

将 lt_app 的图像后处理通道从 `FlutterMethodChannel` 迁移到 `dart:ffi`，消除序列化/反序列化和深拷贝开销。实现分为四个阶段：创建原生 C 桥接层、创建 Dart FFI 绑定层、修改 `ImageProcessor` 使用 FFI、清理旧 MethodChannel 代码。

## Tasks

- [x] 1. 创建原生 C 桥接层 `ImageProcessorBridge.swift`
  - [x] 1.1 创建 `apps/lt_app/ios/Runner/ImageProcessorBridge.swift`，实现 `@_cdecl("process_icon")` 函数
    - 接受 `UnsafePointer<UInt8>` 输入指针、`Int32` 输入长度、`UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>` 输出指针、`UnsafeMutablePointer<Int32>` 输出长度
    - 内部从输入指针构建 `Data`，解码为 `UIImage`，调用 `MetalImageProcessor.shared.processSync(_:thickness: 4)`
    - 处理结果编码为 PNG，通过 `malloc` 分配输出缓冲区并拷贝数据
    - 返回状态码：0=成功，1=UIImage 解码失败，2=Metal 处理失败，3=PNG 编码失败
    - _需求：1.1, 1.2, 1.3, 1.4, 1.6, 6.1, 6.2_

  - [x] 1.2 在同一文件中实现 `@_cdecl("free_processed_data")` 函数
    - 接受 `UnsafeMutablePointer<UInt8>?`，调用 `free()` 释放内存
    - 处理 nil 指针的安全检查
    - _需求：1.5, 4.2_

- [x] 2. 创建 Dart FFI 绑定层 `ffi_bridge.dart`
  - [x] 2.1 创建 `packages/core/lt_uicomponent/lib/src/image_processor/ffi_bridge.dart`
    - 定义 `ProcessIconNative` / `ProcessIconDart` 和 `FreeProcessedDataNative` / `FreeProcessedDataDart` 类型别名
    - 使用 `DynamicLibrary.process()` 加载符号
    - 通过 `lookupFunction` 绑定 `process_icon` 和 `free_processed_data`
    - _需求：2.1, 2.2_

  - [x] 2.2 实现 `FfiBridge.processIcon(Uint8List imageBytes)` 方法
    - 使用 `malloc<Uint8>` 分配输入缓冲区并拷贝数据
    - 分配输出指针 `Pointer<Pointer<Uint8>>` 和输出长度 `Pointer<Int32>`
    - 调用原生 `process_icon`，检查返回状态码
    - 成功时通过 `Uint8List.fromList(outPtr.asTypedList(outLen))` 拷贝输出到 Dart 堆
    - 使用 `try/finally` 确保所有原生内存释放：`malloc.free(inputPtr)`、`_freeProcessedData(outPtr)`、`malloc.free(outPtrPtr)`、`malloc.free(outLenPtr)`
    - 非零状态码时返回 null
    - _需求：2.3, 2.4, 2.5, 2.6, 4.1, 4.2, 4.3, 4.4_

  - [ ]* 2.3 编写属性测试：内存拷贝保真性
    - **属性 1：内存拷贝保真性**
    - 使用 `glados` 生成随机 `Uint8List`（长度 0 到合理上限）
    - 通过 `malloc` 分配原生内存并拷贝，验证 `inputPtr.asTypedList(length)` 与原始数据逐字节一致
    - 释放内存后完成
    - 标签：`Feature: ffi-image-processor, Property 1: 内存拷贝保真性`
    - **验证需求：2.3**

  - [ ]* 2.4 编写属性测试：FFI 调用异常安全性
    - **属性 2：FFI 调用异常安全性**
    - 使用 `glados` 生成随机字节数组（空、小、大、随机内容）
    - 调用 `FfiBridge.processIcon`，验证返回值为 `Uint8List` 或 `null`，不抛出未捕获异常
    - 标签：`Feature: ffi-image-processor, Property 2: FFI 调用异常安全性`
    - 注意：此测试需要 iOS 真机/模拟器环境
    - **验证需求：4.1, 4.2, 4.3**

- [x] 3. 修改 `ImageProcessor` 使用 FFI
  - [x] 3.1 修改 `packages/core/lt_uicomponent/lib/src/image_processor/image_processor.dart`
    - 移除 `MethodChannel` 导入和 `_channel` 常量
    - 导入 `dart:isolate` 和 `ffi_bridge.dart`
    - 将 `processIcon` 实现改为 `Isolate.run(() => FfiBridge.processIcon(imageBytes))`
    - 保持 `catch` 块打印错误并返回 null 的行为
    - 保持 `IconParams` 类不变
    - _需求：3.1, 3.2, 3.3, 3.4, 3.5, 5.1_

  - [ ]* 3.2 编写单元测试验证 `ImageProcessor` API 兼容性
    - 验证 `processIcon` 方法签名为 `static Future<Uint8List?>`
    - 验证 `IconParams` 类保持不变
    - _需求：3.1_

- [x] 4. 检查点 - 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户。

- [x] 5. 清理 MethodChannel 代码
  - [x] 5.1 清理 `apps/lt_app/ios/Runner/AppDelegate.swift`
    - 移除 `imageChannel` 的 `FlutterMethodChannel` 创建代码
    - 移除 `setMethodCallHandler` 闭包及其内部所有图像处理分发逻辑
    - 保留 `GeneratedPluginRegistrant.register(with: self)` 和 `super.application(...)` 调用
    - _需求：5.2_

  - [x] 5.2 验证 `image_processor.dart` 中无 MethodChannel 残留引用
    - 确认无 `flutter/services.dart` 导入（除非其他代码需要）
    - 确认无 `MethodChannel` 或 `PlatformException` 引用
    - _需求：5.1_

  - [ ]* 5.3 编写集成测试验证端到端流程
    - 在 iOS 环境中通过 `ImageProcessor.processIcon` 处理测试图像
    - 验证输出为有效 PNG（检查 PNG 魔数 `[137, 80, 78, 71]`）
    - 验证无效数据输入返回 null 且无崩溃
    - _需求：1.3, 2.4, 3.4, 3.5, 6.2_

- [x] 6. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过，如有问题请询问用户。

## 备注

- 标记 `*` 的任务为可选任务，可跳过以加速 MVP
- 每个任务引用了具体的需求编号以确保可追溯性
- `MetalImageProcessor.swift`、`Shaders.metal`、`ProcessedIconImageProvider` 不需要修改
- 属性测试 1（内存拷贝）可在任何平台运行；属性测试 2 和集成测试需要 iOS 环境

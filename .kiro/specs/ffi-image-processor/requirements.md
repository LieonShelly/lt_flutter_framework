# 需求文档

## 简介

当前 lt_app 的图像后处理流程通过 FlutterMethodChannel 与 iOS 原生 Metal 图像处理器交互。图像数据（`Uint8List`）在 Dart 层与原生层之间需要经过序列化/反序列化和深拷贝，导致严重的 CPU 开销、内存抖动（Memory Churn）和 UI 掉帧。

本特性将使用 `dart:ffi` 替代 MethodChannel，通过共享内存指针直接传递图像数据，消除跨层序列化开销。原生端继续复用现有的 `MetalImageProcessor` Metal GPU 处理管线。

## 术语表

- **FFI_Bridge**: 基于 `dart:ffi` 的 Dart 外部函数接口桥接层，负责通过 C 函数指针与原生代码交互
- **Image_Processor**: Dart 侧图像处理入口类，位于 `packages/core/lt_uicomponent`，负责调用原生图像处理并返回结果
- **MetalImageProcessor**: iOS 原生端基于 Metal GPU 的图像处理器，执行内容边界检测、加粗和去背景操作
- **C_Bridge**: 原生侧暴露给 FFI 的 C 接口层，负责接收内存指针和长度参数，调用 MetalImageProcessor 并写回结果
- **Shared_Memory**: Dart 与原生之间通过 `Pointer<Uint8>` 共享的内存区域，避免数据拷贝
- **ProcessedIconImageProvider**: Flutter `ImageProvider` 子类，负责编排下载、处理、缓存、解码的完整流程
- **Processed_Icon_View**: 展示经过处理的图标图像的 Flutter Widget

## 需求

### 需求 1：C 桥接层接口定义

**用户故事：** 作为开发者，我希望原生端暴露标准 C 函数接口，以便 Dart 通过 FFI 直接调用原生图像处理功能。

#### 验收标准

1. THE C_Bridge SHALL 暴露一个 C 函数 `process_icon`，接受输入图像数据指针（`const uint8_t*`）、输入数据长度（`int32_t`）、输出数据指针（`uint8_t**`）和输出数据长度指针（`int32_t*`）作为参数，返回 `int32_t` 状态码
2. WHEN `process_icon` 被调用时，THE C_Bridge SHALL 将输入数据指针和长度传递给 MetalImageProcessor 进行处理，并将处理结果写入输出指针
3. WHEN MetalImageProcessor 处理成功时，THE C_Bridge SHALL 返回状态码 0，并将输出 PNG 数据的指针和长度写入对应的输出参数
4. IF MetalImageProcessor 处理失败，THEN THE C_Bridge SHALL 返回非零状态码，并将输出长度设为 0
5. THE C_Bridge SHALL 暴露一个 C 函数 `free_processed_data`，接受指针参数，用于释放 `process_icon` 分配的输出内存
6. THE C_Bridge SHALL 使用 `@_cdecl` 或 `extern "C"` 确保函数符号以 C 链接方式导出，使 `dart:ffi` 可通过 `DynamicLibrary` 查找到该符号

### 需求 2：Dart FFI 桥接层实现

**用户故事：** 作为开发者，我希望 Dart 侧通过 `dart:ffi` 直接调用原生 C 函数，以消除 MethodChannel 的序列化开销。

#### 验收标准

1. THE FFI_Bridge SHALL 使用 `DynamicLibrary.process()` 或 `DynamicLibrary.executable()` 加载包含 C_Bridge 符号的动态库
2. THE FFI_Bridge SHALL 通过 `lookup` 和 `asFunction` 绑定 `process_icon` 和 `free_processed_data` 两个原生函数
3. WHEN 调用 `process_icon` 时，THE FFI_Bridge SHALL 将 Dart `Uint8List` 图像数据通过 `malloc` 分配原生内存并拷贝数据，传递指针和长度给原生函数
4. WHEN 原生函数返回成功状态码时，THE FFI_Bridge SHALL 从输出指针读取处理后的 PNG 数据，转换为 Dart `Uint8List` 返回
5. WHEN 原生函数返回后，THE FFI_Bridge SHALL 调用 `free_processed_data` 释放原生侧分配的输出内存，并释放 Dart 侧分配的输入内存
6. IF 原生函数返回非零状态码，THEN THE FFI_Bridge SHALL 返回 null 表示处理失败

### 需求 3：Image_Processor 接口替换

**用户故事：** 作为开发者，我希望 `ImageProcessor.processIcon()` 的内部实现从 MethodChannel 切换为 FFI 调用，同时保持公开 API 签名不变，以避免上层调用方的修改。

#### 验收标准

1. THE Image_Processor SHALL 保持 `static Future<Uint8List?> processIcon(Uint8List imageBytes)` 的公开方法签名不变
2. WHEN `processIcon` 被调用时，THE Image_Processor SHALL 通过 FFI_Bridge 调用原生 `process_icon` 函数，而非通过 MethodChannel 发送消息
3. THE Image_Processor SHALL 在 isolate 或通过 `compute` 执行 FFI 调用，避免阻塞 UI 线程
4. WHEN FFI 调用成功时，THE Image_Processor SHALL 返回处理后的 PNG 图像数据（`Uint8List`）
5. IF FFI 调用失败，THEN THE Image_Processor SHALL 返回 null，与当前 MethodChannel 实现的错误行为保持一致

### 需求 4：内存安全管理

**用户故事：** 作为开发者，我希望 FFI 交互过程中的所有原生内存都能被正确分配和释放，避免内存泄漏。

#### 验收标准

1. THE FFI_Bridge SHALL 在每次 `process_icon` 调用完成后释放 Dart 侧通过 `malloc` 分配的输入缓冲区
2. THE FFI_Bridge SHALL 在读取完输出数据后调用 `free_processed_data` 释放原生侧分配的输出缓冲区
3. IF 在 FFI 调用过程中发生异常，THEN THE FFI_Bridge SHALL 在 `finally` 块中确保所有已分配的原生内存被释放
4. THE C_Bridge SHALL 仅在处理成功时分配输出内存，处理失败时输出指针保持为 null

### 需求 5：MethodChannel 清理

**用户故事：** 作为开发者，我希望移除不再使用的 MethodChannel 图像处理代码，保持代码库整洁。

#### 验收标准

1. WHEN FFI 桥接层完成并验证后，THE Image_Processor SHALL 移除对 `MethodChannel("com.ltapp.image_processor")` 的所有引用
2. WHEN FFI 桥接层完成并验证后，THE AppDelegate SHALL 移除 `imageChannel` 的 `setMethodCallHandler` 注册代码及相关的图像处理分发逻辑

### 需求 6：处理结果一致性

**用户故事：** 作为开发者，我希望 FFI 方案产出的图像处理结果与原 MethodChannel 方案完全一致，确保用户体验无变化。

#### 验收标准

1. THE C_Bridge SHALL 调用与当前 MethodChannel 处理路径相同的 `MetalImageProcessor.shared.processSync` 方法，使用相同的 `thickness: 4` 参数
2. THE C_Bridge SHALL 将处理结果编码为 PNG 格式数据，与当前 MethodChannel 返回的格式一致
3. FOR ALL 有效的输入图像数据，通过 FFI 路径处理后的 PNG 输出 SHALL 与通过 MethodChannel 路径处理后的 PNG 输出在像素级别一致

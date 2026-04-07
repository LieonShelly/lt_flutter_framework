# lt_app 工程图像后处理性能优化
## 现有存在的问题
- 现在 lt_app 工程中对应 图片 的后处理（image_processor）是通过 FlutterMethodChannel 的方式调用 iOS 端的 Metal 图像处理，但是以这种 FlutterMethodChannel 这种方式有一个致命性能的问题：如果走 MethodChannel，这块庞大的数据必须从 Dart 层序列化为二进制，跨越线程跳跃到原生层，再反序列化。这不仅极其消耗 CPU，还会导致极其严重的内存抖动（Memory Churn）和掉帧。

## 涉及到的文件路径
- lt_app工程路径： apps/lt_app
- processed_icon_views 使用图像后处理能力的控件： packages/features/feature_core/lib/src/processed_icon_view.dart
- image_processor 图像后处理 Flutter 端代码 packages/core/lt_uicomponent/lib/src/image_processor/image_processor.dart
- FlutterMethodChannel 在iOS端的调用入口 apps/lt_app/ios/Runner/AppDelegate.swift
- iOS端图像后处理逻辑 apps/lt_app/ios/Runner/MetalImageProcessor.swift

## 期望优化的方向
- 我希望能够优化这块性能，不通过 MethodChannel和原生交互。想使用 FFi 这种方式与原生交互，原生端还是继续使用 MetalImageProcessor 中的方式对图像进行处理

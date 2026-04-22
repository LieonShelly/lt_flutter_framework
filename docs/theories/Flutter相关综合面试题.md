
#### Flutter & iOS 混合栈开发核心面试题预测
基于“iOS 转 Flutter 及混合栈开发”的 JD，面试官通常会重点考察**跨端通信、混合栈路由、内存与渲染机制对比、以及工程化状态管理**四个维度：

**1. 混合栈与工程化架构**
- **路由管理**：原生与 Flutter 混合栈如何管理页面跳转？（单引擎复用 vs 多引擎，是否有使用 `flutter_boost` 或 `Thrio` 的经验，如何解决混合栈场景下的内存激增问题？）
- **产物集成**：CocoaPods 如何集成 Flutter？（源码依赖 vs Framework 产物依赖，如何做 CI/CD 自动化构建打包？）
- **状态管理**：BLoC / Riverpod / GetX 等状态管理的选型依据是什么？在复杂业务模块中，如何解耦 UI 与业务逻辑？

**2. 跨端通信与 Plugin**
- **Platform Channel 原理**：MethodChannel、EventChannel 和 BasicMessageChannel 的区别与适用场景？
- **性能瓶颈**：Channel 通信是跑在哪个线程的？如果需要传输大量数据（如大图片、视频流），Channel 带来的序列化/反序列化性能损耗怎么解决？（引申：C++ FFI、纹理共享 Texture 机制）。
- **插件开发**：如何编写和发布一个完整的 Plugin？如何处理 iOS 原生侧的 AppDelegate 生命周期事件注入？

**3. 核心机制对比 (Swift vs Dart)**
- **内存管理**：Dart 的 GC (分代垃圾回收) 与 Swift 的 ARC 有何本质区别？
- **并发模型**：Dart 的单线程 Event Loop（Isolate / Microtask / Event queue）与 Swift 的 GCD / async-await 模型对比？
- **UI 渲染**：Flutter 的三棵树（Widget, Element, RenderObject）机制，与 iOS UIKit / SwiftUI 的对比及重绘优化策略。

**4. 调试与性能定位**
- **崩溃与调试定位**：Flutter 混合工程在 iOS 端发生 Crash（如内存溢出 OOM、野指针），如何通过 Xcode / Instruments 配合 dSYM 文件进行跨栈定位？
- **包体积优化**：引入 Flutter 后包体积变大，如何进行双端瘦身？

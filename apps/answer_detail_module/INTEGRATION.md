# answer_detail_module XCFramework 集成指南

本文档说明如何将 `answer_detail_module` 构建产出的 XCFramework 集成到 iOS 原生工程（Host App）中，包括工程配置、FlutterEngine 初始化、页面展示、Platform Channel 注册及数据传递。

---

## 目录

1. [XCFramework 产物说明](#1-xcframework-产物说明)
2. [Xcode 工程配置步骤](#2-xcode-工程配置步骤)
3. [FlutterEngine 初始化](#3-flutterengine-初始化)
4. [展示 Flutter 页面](#4-展示-flutter-页面)
5. [Platform Channel 注册](#5-platform-channel-注册)
6. [数据传递](#6-数据传递)

---

## 1. XCFramework 产物说明

执行 `make xcframework` 或 `bash shell/build_xcframework.sh` 后，构建产物位于：

```
apps/answer_detail_module/build/ios/xcframework/Release/
```

| 产物名称 | 说明 |
|---|---|
| `App.xcframework` | answer_detail 模块的 Dart 代码经 AOT 编译后的机器码，包含全部业务逻辑和 UI |
| `Flutter.xcframework` | Flutter 引擎运行时，提供 Dart VM、渲染引擎、Platform Channel 通信等基础能力 |
| 插件 XCFramework（如有） | 当 answer_detail 依赖的 Flutter 插件包含原生 iOS 代码时，会为每个插件生成独立的 XCFramework（例如 `path_provider_foundation.xcframework` 等） |

> **注意**：所有 XCFramework 均需集成到 Host App 中，缺少任何一个都可能导致运行时链接错误。

---

## 2. Xcode 工程配置步骤

### 2.1 添加 XCFramework 到工程

1. 将 `Release/` 目录下的全部 `.xcframework` 文件拷贝到 Host App 工程目录中（建议放在 `Frameworks/` 子目录）
2. 在 Xcode 中选择 Host App Target → **General** → **Frameworks, Libraries, and Embedded Content**
3. 点击 **+** 按钮，选择 **Add Other... → Add Files...**，添加全部 `.xcframework` 文件
4. 确保每个 XCFramework 的 Embed 选项设置为 **Embed & Sign**

### 2.2 配置 Framework Search Paths

1. 选择 Host App Target → **Build Settings**
2. 搜索 **Framework Search Paths**
3. 添加 XCFramework 所在目录的路径，例如：`$(PROJECT_DIR)/Frameworks`

### 2.3 其他配置

- 确保 **Build Settings → Enable Bitcode** 设置为 `No`（Flutter 不支持 Bitcode）
- 确保 **Deployment Target** ≥ 12.0（Flutter 最低支持版本）
- 如果遇到 `dyld: Library not loaded` 错误，检查 XCFramework 是否全部设置为 **Embed & Sign**

---

## 3. FlutterEngine 初始化

在 Host App 中创建并启动 `FlutterEngine`。建议在 `AppDelegate` 中初始化，以便在需要展示 Flutter 页面时引擎已就绪。

```swift
import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var flutterEngine: FlutterEngine = {
        let engine = FlutterEngine(name: "answer_detail_engine")
        return engine
    }()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 启动 FlutterEngine（使用默认入口 main()）
        flutterEngine.run()

        // 注册 Platform Channel 处理器（详见第 5 节）
        registerPlatformChannels(engine: flutterEngine)

        return true
    }
}
```

> **说明**：
> - `FlutterEngine(name:)` 的 `name` 参数用于标识引擎实例，可自定义
> - `flutterEngine.run()` 会执行 Dart 入口函数 `main()`，启动 Flutter 应用
> - 建议在 `didFinishLaunchingWithOptions` 中预热引擎，避免首次展示 Flutter 页面时出现延迟

---

## 4. 展示 Flutter 页面

使用 `FlutterViewController` 展示 Flutter 渲染的界面：

```swift
import Flutter

func showAnswerDetailPage(from viewController: UIViewController) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    let flutterViewController = FlutterViewController(
        engine: appDelegate.flutterEngine,
        nibName: nil,
        bundle: nil
    )

    // 以模态方式展示
    flutterViewController.modalPresentationStyle = .fullScreen
    viewController.present(flutterViewController, animated: true)
}
```

> **说明**：
> - `FlutterViewController` 复用已启动的 `FlutterEngine`，不会重复初始化
> - 也可以使用 `navigationController?.pushViewController` 以导航方式展示
> - Flutter 模块启动后默认展示加载占位界面（`CircularProgressIndicator`），需通过数据传递（第 6 节）导航到具体页面

---

## 5. Platform Channel 注册

answer_detail 模块使用了三种 Platform Channel 与原生端通信。Host App 必须注册对应的处理器，否则 Flutter 侧调用时会抛出 `MissingPluginException`。

### 5.1 `plugin.metal_overlay_view` — UiKitView 原生视图工厂

Flutter 侧通过 `UiKitView` 嵌入原生 Metal 渲染视图。Host App 需要注册一个 `FlutterPlatformViewFactory`。

```swift
import Flutter

// MARK: - Metal Overlay View Factory

class MetalOverlayViewFactory: NSObject, FlutterPlatformViewFactory {

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let creationParams = args as? [String: Any]
        return MetalOverlayPlatformView(
            frame: frame,
            viewId: viewId,
            args: creationParams,
            messenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Metal Overlay Platform View

class MetalOverlayPlatformView: NSObject, FlutterPlatformView {

    private let metalView: UIView // 替换为实际的 Metal 渲染视图
    private let viewId: Int64
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewId: Int64,
        args: [String: Any]?,
        messenger: FlutterBinaryMessenger
    ) {
        self.viewId = viewId

        // 从 creationParams 中获取 imagePath
        let imagePath = args?["imagePath"] as? String ?? ""

        // 创建 Metal 渲染视图（根据实际需求实现）
        self.metalView = UIView(frame: frame) // TODO: 替换为实际的 Metal 渲染视图
        _ = imagePath // TODO: 使用 imagePath 加载图片到 Metal 渲染管线

        // 注册动态 MethodChannel（color_overlayer_{viewId}）
        self.channel = FlutterMethodChannel(
            name: "color_overlayer_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        // 处理 updateColor 方法调用
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "updateColor":
                if let rgba = call.arguments as? [Double], rgba.count == 4 {
                    let red = rgba[0]
                    let green = rgba[1]
                    let blue = rgba[2]
                    let alpha = rgba[3]
                    // TODO: 将 RGBA 值应用到 Metal 渲染管线
                    self.applyColor(red: red, green: green, blue: blue, alpha: alpha)
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "INVALID_ARGS",
                        message: "updateColor 需要 [double, double, double, double] 参数",
                        details: nil
                    ))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        return metalView
    }

    private func applyColor(red: Double, green: Double, blue: Double, alpha: Double) {
        // TODO: 实现 Metal 颜色叠加渲染逻辑
        // red, green, blue, alpha 值域均为 [0.0, 1.0]
    }
}

// MARK: - 注册视图工厂

func registerMetalOverlayViewFactory(engine: FlutterEngine) {
    let factory = MetalOverlayViewFactory(messenger: engine.binaryMessenger)
    let registrar = engine.registrar(forPlugin: "MetalOverlayViewPlugin")
    registrar.register(factory, withId: "plugin.metal_overlay_view")
}
```

**creationParams 格式**：

| 参数名 | 类型 | 说明 |
|---|---|---|
| `imagePath` | `String` | 需要渲染的图片文件路径 |

### 5.2 `metal_texture_channel` — MethodChannel 处理器

Flutter 侧通过此 Channel 请求初始化 Metal 纹理并更新颜色参数。

```swift
import Flutter

func registerMetalTextureChannel(engine: FlutterEngine) {
    let channel = FlutterMethodChannel(
        name: "metal_texture_channel",
        binaryMessenger: engine.binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
        switch call.method {

        case "initializeTexture":
            // 参数: {'imagePath': String}
            guard let args = call.arguments as? [String: Any],
                  let imagePath = args["imagePath"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "initializeTexture 需要 {'imagePath': String} 参数",
                    details: nil
                ))
                return
            }

            // 创建 Metal 纹理并注册到 FlutterTextureRegistry
            let textureRegistry = engine.registrar(forPlugin: "MetalTexturePlugin").textures()
            let textureId = createMetalTexture(
                imagePath: imagePath,
                textureRegistry: textureRegistry
            )

            // 返回 textureId（int?），Flutter 侧用于 Texture widget
            result(textureId)

        case "updateColor":
            // 参数: [double r, double g, double b, double a]，值域 [0.0, 1.0]
            guard let rgba = call.arguments as? [Double], rgba.count == 4 else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "updateColor 需要 [double, double, double, double] 参数",
                    details: nil
                ))
                return
            }

            let red = rgba[0]
            let green = rgba[1]
            let blue = rgba[2]
            let alpha = rgba[3]

            // TODO: 更新 Metal 纹理的颜色叠加参数
            updateMetalTextureColor(red: red, green: green, blue: blue, alpha: alpha)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - Metal 纹理管理（需根据实际需求实现）

func createMetalTexture(
    imagePath: String,
    textureRegistry: FlutterTextureRegistry
) -> Int64? {
    // TODO: 实现 Metal 纹理创建逻辑
    // 1. 使用 imagePath 加载图片
    // 2. 创建 Metal 纹理对象（实现 FlutterTexture 协议）
    // 3. 调用 textureRegistry.register(_:) 注册纹理
    // 4. 返回 textureId
    return nil
}

func updateMetalTextureColor(red: Double, green: Double, blue: Double, alpha: Double) {
    // TODO: 实现颜色更新逻辑
    // 更新 Metal 渲染管线中的颜色叠加参数
}
```

**方法签名汇总**：

| 方法名 | 参数 | 返回值 | 说明 |
|---|---|---|---|
| `initializeTexture` | `{'imagePath': String}` | `int?`（textureId） | 初始化 Metal 纹理，返回 `Texture` widget 使用的 textureId |
| `updateColor` | `[double, double, double, double]`（RGBA，值域 `[0.0, 1.0]`） | `void` | 更新 Metal 纹理的颜色叠加参数 |

### 5.3 `color_overlayer_{id}` — 动态 MethodChannel 处理器

此 Channel 在 `UiKitView` 创建时动态生成，`{id}` 为 `onPlatformViewCreated` 回调返回的 `platformViewId`。

> **注意**：如果你按照 5.1 节的方式在 `MetalOverlayPlatformView` 的 `init` 中注册了 `color_overlayer_{viewId}` 的 MethodChannel 处理器，则无需额外注册。该 Channel 已在视图创建时自动绑定。

**方法签名**：

| 方法名 | 参数 | 返回值 | 说明 |
|---|---|---|---|
| `updateColor` | `[double, double, double, double]`（RGBA，值域 `[0.0, 1.0]`） | `void` | 更新指定 Metal Overlay View 的颜色叠加参数 |

### 5.4 Pigeon API 注册

answer_detail 模块使用 [Pigeon](https://pub.dev/packages/pigeon) 自动生成类型安全的双向通信代码，替代手写 MethodChannel。生成的 Swift 代码位于 `ios/answer_detail_api.g.swift`，Host App 需要将该文件添加到 Xcode 工程中。

#### AnswerDetailHostApi — Flutter → iOS

Host App 需要实现 `AnswerDetailHostApi` Swift 协议，处理 Flutter 端发起的操作请求（如关闭页面）。

```swift
import Flutter

/// 实现 Pigeon 生成的 AnswerDetailHostApi 协议
class AnswerDetailHostApiHandler: AnswerDetailHostApi {

    private weak var flutterViewController: FlutterViewController?

    init(flutterViewController: FlutterViewController?) {
        self.flutterViewController = flutterViewController
    }

    func dismiss() throws {
        flutterViewController?.dismiss(animated: true)
    }
}
```

使用 `AnswerDetailHostApiSetup.setUp` 注册协议实现：

```swift
func registerAnswerDetailHostApi(engine: FlutterEngine, flutterVC: FlutterViewController?) {
    let handler = AnswerDetailHostApiHandler(flutterViewController: flutterVC)
    AnswerDetailHostApiSetup.setUp(
        binaryMessenger: engine.binaryMessenger,
        api: handler
    )
}
```

#### AnswerDetailFlutterApi — iOS → Flutter

Host App 通过 `AnswerDetailFlutterApi` 实例向 Flutter 端推送数据（如 Answer 详情）。无需实现协议，直接创建实例即可调用：

```swift
let flutterApi = AnswerDetailFlutterApi(binaryMessenger: engine.binaryMessenger)
```

> **说明**：
> - `AnswerDetailHostApiSetup.setUp` 必须在 `FlutterEngine.run()` 之后调用
> - `AnswerDetailFlutterApi` 实例可在需要推送数据时随时创建
> - 生成的 Swift 文件 `answer_detail_api.g.swift` 需添加到 Xcode 工程的编译源文件中

### 5.5 统一注册入口

在 `AppDelegate` 中统一注册全部 Platform Channel 处理器：

```swift
func registerPlatformChannels(engine: FlutterEngine, flutterVC: FlutterViewController? = nil) {
    // 1. 注册 Metal Overlay View 原生视图工厂
    //    （同时处理 color_overlayer_{id} 动态 Channel）
    registerMetalOverlayViewFactory(engine: engine)

    // 2. 注册 Metal Texture Channel
    registerMetalTextureChannel(engine: engine)

    // 3. 注册 Pigeon 生成的 AnswerDetailHostApi
    registerAnswerDetailHostApi(engine: engine, flutterVC: flutterVC)
}
```

---

## 6. 数据传递

Host App 需要将 Answer 数据传递给 Flutter 模块，以便 `AnswerDetailPage` 展示答案详情。模块使用 Pigeon 生成的类型安全 API 进行数据传递。

### 6.1 Pigeon 数据类型

Pigeon 生成的 Swift 数据类型定义在 `answer_detail_api.g.swift` 中：

| Swift 类型 | 字段 | 说明 |
|---|---|---|
| `ApiAnswer` | `id: String`, `content: String`, `createTms: String?`, `createYmd: String?`, `question: ApiQuestion?`, `icon: ApiIcon?` | 答案数据 |
| `ApiQuestion` | `id: String`, `title: String`, `category: ApiCategory`, `pinned: Bool`, `subCategory: ApiCategory?` | 问题数据 |
| `ApiCategory` | `id: String`, `name: String`, `color: String?` | 分类数据 |
| `ApiIcon` | `status: String`, `url: String` | 图标数据（status 值：`GENERATED`/`PENDING`/`FAILED`/`UNKNOWN`） |

### 6.2 方式一：通过 Pigeon API 传递数据（推荐）

在 FlutterEngine 启动后，通过 Pigeon 生成的 `AnswerDetailFlutterApi` 将类型安全的数据推送给 Flutter 端。Flutter 端自动将 Pigeon 消息类转换为 Domain Entity 并导航到详情页。

**Swift 侧（Host App）**：

```swift
import Flutter

func sendAnswerData(engine: FlutterEngine, answer: ApiAnswer) {
    let flutterApi = AnswerDetailFlutterApi(binaryMessenger: engine.binaryMessenger)

    flutterApi.setAnswerData(answer: answer) { result in
        switch result {
        case .success:
            print("Answer data sent successfully")
        case .failure(let error):
            print("Failed to send answer data: \(error)")
        }
    }
}

// 使用示例
func presentAnswerDetail(from viewController: UIViewController) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    // 构造类型安全的 ApiAnswer 对象
    let category = ApiCategory(id: "cat-001", name: "日常", color: nil)
    let question = ApiQuestion(
        id: "question-001",
        title: "今天让你感到开心的事情是什么？",
        category: category,
        pinned: false,
        subCategory: nil
    )
    let icon = ApiIcon(status: "GENERATED", url: "https://example.com/icon.png")
    let answer = ApiAnswer(
        id: "answer-001",
        content: "这是答案内容...",
        createTms: "2025-01-15T10:30:00.000Z",
        createYmd: "2025-01-15",
        question: question,
        icon: icon
    )

    // 展示 Flutter 页面
    let flutterVC = FlutterViewController(
        engine: appDelegate.flutterEngine,
        nibName: nil,
        bundle: nil
    )
    flutterVC.modalPresentationStyle = .fullScreen
    viewController.present(flutterVC, animated: true)

    // 推送数据给 Flutter 端
    sendAnswerData(engine: appDelegate.flutterEngine, answer: answer)
}
```

> **说明**：
> - 使用 Pigeon 生成的 Swift 类型（`ApiAnswer`、`ApiQuestion` 等），编译器会检查字段类型和必填项
> - `setAnswerData` 的 completion 回调可用于确认数据是否成功送达 Flutter 端
> - Flutter 端接收到数据后，自动将 Pigeon 消息类转换为 `AnswerEntity` 并导航到 `AnswerDetailPage`

### 6.3 方式二：通过 initialRoute 传递数据

将 JSON 数据编码到 `FlutterEngine` 的 `initialRoute` 中。适用于数据量较小的场景。

> **注意**：此方式不推荐，建议优先使用方式一（Pigeon API）。Pigeon 方式提供编译时类型检查，避免手动 JSON 序列化/反序列化。

**Swift 侧（Host App）**：

```swift
import Flutter

func launchWithAnswerData(answerJson: [String: Any]) -> FlutterEngine {
    let engine = FlutterEngine(name: "answer_detail_engine")

    // 将 JSON 编码为字符串，拼接到 initialRoute
    if let jsonData = try? JSONSerialization.data(withJSONObject: answerJson),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        // 格式: /answer_detail?data=<URL编码的JSON>
        let encodedJson = jsonString.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? ""
        let route = "/answer_detail?data=\(encodedJson)"

        engine.navigationChannel.invokeMethod("setInitialRoute", arguments: route)
    }

    engine.run()
    return engine
}
```

**Dart 侧解析**：

```dart
GoRoute(
  path: '/answer_detail',
  builder: (context, state) {
    // 优先从 extra 获取（MethodChannel 方式）
    if (state.extra is AnswerEntity) {
      return AnswerDetailPage(answer: state.extra as AnswerEntity);
    }

    // 从 queryParameters 解析（initialRoute 方式）
    final dataStr = state.uri.queryParameters['data'];
    if (dataStr != null) {
      final json = jsonDecode(Uri.decodeComponent(dataStr));
      final answer = AnswerEntity.fromJson(json as Map<String, dynamic>);
      return AnswerDetailPage(answer: answer);
    }

    // 兜底：返回加载界面
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  },
),
```

> **建议**：推荐使用 **方式一（Pigeon API）**，原因如下：
> - 编译时类型检查，Swift 编译器会验证字段类型和必填项
> - 无需手动 JSON 序列化/反序列化，消除运行时类型转换错误
> - 支持在 Flutter 页面已展示后动态更新数据
> - Pigeon 自动生成两端代码，接口变更时编译器会提示所有需要修改的位置

---

## 常见问题

### Q: 运行时报 `MissingPluginException` 错误

**原因**：Host App 未注册对应的 Platform Channel 处理器。

**解决**：确保在 `FlutterEngine.run()` 之后、展示 `FlutterViewController` 之前，调用 `registerPlatformChannels(engine:)` 注册全部处理器。

### Q: 编译时报 `dyld: Library not loaded` 错误

**原因**：XCFramework 未正确嵌入到 App Bundle 中。

**解决**：检查 Xcode Target → General → Frameworks, Libraries, and Embedded Content 中所有 XCFramework 是否设置为 **Embed & Sign**。

### Q: Flutter 页面显示空白

**原因**：`FlutterEngine` 未正确启动，或未传递 `AnswerEntity` 数据。

**解决**：
1. 确认 `flutterEngine.run()` 已调用
2. 确认通过 Pigeon API（`AnswerDetailFlutterApi.setAnswerData`）或 initialRoute 传递了有效数据
3. 检查 Xcode 控制台是否有 Flutter 相关的错误日志

#### Swift并发相关
- 与 GCD 并发的区别
    - Swift 现代并发模型带来了三个核心概念，构建了所谓**“结构化并发（Structured Concurrency）”**的基石。
    - async / await (异步函数的语法糖)：
        - 它允许你以同步代码的书写直觉，去表达异步的逻辑。代码是从上往下线性执行的。遇到 await 关键字时，当前任务会被挂起（Suspend），但它绝对不会阻塞当前底层的线程。底层会让出线程的控制权去执行其他任务，等异步结果回来后，再从上次挂起的地方**恢复（Resume）**执行。
        ``` Swift
         // 传统的闭包回调方式 (晦涩且容易出错)
        func fetchUserData(completion: @escaping (Result<User, Error>) -> Void) { ... }

        // 现代的 async/await 方式 (清晰、线性、支持原生 try-catch)
        func fetchUserData() async throws -> User {
            let url = URL(string: "https://api.example.com/user")!
            // 代码在此处挂起，不阻塞线程，等待网络返回
            let (data, _) = try await URLSession.shared.data(from: url) 
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        }

        ```
    - 结构化并发 (Task & TaskGroup)：
        - 如果你想让多个网络请求并发执行，就需要用到 async let 或者 TaskGroup。它将并发任务的生命周期与代码的作用域（Scope）绑定。编译器和运行时会保证：父任务只有在所有子任务都完成后才会完成。同时它原生支持取消传播（Cancellation Propagation）—— 如果父任务被取消，所有的子任务会自动收到取消协作信号，极大减少了无用功。
    - Actor (状态隔离)：
        - 这是解决数据竞争（Data Race）的终极武器。在传统的 Class 中，多线程同时读写同一个属性会导致难以排查的 Crash。而 actor 是一种全新的引用类型，它在内部维护了一个隔离域（Isolation Domain）。任何从外部访问 actor 可变状态的操作，都必须跨越隔离域，即必须加上 await 异步等待。这就从编译器层面强制保证了同一时间只有一个任务能访问其内部状态，优雅地干掉了容易引发死锁的传统锁机制（Lock/Mutex/Semaphore）。
    - 这是高级面试的加分项。Swift 并发模型不再像 GCD 那样疯狂开辟新线程。它在底层默认维护了一个最大数量与设备 CPU 核心数相等的协作式线程池。
        - 当代码执行到 await 遇到网络 I/O 挂起时，系统会将当前任务的状态打包成一个 Continuation 保存到堆区。此时，底层的真实线程会被立刻释放，转去线程池里拿别的活跃任务执行。当网络数据返回后，系统再把之前的 Continuation 放回执行队列，等待线程池有空闲线程时去恢复执行。
        - 结论： 极少量的物理线程就能处理海量的并发任务，彻底消除了线程爆炸和频繁上下文切换带来的性能损耗。
- 举例：相册图片相似度检测案例
    - 1. 数据获取：安全且轻量地加载相册 (PhotoKit)
    - 2. 核心引擎：提取图像特征向量 (Vision Framework)
    - 3. 相似度计算与分组策略 (Clustering Algorithm)
    - 4. 性能调优：利用现代并发 (Modern Concurrency)

#### GithubAction 在项目上的应用

#### 在 iOS 开发中，你是如何做性能优化的？主要优化哪些方面？
在 iOS 开发中，性能优化是一个系统性的工程。我们通常遵循**“先测量，后优化”**的原则，借助 Instruments 和 MetricKit 发现瓶颈，主要集中在以下五个基本面的优化：

**1. 启动耗时优化 (Launch Time)**
主线思路：减少不必要的操作，将耗时任务延迟或异步执行。
* **Pre-main（`main()` 执行前）优化：**
    * **减少动态库注入：** 苹果建议尽量合并动态库或使用静态库（Static Framework），以降低 `dyld` （动态链接器）加载的时间。
    * **清理无用类与分类：** 减少 Objective-C 运行时加载类和结构体的开销。
    * **慎用 `+load`：** `+load` 会在类装载时立即执行，阻塞主线程。如果有初始化需求，尽量推迟或改用懒加载的 `+initialize`。
* **Post-main（`main()` 执行后）优化：**
    * **懒加载与延迟加载：** 首页非必需的视图、数据以及 SDK 等待首屏渲染完毕后再加载。
    * **异步初始化：** 利用后台线程进行耗时但不需要马上与 UI 交互的服务的初始化任务。
    * **优化用户预期：** 利用占位图或骨架屏（Skeleton View）缓解等待带来的焦虑。

**2. 流畅度与渲染优化 (Smoothness & UI Rendering)**
保证页面以 60 FPS (甚至 120 FPS) 运行是对用户的尊重。
* **释放主线程：** 取消在主线程里做冗杂的数据解析、文本高度的计算（如复杂的 `TextKit` 计算）等，移步子线程计算好之后将结果交付主线程刷新。
* **减少离屏渲染 (Off-screen Rendering)：** 圆角（`cornerRadius` 配合 `masksToBounds`）、阴影（`shadow`）、遮罩（`mask`）是触发离屏渲染的常客。这种机制需要在 GPU 和 off-screen 缓冲区之间频繁切换，能让设计出切图解决的就不要写代码，非要写的可使用 `Core Graphics` 子线程预先绘制成带圆角的图片。
* **控制视图层级（View Hierarchy）：** 层级嵌套越深，Auto Layout 和绘制的开销越大，避免多级无用的透明 View 叠加。
* **注重重用 (Reuse Mechanisms)：** 对于长列表，务必用好 `UITableView` / `UICollectionView` 的 Cell 重用池，不在 Cell 的 `cellForRowAt` 里做无畏的创建或布局操作。

**3. 内存吃紧与 OOM 优化 (Memory Management / OOM)**
内存泄漏极容易导致 App 发热甚至因系统强杀导致 Crash (Out Of Memory)。
* **狙击循环引用 (Retain Cycles)：**
    * 严防 Block/Closure 的滥用，该上 `[weak self]` 或 `[unowned self]` 时不可手软。
    * `NSTimer` 与代理的循环引用，可以通过 `weak` 持有一层代理对象（Proxy/Wrapper）进行解耦。
    * `Delegate` 坚持使用 `weak`。
* **大型图片的温和加载：**
    * 当图片体积过大（甚至几十 MB）但只需要很小的展示窗口时，不可直接将原图加载到内存中。应选用 `ImageIO` (如 `CGImageSourceCreateThumbnailAtIndex`) 提供 **降采样 (Downsampling)** 方案加载所需的足够分大小缩略图。及时释放在视野外的图缓存。
* **合理的系统缓存策略：** 灵活使用 `NSCache` ，因为在内存吃紧时系统会自动驱逐内部缓存数据，优于传统的字典内存缓存。

**4. 安装包瘦身带来飞轮效应 (App Binary Size)**
安装包体积变小，可以提高商店的新增转化率。
* **图片等资源的压榨：** 使用无损或高压格式文件（比如 WebP）。删除没用的旧图。
* **编译器优化：** 在 Xcode 设置中打开如 **LTO (Link-Time Optimization)** 选项，开启 **Strip Linked Product** 清理多余汇编指令、符号表进行脱壳。
* **代码清理：** 对冗余未使用的代码用脚本扫出后坚决移除。
* **按需派发资源 (ODR)：** 并不急用的特定场景的视听资源配置成 On-Demand Resources 放在云上。

**5. 耗电量优化：保护手机电池 (Energy & Battery)**
不要让 App 变成“暖宝宝”。
* **合并与精简网络请求：** 碎片化的网络申请极度消耗天线基带功耗（无线模块在唤醒状态非常耗电），应当尝试合并请求，使用正确的缓存策略。将能延迟到 WiFi 环境下载的内容延后。
* **克制地理定位：** 定位精度（如 `kCLLocationAccuracyBest`）越高耗电越大，满足要求即可，并在退居后台时适时停用相关传感器监听。
* **暂停背景空耗：** App 按下 Home 键回到后台状态后，主动并彻底关闭循环动画、定时器及无关后台任务，以符合应用生命周期规律。

---
> [!TIP]
> **排雷利器 (Instruments):**
> 任何性能优化必须依靠数据说话。
> 1. **Time Profiler:** 用于测量代码开销（尤其是主线程的卡顿和 CPU 占用）。
> 2. **Allocations:** 记录内存对象的派生和生命周期，查验内存增长波段。
> 3. **Leaks:** 能够直指没有释放发生泄漏的对象。
> 4. **Core Animation (现融合在 Xcode 中):** 用于实时检测帧率及导致离屏渲染的地方（如 Color Blended Layers 等标记）。

#### 在 iOS 开发中，如何防止中间人攻击 (MitM) ?
在移动端业务中，特别是金融或包含敏感信息的应用，单纯使用 HTTPS 仍可能由于用户（或黑客）在设备上安装并信任了抓包工具的根证书，从而被 Charles/Fiddler 截获甚至篡改数据。防止中间人攻击的核心防御手段可以分为以下四层：

**1. 基础防线：全站 HTTPS 与 ATS (App Transport Security)**
* **ATS 要求**：苹果默认机制，要求 App 网络通信必须走 HTTPS。
* 本质上它是防网络节点嗅探，但**防不住**端侧主动信任了伪造根证书的中间人攻击。

**2. 核心防线：SSL/Certificate Pinning (证书锁定/公钥锁定)**
这是移动端**防抓包与防 MitM 攻击最常用、最有效**的技术手段。
* **原理**：将服务器端合法的公钥或证书直接硬编码（或者保存其 Hash 值）预埋在 App 包内。当发起 HTTPS TLS 握手时，拦截系统的默认证书链校验，改由代码强制比对服务器下发的证书数据与本地保存的是否一致。若存在中间人伪造证书，比对必致失败，App 会立刻切断连接。
* **实现方案**：
    * **原生 URLSession**：实现 `URLSessionDelegate` 的 `urlSession(_:didReceive:completionHandler:)` 方法，拦截处理 `URLAuthenticationChallenge` 认证挑战。
    * **第三方网络库**：利用 `Alamofire` 的 `ServerTrustManager`，或 `AFNetworking` 的 `AFSecurityPolicy` 快速配置 Pinning 模式。
* **最佳实践**：不要锁定会过期的证书本身，而应该锁定**公钥 (Public Key)**，并在 App 内多预埋一颗备用公钥（Backup Key），防止服务端更换证书而导致老版本 App 大面积断网。

**3. 补充防线：报文级加密与数字签名 (Payload Encryption & Signature)**
当面临越狱设备 (Jailbreak) 使用 Frida/hook 越权强行移除掉 SSL Pinning 代码时，依然保全数据的兜底方案：
* **非明文传输**：使用对称加密（如 AES）将 Request Body 与 Response Body 加密。对称加密的密钥可以通过非对称加密（如 RSA）在首次启动建联时安全下发至客户端。
* **防篡改与防重放 (Sign 签名)**：将请求的所有参数、时间戳 (Timestamp)、随机防重放数 (Nonce) 等按规定排序拼接，加盐 (Salt) 后使用哈希算法 (如 HMAC-SHA256) 生成 Sign 一并传给服务端。就算抓包看到了，也无法修改任何参数。

**4. 终极防线：双向认证 (mTLS / Two-Way Authentication)**
常用于金融结算级、B端高密级应用。
* **原理**：普通的 HTTPS 单向认证只有客户端去验证服务器的证书；**双向认证**则是在 TLS 握手过程中，服务器也必须要求客户端提交一张可被服务端信任的“客户端鉴权证书”。
* 如果没有这张只发给合法 App 实例的证书，中间人代理软件连 TLS 握手层都进不去，攻击手段彻底失效。

#### OC 中的网络请求 Block 需要添加 `weakSelf` 吗？
关于 Objective-C 中 Block 是否会造成循环引用（Retain Cycle），核心永远是判断：**是否构成了互相强持有**。针对日常使用的网络请求，分为以下两种情况：

**1. 不需要加 `weakSelf` 的情况（绝大多数单次请求）**
如果是通过 `AFNetworking` 或是原生的类方法/单例直接发起的单次网络请求，例如：
```objective-c
[AFHTTPSessionManager.manager GET:@"..." parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    self.data = responseObject; // 直接用 self
} failure:nil];
```
* **原理解析**：在这个场景中，`self`（比如你的 ViewController）并没有用一个 `strong` 的属性去持有着这个网络请求对象或是 Block 自身。此时，是底层的网络子系统（ NSURLSession ）在后台异步**强引用**了这个 Block。
* **生命周期**：网络请求回来后，底层系统会自动执行并释放这个 Block，进而释放对 `self` 的引用。这**不会**导致永久的内存泄漏（Leak），但会导致短暂的**延迟释放 (Delayed Deallocation)**（即请求不回来之前，哪怕你退出了页面，`self` 也必须活着，直到回调触发或请求超时被丢弃）。

**2. 必须加 `weakSelf` 的情况（属性相互持有）**
如果你在 `self` 内部用了一个属性把这次的网络请求（比如 `NSURLSessionDataTask`）或者直接把这个 Block 保存下来了，以便后续手动去取消它：
```objective-c
self.currentTask = [AFHTTPSessionManager.manager GET:@"..." parameters:nil ... success:^(NSURLSessionDataTask *task, id responseObject) {
    self.data = responseObject; // 致命的互相持有！
} ...];
```
* **原理解析**：`self` 强持有了 `currentTask`，`currentTask` 持有了 Block，而 Block 又强持有了 `self`。这就形成了一个坚不可摧的闭环。
* **结论**：这时候**绝对必须**加上 `__weak typeof(self) weakSelf = self;` 打破僵局。

---
> [!TIP]
> **一线开发中的最佳实践方案：**
> 尽管在情况 1 时不会死锁泄露，但我们依然强烈推荐**只要是写在 Controller 中的网络请求 Block，统统无脑加上 `weakSelf`。**
> 因为当用户已经按返回键销毁了页面后，如果不用 `weakSelf`，迟迟才回来的网络回调依然会在后台执行大量没用的数据解析和 UI 刷新逻辑，这是在吃手机系统的性能。使用 `weakSelf` 加 `strongSelf` 的标准范式，不仅防隐患，也是极好的代码素养体现。

#### Swift 闭包中 `weak` 和 `unowned` 的区别
在 Swift 中，为了打破闭包（Closure）产生的循环引用，我们会使用捕获列表 `[weak self]` 或 `[unowned self]`。两者的核心共同点是：**都不会增加对象的引用计数**。但它们在底层机制和使用安全性上有本质的区别。

**1. `weak` (弱引用)**
* **本质**：声明为 `weak` 的引用必定是一个**可选类型 (Optional)**，因为在程序运行期间它随时可能变成 `nil`。
* **安全性机制**：极其安全。当 `weak` 引用的对象被释放后，ARC 会自动将其指针置为 `nil`。即使在此之后向它发送消息（或尝试调用它），也不会发生 Crash。
* **使用范式**：在闭包内部使用时，你需要将其解包（比如使用可选链 `self?.` 或者 `guard let self = self else { return }`）。
* **适用场景**：**推荐的默认选择。**只要你不百分百确定执行闭包的那一刻，`self` 是否还活着，就无条件使用 `[weak self]`。网络请求异步回调就是最典型的场景。

**2. `unowned` (无主引用)**
* **本质**：声明为 `unowned` 的引用**假定**它所指向的实例一定存在，因此它不是可选类型。它在内存底层类似于 Objective-C 的 `__unsafe_unretained` 的高级形态。
* **致命风险**：非常危险！如果 `unowned` 指向的对象已经被 ARC 释放，此时闭包恰好触发执行并尝试访问该对象，系统不会置 `nil`，而是直接引发**运行时崩溃 (Run-time Crash)**（报错类似于 *Attempted to read an unowned reference but the object was already deallocated*）。
* **使用范式**：在闭包内可以直接像普通变量一样用 `self.` 调用，不需要加 `?` 烦人的解包。
* **适用场景**：仅用于**这两个对象生命周期绝对绑定，“同生共死”**的情况。比如一个 `Person` 类里必然有一颗 `Heart` 类，`Heart` 的行为闭包里用到 `Person` 时，就可以用 `[unowned self]`。因为当心脏在跳动时，人绝对是活着的；人死了，心脏自然也被销毁了。

**总结口诀**：
平时业务无脑写 `weak` 保平安；除非存在绝对的嵌套依存（生命周期强绑定），为了不写问号 `?` 且追求那一丝丝极致性能，才敢用 `unowned`。

#### iOS 发送请求时，服务端如何通过 Token 识别用户？
在 iOS 端（或任何大前端），我们在完成登录后会拿到一个 Token，并在后续请求的 HTTP Header 中带上它（通常格式为 `Authorization: Bearer <Token>`）。服务端识别这个 Token 归属哪个用户，主要由**服务端的 Token 架构**决定，目前主流分为两大流派：

**1. 状态化 Token (Stateful Token / Session + Redis查表法)**
这里 iOS 端拿到的 Token 其实只是一把“随机字符串”的无意义钥匙。
* **服务端是如何找人的？**
  服务端收到你的请求和这把钥匙后，必须拿着钥匙去**查库**（通常是去服务器内存或高性能缓存如 Redis 中查询）。因为 Redis 里面存着一张巨大的对照表：`"Token_A" -> "UserID_1001"`。如果查到了映射，服务端就知道当前请求是谁发出的；如果查不到或过期了，就返回 401 让 iOS 重新登录。
* **特点**：好处是服务端想踢谁下线随时可以直接在 Redis 里删掉那条记录；坏处是每一个网络请求都要去查一次 Redis，高并发下对后台服务器性能是一个考验。

**2. 无状态 Token (Stateless Token / JWT 算哈希法)**
这是目前 Web/现代移动端非常普遍的横向扩容解决方案：**JSON Web Token (JWT)**。
此时 iOS 端拿到的 Token（一般是由 `.` 隔开的三段 Base64 字符串），**这个字符串本身就包含了用户是谁的信息！**
* **服务端是怎么找人的？**
  服务端收到 Token 后，将其第二段（Payload 载荷区）解 Base64，里面通常明明白白写着 JSON 数据：`{"userId": 1001, "role": "vip", "exp": 1712222222}`。也就是说，服务端直接读 Token 就知道了用户身份，**完全不需要去查任何数据库**。
* **如果黑客或用户拦截篡改了明文里的 UserID 怎么办？**
  这就靠 Token 的第三部分：**防伪数字签名 (Signature)**。服务端在下发 Token 时，会用一张只有服务器本地才知道的**绝密字符串（Secret Key）**对这段明文做了不可逆的哈希运算或者 RSA 私钥签名，算出一个最终签名贴在第三段。
  当 iOS 发来请求时，服务端同样拿出自己的这把绝秘 Key 按照相同算法重新对明文做一次签名计算。如果算出来的签名和抓到的 Token 尾部的签名完全一致，服务端此时可以百分百确信：这个 Token 就是我当初发的，而且中途没有被任何人篡改过。
* **特点**：不需要查任何数据库和 Redis，服务端解耦且性能极高。缺点是一旦签发，在这个 Token 自带的 `exp` 倒计时过期之前，服务端很难用极低成本去强制废弃个别的 Token。

**一句话总结：**
对于你发出去的 Token ，服务端要么是拿着它去**查 Redis 对照表 (Session/Opaque Token)** 找出你的 UserID，要么是拿着绝密私钥去**验签并直接解开 Token 中的明文 (JWT)** 来直接读取你的 UserID。


## Q: 你认为你在这个项目中做过最大的亮点是什么？

### 回答方向：MVVM+Coordinator 导航架构

---

### 开场（Situation + Task）

我们的项目是保时捷的 iOS 移动端 monorepo，包含 120+ 个模块、两个生产 App（全球版和中国版）。在这样的规模下，如果导航逻辑散落在各个 ViewController 里，模块之间会产生严重耦合，也很难支持 DeepLink、跨 Tab 跳转这些场景。所以我们设计并落地了一套完整的 MVVM+Coordinator 导航架构。

---

### 核心设计（Action）

整个架构分三层协议：

#### 1. Route — 导航的"语言"

最底层是一个极简的 `Route` 协议，只要求 `Sendable`，定义在 utils 层，所有模块都能用。每个功能模块定义自己的 Route 枚举：

```swift
public protocol Route: Sendable {}

// 每个模块定义自己的路由枚举
public enum VehicleDetailsRoute: Route {
    case showDetails(vin: Vehicle.VIN)
}

public enum ChargingFunctionRoute: Route {
    case showChargingOverview(vin: Vehicle.VIN)
    case showChargingHistory
}
```

这样做的好处是，Route 是值类型、可序列化的，天然适合 DeepLink 转换，而且每个模块的路由是自包含的，不需要知道其他模块的存在。

#### 2. Routing — 路由分发机制

中间层是 `Routing` 协议，核心是两个方法：

```swift
@MainActor
public protocol Routing: AnyObject {
    var onFinishAction: (@Sendable (_ continueWithRoute: any Route) -> Void)? { get set }
    func start(route: any Route) -> Bool
    func handle(route: any Route)
}
```

关键设计是 `handle(route:)` 的默认实现：如果当前 Coordinator 处理不了这个 Route，就通过 `onFinishAction` 向上冒泡给父 Coordinator。这形成了一个**责任链模式**——Route 会沿着 Coordinator 树向上传递，直到有人能处理它。

```swift
// handle 的默认实现
func handle(route: any Route) {
    if !start(route: route) {
        // 当前 Coordinator 处理不了，传给父 Coordinator
        onFinishAction?(route)
    }
}
```

#### 3. Coordinator — 导航的执行者

最上层是 `Coordinator` 协议，继承 `Routing`，管理 `childCoordinators` 数组和 `navigationController`。每个 Coordinator 的 `start(route:)` 实现模式很统一：

```swift
public func start(route: any Route) -> Bool {
    guard let route = route as? VehicleDetailsRoute else {
        return startChildCoordinator(route: route)  // 交给子 Coordinator 尝试
    }
    switch route {
    case .showDetails(let vin):
        showDetails(vin: vin)
        return true
    }
}
```

先尝试匹配自己的 Route 类型，匹配不上就遍历 childCoordinators 看谁能处理。这个模式在 77 个 Domain 模块里完全统一。

#### 4. 顶层 AppCoordinator — 全局路由中枢

AppCoordinator 是整棵树的根节点，它管理多个 `LayoutCoordinator`（对应 TabBar 的每个 Tab）和 `UtilityCoordinator`（全局功能如登录、版本检查）。路由分发的优先级是：

```
AppRoute（自身处理）→ UtilityCoordinators → LayoutCoordinators → MenuCoordinator
```

当 Route 命中某个 LayoutCoordinator 时，AppCoordinator 还会自动切换 TabBar 到对应的 Tab。这让 DeepLink 跳转到任意功能页面变得非常自然——只需要把 URL 转换成对应的 Route 对象，剩下的交给责任链。

---

### 解决了什么问题（Result）

这套架构带来了几个实际收益：

1. **模块完全解耦**：ViewController 不知道导航栈的存在，模块之间通过 Route 枚举通信，没有直接依赖
2. **DeepLink 统一处理**：URL → Route 的转换只需要一个 `DeepLinkManager`，转换后的 Route 走和正常导航完全一样的路径
3. **跨模块跳转零成本**：比如从"充电"模块跳到"车辆详情"，只需要 `handle(route: VehicleDetailsRoute.showDetails(vin: vin))`，Route 会自动冒泡到能处理它的 Coordinator
4. **Swift 6 并发安全**：所有 Coordinator 和 Routing 协议都标记了 `@MainActor`，Route 要求 `Sendable`，在 Swift 6 严格并发检查下是安全的
5. **新模块接入成本低**：新功能只需要定义自己的 Route 枚举、实现一个 Coordinator，注册为 childCoordinator 就完成了

---

### 面试官可能的追问

#### Q: 为什么不用 SwiftUI 的 NavigationStack？

项目从 iOS 16 开始支持，大量存量 UIKit 代码。Coordinator 模式对 UIKit 和 SwiftUI 都兼容——SwiftUI 的 View 可以通过 `RouteDispatching` 协议的 `onAction` 闭包把路由事件传给 Coordinator。

#### Q: Route 冒泡会不会有性能问题？

不会。Coordinator 树的深度通常只有 3-4 层（App → Layout → Feature → SubFeature），每层只是一个 `as?` 类型检查，开销可以忽略。

#### Q: 怎么防止 Coordinator 内存泄漏？

`addChildCoordinator` 时用 `[weak self]` 绑定 `onFinishAction`，Coordinator 结束时调用 `removeChildCoordinator` 从父节点移除。生命周期和 NavigationController 的 push/pop 对齐。

#### Q: 和 Router 模式有什么区别？

Router 通常是一个中心化的路由表（URL → Handler），我们的方案是去中心化的——每个 Coordinator 只认识自己的 Route 类型，通过责任链自动分发。好处是新增模块不需要修改全局路由表，坏处是调试时需要理解冒泡路径。

#### Swift 数组 Copy-on-Write (COW) 机制
- **核心定义**：Swift 中的集合类型（Array, Dictionary, Set）虽然是值类型，但底层通过 COW 机制进行性能优化。
- **触发条件**：
    1. **修改操作**：执行了会改变集合内容的操作（如 `append`, `remove`, `subscript set`）。
    2. **共享存储**：当前集合底层的内存缓冲引用计数大于 1（即有多个变量共享同一份数据）。
- **性能优势**：避免了在仅仅是赋值或传递参数时发生无意义的大内存拷贝，只有在真正需要独立副本进行修改时才执行拷贝。
- **代码演示**：
```swift
func printAddress(_ arr: [Int]) {
    arr.withUnsafeBufferPointer { print($0.baseAddress!) }
}

var a = [1, 2, 3]
var b = a  // 此时 a 和 b 共享内存

printAddress(a) // 0x60000...
printAddress(b) // 0x60000... (地址相同)

b.append(4)     // b 发现有共享，触发 COW，拷贝后修改

printAddress(a) // 0x60000... (原地址不变)
printAddress(b) // 0x60001... (新地址)
```
- **自定义 COW**：对于自定义 struct，可以通过 `isKnownUniquelyReferenced` 检查内部引用类型的唯一性来手动实现 COW。

#### Swift 函数调用：栈区（Stack）还是堆区（Heap）？

**核心结论：函数调用本身发生在栈区**，但函数内部操作的数据可能在堆区分配，取决于数据类型。

**1. 为什么函数调用在栈区？**

函数调用具有严格的**后进先出（LIFO）**特性，与栈结构天然契合：

```
main() 调用 foo() 调用 bar()

Stack 状态:
┌─────────────┐
│  bar() 帧   │  ← 栈顶（最新调用）
├─────────────┤
│  foo() 帧   │
├─────────────┤
│  main() 帧  │  ← 栈底
└─────────────┘
```

每次函数调用都会创建一个**栈帧（Stack Frame）**，包含：
- **返回地址**：函数执行完后回到哪里
- **参数（值类型）**：传入的 Int、Bool、struct 等
- **局部变量（值类型）**：函数内部的临时变量
- **寄存器保存值**：调用方的寄存器状态

```swift
func add(a: Int, b: Int) -> Int {
    let result = a + b  // a, b, result 都在栈上
    return result
}   // 函数返回，栈帧自动销毁
```

栈分配性能极高：仅需移动栈指针（SP 寄存器），O(1) 时间，且自动管理，无需 ARC。

**2. 什么时候涉及堆区？**

| 场景 | 说明 |
|---|---|
| **引用类型（class 实例）** | 栈上存指针，堆上存实际数据，ARC 管理生命周期 |
| **逃逸闭包捕获的变量** | 变量生命周期超过函数作用域，自动迁移到堆上 |
| **String / Array 的内部存储** | 值类型本身的元数据在栈上，内部动态数组在堆上 |

```swift
class Person {
    var name: String
    init(name: String) { self.name = name }
}

func createPerson() {
    let p = Person(name: "Tom")
    // p 的"指针"在栈上，Person 实例的实际数据在堆上
}

func makeCounter() -> () -> Int {
    var count = 0  // 被 @escaping 闭包捕获后，count 迁移到堆上
    return { count += 1; return count }
}
```

**3. Swift 编译器优化：逃逸分析（Escape Analysis）**

编译器会判断对象是否"逃逸"出当前作用域：
- 若 class 实例**不逃逸**，编译器可能将其优化到栈上分配，绕过 ARC；
- 标记为 `@escaping` 的闭包，其捕获列表**必须在堆上**分配。

**4. 总结对比**

| 维度 | 栈区（Stack） | 堆区（Heap） |
|---|---|---|
| **函数调用本身** | ✅ | ❌ |
| **值类型局部变量** | ✅ 默认 | ⚠️ 逃逸时迁移 |
| **引用类型（class）** | 存指针 | ✅ 存实例数据 |
| **捕获变量的逃逸闭包** | ❌ | ✅ |
| **管理方式** | 自动（栈帧） | ARC |
| **性能** | 极快（移动 SP 指针） | 较慢（malloc / ARC 计数） |

#### Swift 自定义属性包裹器（Property Wrapper）

**1. 核心语法**

用 `@propertyWrapper` 标记 struct/class/enum，并实现必须的 `wrappedValue` 属性：

```swift
@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    // ✅ 必须实现，这是属性的实际存储值
    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Int, range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct Player {
    @Clamped(range: 0...100) var health: Int = 100
}

var p = Player()
p.health = 150  // 自动夹紧到 100
p.health = -10  // 自动夹紧到 0
```

**2. 三个核心要素**

| 要素 | 是否必须 | 访问方式 | 说明 |
|---|---|---|---|
| `wrappedValue` | ✅ 必须 | `obj.propertyName` | 包裹器核心，实际值的读写逻辑 |
| `projectedValue` | ❌ 可选 | `obj.$propertyName` | 额外暴露的元数据/状态 |
| `init(wrappedValue:)` | ❌ 可选 | 赋值语法 `= xxx` | 支持 `@Wrapper var x = value` |

**`projectedValue` 示例（用 `$` 前缀访问）：**

```swift
@propertyWrapper
struct Logged<T> {
    private var value: T
    private(set) var projectedValue: [String] = []  // 操作日志

    var wrappedValue: T {
        get { value }
        set {
            projectedValue.append("修改为: \(newValue)")
            value = newValue
        }
    }

    init(wrappedValue: T) { self.value = wrappedValue }
}

struct Config {
    @Logged var serverURL: String = "https://api.dev.com"
}

var config = Config()
config.serverURL = "https://api.prod.com"
print(config.$serverURL)  // ["修改为: https://api.prod.com"]
```

**3. 实战示例：封装 UserDefaults**

```swift
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get { UserDefaults.standard.value(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

struct Settings {
    @UserDefault(key: "isDarkMode", defaultValue: false) var isDarkMode: Bool
    @UserDefault(key: "username", defaultValue: "Guest") var username: String = "Tom"
}
```

**4. 编译器展开原理**

理解展开过程有助于排查疑惑：

```swift
// 写法：
@Clamped(range: 0...100) var health: Int = 100

// 编译器等价展开为：
private var _health = Clamped(wrappedValue: 100, range: 0...100)
var health: Int {
    get { _health.wrappedValue }
    set { _health.wrappedValue = newValue }
}
```

**5. 线程安全属性包裹器（进阶示例）**

```swift
@propertyWrapper
final class ThreadSafe<T> {
    private var value: T
    private let lock = NSLock()

    var wrappedValue: T {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }

    init(wrappedValue: T) { self.value = wrappedValue }
}

class DataManager {
    @ThreadSafe var counter: Int = 0  // 多线程读写安全
}
```



### 1. Struct (结构体) 和 Class (类) 的本质区别是什么？你在实际项目中如何做技术选型？
- 核心考点： 值类型 (Value Type) vs 引用类型 (Reference Type)、内存分配、方法分派 (Method Dispatch)。
- 资深视角： 普通候选人只能答出“Struct 不能继承，是值类型传递拷贝；Class 是引用类型”。但高级开发者需要指出：
- 内存层面： Struct 默认分配在栈 (Stack) 上，速度极快且线程安全；Class 分配在堆 (Heap) 上，存在 ARC 的引用计数开销。
- 分派机制： Struct 默认使用静态派发 (Static Dispatch)，性能最优；Class 存在继承，使用动态派发 (Dynamic / V-Table Dispatch)。
- 进阶知识点： 写时复制 (Copy-on-Write, CoW)。这是苹果为了优化大型值类型（如 Array、Dictionary）内存而引入的核心机制。

### 2. 请解释一下 Swift 中的 Protocol-Oriented Programming (面向协议编程，POP) 与传统的 OOP 有什么区别和优势？
- 核心考点： 协议扩展 (Protocol Extension)、多继承困境、代码解耦。
- 资深视角： OOP 的基类容易变得极其臃肿（比如广为诟病的 BaseViewController），且 Swift 的 Class 只支持单继承。

POP 的精髓在于通过 Protocol + Extension 提供默认实现。它允许我们像搭积木一样为 Struct 或 Class 横向赋予能力（比如 Loggable, NetworkFetchable），彻底打破了继承树的束缚，这也是 SwiftUI 底层的核心设计理念。

### 3. Swift 内存管理中的 weak 和 unowned 有什么区别？分别适用于什么场景？
- 核心考点： ARC (自动引用计数)、循环引用 (Retain Cycle)、野指针与崩溃。
- 资深视角： * 相同点：两者都不会增加引用计数，都能打破闭包或对象间的循环引用。
- 不同点：weak 修饰的对象释放后，指针会被自动置为 nil，所以它必须是可选类型 (Optional)。而 unowned (无主引用) 假定引用的对象生命周期永远等于或长于当前对象。如果对象被释放后依然访问 unowned 指针，会直接触发运行时 Crash。
- 考察点在于候选人是否具有写出高可用代码的安全意识。

### 4. 什么是 Opaque Return Types（不透明返回类型，some 关键字）？它和泛型 (Generics) 或 Any 有什么不同？
- 核心考点： Swift 5.1 引入的特性，也是 SwiftUI var body: some View 的底层基础、反向泛型。
- 资深视角： 返回 Any 或者 Protocol 是一种“类型擦除”，编译器在编译期丢失了具体的底层类型信息，导致无法调用一些关联类型 (Associated Type) 的方法。
- 返回 some Protocol 则是由函数内部实现决定具体的返回类型，但对外隐藏。它在保证了封装性的同时，让编译器依然能推断出真实的静态类型，从而保证了类型安全和性能。

### 5. 请聊聊 Result Type 以及它如何优化 Swift 的错误处理机制？
- 核心考点： 泛型枚举、Error Handling 演进。
- 资深视角： 传统网络请求回调闭包通常是 (Data?, Error?) -> Void，这存在一种歧义状态：Data 和 Error 同时存在，或者同时为 nil，导致控制流校验非常繁琐。Result<Success, Failure: Error> 利用枚举的互斥性，从类型层面上强制规定了非黑即白的结果（要么成功带数据，要么失败带错误），结合 switch 语句极大提升了代码的严谨性。

### Swift 中 Any, any, AnyObject, AnyClass 这几个关键字分别代表什么？
- 1. Any (任意类型的实例)
Any 代表了 Swift 中任何类型的实例。无论它是值类型（Struct、Enum）、引用类型（Class），甚至是闭包（Function Type），都可以被隐式转换为 Any。
- 核心特性： 极其灵活，但也是一把双刃剑。返回 Any 或者 Protocol 是一种“类型擦除” 。编译器在编译期会丢失具体的底层类型信息，导致你无法直接调用它原本的方法或关联类型 。
- 应用场景： 处理类型极度混合的集合（如老旧的 Objective-C API 返回的无类型数组），或编写高度动态化的接口。
    ```Swift
    var mixedArray: [Any] = [1, "Hello", true, { print("Closure") }]
    ```
- 2. AnyObject (任意类的实例)
    - AnyObject 是一个系统内置的协议（Protocol），Swift 中所有的类（Class）都隐式遵守了这个协议。它专门用来代表任何引用类型的实例。
    - 核心特性： 明确排除了 Struct、Enum 等值类型。
    - 经典场景： 最常用于定义 delegate 协议时，限制该协议只能被 Class 遵守，从而可以使用 weak 关键字修饰代理属性，打破循环引用。
    ```Swift
    // 限制协议只能由 Class 遵守
    protocol NetworkDelegate: AnyObject {
        func didFinishFetch()
    }

    class NetworkManager {
        weak var delegate: NetworkDelegate?
    }
    ```
- 3. AnyClass (任意类的元类型)
    - AnyClass 并不是指类的实例，而是指类本身的类型（Metatype）。在 Swift 源码中，它的定义是 typealias AnyClass = AnyObject.Type。
    - 核心特性： 代表着类型自身，类似于 Objective-C 中的 Class 类型。
    - 应用场景： 常见于组件化路由、反射机制，或者在使用 UITableView / UICollectionView 注册纯代码 Cell 时传入类型对象。

    ```Swift
    // 接受一个类类型本身，而不是它的实例化对象
    func registerClass(_ cellClass: AnyClass) {
        print("Registered: \(cellClass)")
    }
    ```
- 4. any (小写 any：存在类型标记)
    - any 是 Swift 5.6 引入的关键字，用来显式标记存在类型（Existential Type）。它是伴随着现代 Swift 协议演进而来的重要特性。

    - 核心特性： 当你把一个协议当作具体的类型来使用时（例如声明一个变量 var animal: Animal），系统在底层其实是在创建一个“装箱（Box）”来包裹背后的真实数据。为了让开发者明确意识到这种动态派发带来的性能损耗，Swift 强制要求在协议名前加上 any 关键字。

    - 与泛型/some的区别： 泛型和 some 是编译期确定的静态类型，性能高且类型安全；而 any 是运行时的动态类型，支持多态但在运行时有额外的内存和派发开销。
    ```Swift
    protocol Animal {
        func speak()
    }   
    protocol Animal {
        func speak()
    }

    struct Dog: Animal { func speak() { print("Woof") } }
    struct Cat: Animal { func speak() { print("Meow") } }

    // 使用 any 明确表示这里装箱了一个遵守 Animal 协议的动态类型
    let myPets: [any Animal] = [Dog(), Cat()]
    ```


### 6. Swift 中，方法派发的方式有哪些？

- 静态派发 (Static / Direct Dispatch)
    - 核心特性： 系统在编译期就已经明确知道了具体要调用的函数内存地址，运行时会直接跳转到该地址执行相应的汇编指令。
    - 核心优势： 性能极高。因为地址在编译时就已固定，编译器甚至可以对其进行内联（Inline）优化，将函数体直接展开在调用处，进一步省去函数调用栈的压栈出栈开销。

    - 适用场景：
        - 值类型： Struct 默认使用静态派发 (Static Dispatch)，性能最优 。Enum 也是如此。
        - 被封闭的引用类型： 被 final 关键字修饰的 Class 或其内部方法。final 相当于向编译器发誓“这个类或方法绝对不会被继承或重写”，编译器就会放心地使用静态派发。
        - 扩展： 在 Extension 中直接定义的方法（注意：非 Protocol 中声明的方法）默认使用静态派发。

2. 函数表派发 (Table Dispatch / V-Table)
    - 核心特性： 编译型面向对象语言（如 C++、Swift）实现多态的最常见动态派发机制。它在运行期通过查表来动态确定函数的实际地址。
    - 底层机制： Class 存在继承，使用动态派发 (Dynamic / V-Table Dispatch) 。系统会为每个类在内存中维护一个虚函数表（Virtual Table，简称 V-Table），表中存储着该类所有可重写方法的内存地址数组。子类会拷贝父类的表，并替换掉自己重写的方法地址。当调用方法时，程序会在运行时先读取当前对象的 V-Table，找到正确的偏移量索引，获取方法地址后再跳转执行。
    - 协议派发 (Witness Table)： 当使用 Protocol 类型的变量调用方法时，底层使用的是类似的“协议见证表（Protocol Witness Table）”。
    - 性能损耗： 相比静态派发，它在运行时多出了两次内存读取操作（读取表、读取函数地址），且由于运行时才能确定跳转目标，编译器通常无法进行内联等高级优化。

3. 消息机制派发 (Message Dispatch)
    - 核心特性： Objective-C 的“灵魂”，也是 Swift 为了兼容 Cocoa 框架和纯动态特性而保留的最慢、但最灵活的派发方式。
    - 底层机制： 完全在运行期动态决定。底层会调用 objc_msgSend 函数，顺着对象的 isa 指针找到类对象，在方法缓存（Cache）或方法列表（Method List）中查找。如果找不到，还会沿着 superclass 指针一直向上查找到 NSObject，甚至触发消息转发（Message Forwarding）机制。
    - 核心优势： 极度的灵活性。它允许开发者在运行时动态修改方法的实现。著名的 KVO (键值观察) 和 Method Swizzling (黑魔法) 都是基于这套消息机制实现的。
    - 适用场景：
        - 被 @objc dynamic 联合修饰的方法。
        - 继承自 Objective-C 类的原生方法。
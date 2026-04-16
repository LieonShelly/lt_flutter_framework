#### Swift并发相关
- 与 GCD 并发的区别
Swift 现代并发模型带来了三个核心概念，构建了所谓**“结构化并发（Structured Concurrency）”**的基石。

async / await (异步函数的语法糖)：
它允许你以同步代码的书写直觉，去表达异步的逻辑。代码是从上往下线性执行的。遇到 await 关键字时，当前任务会被挂起（Suspend），但它绝对不会阻塞当前底层的线程。底层会让出线程的控制权去执行其他任务，等异步结果回来后，再从上次挂起的地方**恢复（Resume）**执行。
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

结构化并发 (Task & TaskGroup)：
如果你想让多个网络请求并发执行，就需要用到 async let 或者 TaskGroup。它将并发任务的生命周期与代码的作用域（Scope）绑定。编译器和运行时会保证：父任务只有在所有子任务都完成后才会完成。同时它原生支持取消传播（Cancellation Propagation）—— 如果父任务被取消，所有的子任务会自动收到取消协作信号，极大减少了无用功。

Actor (状态隔离)：
这是解决数据竞争（Data Race）的终极武器。在传统的 Class 中，多线程同时读写同一个属性会导致难以排查的 Crash。而 actor 是一种全新的引用类型，它在内部维护了一个隔离域（Isolation Domain）。任何从外部访问 actor 可变状态的操作，都必须跨越隔离域，即必须加上 await 异步等待。这就从编译器层面强制保证了同一时间只有一个任务能访问其内部状态，优雅地干掉了容易引发死锁的传统锁机制（Lock/Mutex/Semaphore）。

这是高级面试的加分项。Swift 并发模型不再像 GCD 那样疯狂开辟新线程。它在底层默认维护了一个最大数量与设备 CPU 核心数相等的协作式线程池。

当代码执行到 await 遇到网络 I/O 挂起时，系统会将当前任务的状态打包成一个 Continuation 保存到堆区。此时，底层的真实线程会被立刻释放，转去线程池里拿别的活跃任务执行。当网络数据返回后，系统再把之前的 Continuation 放回执行队列，等待线程池有空闲线程时去恢复执行。

结论： 极少量的物理线程就能处理海量的并发任务，彻底消除了线程爆炸和频繁上下文切换带来的性能损耗。
- 举例：相册图片相似度检测案例
    - 1. 数据获取：安全且轻量地加载相册 (PhotoKit)
    - 2. 核心引擎：提取图像特征向量 (Vision Framework)
    - 3. 相似度计算与分组策略 (Clustering Algorithm)
    - 4. 性能调优：利用现代并发 (Modern Concurrency)
#### GithubAction 在项目上的应用
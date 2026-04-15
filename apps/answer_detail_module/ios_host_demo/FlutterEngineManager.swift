import SwiftUI
import Flutter

// MARK: - FlutterEngine 管理器

/// 持有单一 FlutterEngine 实例，管理 Pigeon API 的注册和调用。
///
/// 这是单引擎架构的核心：整个 App 只有一个 FlutterEngine，
/// 所有 Flutter 页面（B 和 D）共享同一个引擎和 GoRouter 实例。
class FlutterEngineManager: ObservableObject {

    let flutterEngine: FlutterEngine
    private var navigationFlutterApi: NavigationFlutterApi?
    private var isEngineRunning = false

    /// NavigationHostApi 的回调闭包，由外部设置
    var onOpenCustomerService: (() -> Void)?
    var onGoBack: (() -> Void)?
    var onConfirmOrder: ((String) -> Void)?

    init() {
        self.flutterEngine = FlutterEngine(name: "single_engine_demo")
    }

    /// 启动 FlutterEngine（只启动一次）
    func startEngine() {
        guard !isEngineRunning else { return }
        flutterEngine.run()
        isEngineRunning = true

        // 初始化 NavigationFlutterApi（iOS → Flutter）
        navigationFlutterApi = NavigationFlutterApi(
            binaryMessenger: flutterEngine.binaryMessenger
        )

        // 注册 NavigationHostApi（Flutter → iOS）
        let hostApiHandler = NavigationHostApiHandler(manager: self)
        NavigationHostApiSetup.setUp(
            binaryMessenger: flutterEngine.binaryMessenger,
            api: hostApiHandler
        )

        print("🚀 FlutterEngine 已启动（单引擎模式）")
    }

    // MARK: - iOS → Flutter 导航指令

    /// 导航到 Flutter 商品详情页（页面 B）
    func navigateToProductDetail(productId: String) {
        navigationFlutterApi?.navigateToProductDetail(productId: productId) { result in
            switch result {
            case .success:
                print("✅ Flutter 已导航到商品详情页 (productId: \(productId))")
            case .failure(let error):
                print("❌ 导航到商品详情页失败: \(error)")
            }
        }
    }

    /// 导航到 Flutter 订单确认页（页面 D）
    func navigateToOrderConfirm(orderId: String, productName: String, price: Double) {
        let orderInfo = ApiOrderInfo(
            orderId: orderId,
            productName: productName,
            price: price
        )
        navigationFlutterApi?.navigateToOrderConfirm(orderInfo: orderInfo) { result in
            switch result {
            case .success:
                print("✅ Flutter 已导航到订单确认页 (orderId: \(orderId))")
            case .failure(let error):
                print("❌ 导航到订单确认页失败: \(error)")
            }
        }
    }
}

// MARK: - NavigationHostApi 实现（Flutter → iOS）

/// 处理 Flutter 端发来的操作请求
///
/// - `openCustomerService()`：Flutter B 点击"联系客服"，原生端 push 页面 C
/// - `goBack()`：Flutter 页面点击返回，原生端 pop 当前页面
/// - `confirmOrder(orderId:)`：Flutter D 点击"确认下单"
class NavigationHostApiHandler: NavigationHostApi {

    private weak var manager: FlutterEngineManager?

    init(manager: FlutterEngineManager) {
        self.manager = manager
    }

    func openCustomerService() throws {
        print("📞 Flutter 请求打开客服页面")
        DispatchQueue.main.async {
            self.manager?.onOpenCustomerService?()
        }
    }

    func goBack() throws {
        print("⬅️ Flutter 请求返回上一页")
        DispatchQueue.main.async {
            self.manager?.onGoBack?()
        }
    }

    func confirmOrder(orderId: String) throws {
        print("🛒 Flutter 请求确认订单: \(orderId)")
        DispatchQueue.main.async {
            self.manager?.onConfirmOrder?(orderId)
        }
    }
}

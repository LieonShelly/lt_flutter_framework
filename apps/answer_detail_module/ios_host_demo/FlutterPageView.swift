import SwiftUI
import Flutter

// MARK: - Flutter 页面容器

/// 将 FlutterViewController 包装为 SwiftUI View，嵌入 NavigationStack。
///
/// 用于 pageB（商品详情）和 pageD（订单确认），它们共享同一个 FlutterEngine。
/// `onAppear` 时通过 NavigationFlutterApi 发送导航指令，驱动 Flutter GoRouter
/// 切换到对应的路由。
struct FlutterPageView: View {
    @ObservedObject var engineManager: FlutterEngineManager

    /// 页面出现时执行的导航指令（如 navigateToProductDetail / navigateToOrderConfirm）
    var onAppear: (() -> Void)?

    /// Flutter 端请求跳转到下一个原生页面（如 openCustomerService）
    var onNavigateNext: (() -> Void)?

    /// Flutter 端请求返回上一页（goBack）
    var onGoBack: (() -> Void)?

    /// Flutter 端请求确认订单（confirmOrder）
    var onConfirmOrder: ((String) -> Void)?

    var body: some View {
        FlutterViewControllerRepresentable(engine: engineManager.flutterEngine)
            .ignoresSafeArea()
            .onAppear {
                // 绑定 Flutter → iOS 回调
                engineManager.onOpenCustomerService = onNavigateNext
                engineManager.onGoBack = onGoBack
                engineManager.onConfirmOrder = onConfirmOrder

                // 延迟发送导航指令，确保 FlutterViewController 已就绪
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onAppear?()
                }
            }
    }
}

// MARK: - FlutterViewController UIViewControllerRepresentable

/// 将 UIKit 的 FlutterViewController 桥接到 SwiftUI
struct FlutterViewControllerRepresentable: UIViewControllerRepresentable {
    let engine: FlutterEngine

    func makeUIViewController(context: Context) -> FlutterViewController {
        return FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        // FlutterViewController 的更新由 Pigeon 通信驱动，这里无需额外操作
    }
}

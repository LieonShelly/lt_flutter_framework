import SwiftUI
import Flutter

// MARK: - 路由枚举

enum SingleFlutterDemoRoute: Hashable {
    case pageA
    case pageB  // Flutter 商品详情页
    case pageC  // 原生客服聊天页
    case pageD  // Flutter 订单确认页
}

// MARK: - 主视图

/// 单引擎混合栈 Demo
///
/// 路径：Native A → Flutter B → Native C → Flutter D
///
/// pageB 和 pageD 都是 Flutter 页面，共享同一个 FlutterEngine。
/// 当从 pageC 跳转到 pageD 时，Flutter 端的 GoRouter 会执行 go('/order_confirm')，
/// 替换掉之前 pageB 的 '/product_detail' 路由状态——这就是单引擎架构的核心痛点。
struct SingleFlutterEngineView: View {
    @State var path: NavigationPath = .init()

    /// 单一 FlutterEngine 实例（整个 Demo 生命周期内只有这一个）
    @StateObject private var engineManager = FlutterEngineManager()

    var body: some View {
        NavigationStack(path: $path) {
            // Page A - 首页
            NativePageAContent(path: $path)
                .defaultBackground()
                .navigationDestination(for: SingleFlutterDemoRoute.self) { route in
                    switch route {
                    case .pageA:
                        NativePageAContent(path: $path)
                            .defaultBackground()

                    case .pageB:
                        // Flutter 商品详情页
                        FlutterPageView(
                            engineManager: engineManager,
                            onAppear: {
                                engineManager.navigateToProductDetail(productId: "PROD-001")
                            },
                            onNavigateNext: {
                                // Flutter B 点击"联系客服" → push 原生页面 C
                                path.append(SingleFlutterDemoRoute.pageC)
                            },
                            onGoBack: {
                                // Flutter B 点击返回 → pop 回 Native A
                                path.removeLast()
                            }
                        )
                        .defaultBackground()
                        .navigationBarHidden(true) // Flutter 自带 AppBar

                    case .pageC:
                        // 原生客服聊天页
                        NativePageCContent(path: $path, engineManager: engineManager)
                            .defaultBackground()

                    case .pageD:
                        // Flutter 订单确认页
                        FlutterPageView(
                            engineManager: engineManager,
                            onAppear: {
                                engineManager.navigateToOrderConfirm(
                                    orderId: "ORD-20250415-001",
                                    productName: "Demo 商品 #PROD-001",
                                    price: 99.0
                                )
                            },
                            onNavigateNext: nil,
                            onGoBack: {
                                // Flutter D 点击返回 → pop 回 Native C
                                path.removeLast()
                            },
                            onConfirmOrder: { orderId in
                                // Flutter D 点击"确认下单"
                                print("✅ 订单已确认: \(orderId)")
                                // 可以 pop 到根页面或展示确认弹窗
                                path = .init()
                            }
                        )
                        .defaultBackground()
                        .navigationBarHidden(true) // Flutter 自带 AppBar
                    }
                }
        }
        .onAppear {
            engineManager.startEngine()
        }
    }
}

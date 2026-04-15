import SwiftUI

// MARK: - Native 页面 C（客服聊天页）

/// 原生页面 C —— 客服聊天页
///
/// 路径位置：Native A → Flutter B → **Native C** → Flutter D
///
/// 由 Flutter 页面 B 点击"联系客服"按钮触发 `openCustomerService()` 后，
/// 原生端 push 进来的页面。
struct NativePageCContent: View {
    @Binding var path: NavigationPath
    @ObservedObject var engineManager: FlutterEngineManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                routeBanner
                chatSimulation
                painPointBanner
                navigateButton
            }
            .padding()
        }
        .navigationTitle("客服聊天")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 路径说明 Banner

    private var routeBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("💬 Native 页面 C - 客服聊天")
                .font(.headline)
            Text("路径：Native A → Flutter B → Native C")
                .font(.subheadline)
                .foregroundColor(.purple)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 模拟聊天界面

    private var chatSimulation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("客服对话")
                .font(.headline)

            chatBubble(isUser: false, text: "您好！请问有什么可以帮您？")
            chatBubble(isUser: true, text: "我想了解一下这个商品的发货时间")
            chatBubble(isUser: false, text: "这款商品下单后 24 小时内发货，预计 3-5 天到达。")
            chatBubble(isUser: false, text: "如果您确认购买，可以点击下方按钮进入订单确认页面。")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func chatBubble(isUser: Bool, text: String) -> some View {
        HStack {
            if isUser { Spacer() }

            Text(text)
                .font(.body)
                .padding(12)
                .background(isUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(12)

            if !isUser { Spacer() }
        }
    }

    // MARK: - 痛点说明

    private var painPointBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("⚠️ 即将触发单引擎痛点")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.orange)

            Text("点击下方按钮后，原生端会 push 一个新的 FlutterViewController，"
                 + "并通过 NavigationFlutterApi 发送 navigateToOrderConfirm 指令。\n\n"
                 + "由于只有一个 FlutterEngine，GoRouter 会执行 go('/order_confirm')，"
                 + "直接替换掉之前 Flutter B 的 '/product_detail' 路由状态。"
                 + "当用户从 Flutter D 返回到这里，再返回到 Flutter B 时，"
                 + "会发现 Flutter B 的页面内容已经变成了 Flutter D 的内容——"
                 + "因为它们共享同一个 GoRouter 实例。")
                .font(.caption)
                .foregroundColor(.brown)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 跳转按钮

    private var navigateButton: some View {
        Button {
            path.append(SingleFlutterDemoRoute.pageD)
        } label: {
            HStack {
                Image(systemName: "cart.fill")
                Text("去下单（跳转 Flutter D）")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

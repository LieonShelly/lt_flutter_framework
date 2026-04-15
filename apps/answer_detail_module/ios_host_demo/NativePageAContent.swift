import SwiftUI

// MARK: - Native 页面 A（App 首页）

/// 原生页面 A —— 混合栈的起点
///
/// 路径位置：**Native A** → Flutter B → Native C → Flutter D
struct NativePageAContent: View {
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                routeBanner
                architectureInfo
                productCard
                navigateButton
            }
            .padding()
        }
        .navigationTitle("首页")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 路径说明 Banner

    private var routeBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("📱 Native 页面 A - App 首页")
                .font(.headline)
            Text("路径起点：Native A")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 架构说明

    private var architectureInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🏗️ 单引擎架构 Demo")
                .font(.headline)

            Text("本 Demo 演示单引擎（Single Engine）架构下，原生页面与 Flutter 页面交替跳转时的路由管理痛点。")
                .font(.body)
                .foregroundColor(.secondary)

            Divider()

            Text("跳转路径：")
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 6) {
                stepRow(number: "1", title: "Native A（本页面）", tech: "SwiftUI", isActive: true)
                stepRow(number: "2", title: "Flutter B（商品详情）", tech: "Flutter", isActive: false)
                stepRow(number: "3", title: "Native C（客服聊天）", tech: "SwiftUI", isActive: false)
                stepRow(number: "4", title: "Flutter D（订单确认）", tech: "Flutter", isActive: false)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func stepRow(number: String, title: String, tech: String, isActive: Bool) -> some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(isActive ? Color.green : Color.blue))

            Text(title)
                .font(.subheadline)
                .fontWeight(isActive ? .semibold : .regular)

            Spacer()

            Text(tech)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
        }
    }

    // MARK: - 商品卡片

    private var productCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🛍️ Demo 商品")
                    .font(.headline)
                Spacer()
                Text("¥ 99.00")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }

            Text("这是一个用于演示混合栈架构的 Demo 商品。点击下方按钮将跳转到 Flutter 实现的商品详情页。")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - 跳转按钮

    private var navigateButton: some View {
        Button {
            path.append(SingleFlutterDemoRoute.pageB)
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("查看商品详情（跳转 Flutter B）")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

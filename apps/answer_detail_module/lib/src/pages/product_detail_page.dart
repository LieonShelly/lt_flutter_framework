import 'package:flutter/material.dart';

import '../generated/answer_detail_api.g.dart';

/// 商品详情页（Flutter 页面 B）
///
/// 混合栈 Demo 中的第一个 Flutter 页面，展示商品信息，
/// 并通过 [NavigationHostApi] 与原生端通信。
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.hostApi,
  });

  final String productId;
  final NavigationHostApi hostApi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商品详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => hostApi.goBack(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 路径说明 Banner
            _buildRouteBanner(),
            const SizedBox(height: 24),
            // 商品信息区域
            _buildProductInfo(),
            const SizedBox(height: 24),
            // 联系客服按钮
            _buildContactButton(),
            const SizedBox(height: 24),
            // 痛点说明区域
            _buildPainPointBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏷️ Flutter 页面 B - 商品详情',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '路径：Native A → Flutter B',
            style: TextStyle(fontSize: 14, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demo 商品 #$productId',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '¥ 99.00',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '这是一个用于演示单引擎混合栈架构的 Demo 商品。'
              '在真实场景中，这里会展示商品的详细描述信息，'
              '包括规格、材质、使用说明等内容。',
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => hostApi.openCustomerService(),
        icon: const Icon(Icons.headset_mic),
        label: const Text('联系客服'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPainPointBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ 单引擎架构痛点',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '在单引擎架构下，整个 App 只有一个 FlutterEngine 实例。'
            '当用户从本页面（Flutter B）跳转到原生客服页（Native C），'
            '再从 Native C 跳转到订单确认页（Flutter D）时，'
            'GoRouter 会执行 go(\'/order_confirm\')，'
            '这会替换掉当前的路由栈——本页面的状态将完全丢失。\n\n'
            '这正是单引擎架构的核心缺陷：Flutter 端无法同时维护 '
            'B 和 D 两个独立的页面栈，因为它们共享同一个 GoRouter 实例。',
            style: TextStyle(fontSize: 13, color: Color(0xFF795548)),
          ),
        ],
      ),
    );
  }
}

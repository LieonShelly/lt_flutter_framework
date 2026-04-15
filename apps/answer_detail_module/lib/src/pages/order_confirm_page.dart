import 'package:flutter/material.dart';

import '../generated/answer_detail_api.g.dart';

/// 订单确认页（Flutter 页面 D）
///
/// 混合栈 Demo 中的第二个 Flutter 页面，展示订单确认信息，
/// 并通过 [NavigationHostApi] 与原生端通信。
class OrderConfirmPage extends StatelessWidget {
  const OrderConfirmPage({
    super.key,
    required this.orderId,
    required this.productName,
    required this.price,
    required this.hostApi,
  });

  final String orderId;
  final String productName;
  final double price;
  final NavigationHostApi hostApi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单确认'),
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
            // 订单信息区域
            _buildOrderInfo(),
            const SizedBox(height: 24),
            // 确认下单按钮
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏷️ Flutter 页面 D - 订单确认',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '路径：Native A → Flutter B → Native C → Flutter D',
            style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '订单信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildInfoRow('订单编号', orderId),
            const SizedBox(height: 12),
            _buildInfoRow('商品名称', productName),
            const SizedBox(height: 12),
            _buildInfoRow('商品价格', '¥ ${price.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildInfoRow('收货地址', '北京市朝阳区 xx 路 xx 号（占位文本）'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () => hostApi.confirmOrder(orderId),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
        ),
        child: const Text('确认下单', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

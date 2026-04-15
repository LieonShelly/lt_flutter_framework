import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'generated/answer_detail_api.g.dart';

/// [NavigationFlutterApi] 的实现，接收原生端的导航指令并驱动 GoRouter。
///
/// 注意：这里刻意使用 `go` 而非 `push`——`go` 会替换整个路由栈，
/// 这正是单引擎架构痛点的体现。当 Host_App 从 Native C 调用
/// `navigateToOrderConfirm` 时，Flutter 端的 `/product_detail`
/// 路由状态会被完全替换为 `/order_confirm`。
class NavigationFlutterApiImpl implements NavigationFlutterApi {
  final GoRouter _router;

  NavigationFlutterApiImpl(this._router);

  @override
  void navigateToProductDetail(String productId) {
    try {
      _router.go('/product_detail', extra: productId);
    } catch (e, stackTrace) {
      debugPrint('=== ERROR in navigateToProductDetail: $e ===');
      debugPrint('=== $stackTrace ===');
    }
  }

  @override
  void navigateToOrderConfirm(ApiOrderInfo orderInfo) {
    try {
      _router.go(
        '/order_confirm',
        extra: <String, dynamic>{
          'orderId': orderInfo.orderId,
          'productName': orderInfo.productName,
          'price': orderInfo.price,
        },
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERROR in navigateToOrderConfirm: $e ===');
      debugPrint('=== $stackTrace ===');
    }
  }
}

# 实施任务：单引擎架构混合栈 Demo

## 任务列表

- [x] 1. 扩展 Pigeon 接口定义
  - [x] 1.1 在 `pigeons/answer_detail_api.dart` 中新增 `ApiOrderInfo` 数据类
  - [x] 1.2 在 `pigeons/answer_detail_api.dart` 中新增 `NavigationFlutterApi`（`@FlutterApi`），包含 `navigateToProductDetail` 和 `navigateToOrderConfirm` 方法
  - [x] 1.3 在 `pigeons/answer_detail_api.dart` 中新增 `NavigationHostApi`（`@HostApi`），包含 `openCustomerService`、`goBack` 和 `confirmOrder` 方法
  - [x] 1.4 运行 Pigeon 代码生成，生成 Dart 和 Swift 代码

- [x] 2. 创建商品详情页（Flutter 页面 B）
  - [x] 2.1 创建 `lib/src/pages/product_detail_page.dart`，实现 `ProductDetailPage` StatelessWidget
  - [x] 2.2 实现页面 UI：AppBar（含返回按钮）、路径说明 Banner、商品信息区域、联系客服按钮、痛点说明区域
  - [x] 2.3 接入 `NavigationHostApi`：返回按钮调用 `goBack()`，联系客服按钮调用 `openCustomerService()`

- [x] 3. 创建订单确认页（Flutter 页面 D）
  - [x] 3.1 创建 `lib/src/pages/order_confirm_page.dart`，实现 `OrderConfirmPage` StatelessWidget
  - [x] 3.2 实现页面 UI：AppBar（含返回按钮）、路径说明 Banner、订单信息区域、确认下单按钮
  - [x] 3.3 接入 `NavigationHostApi`：返回按钮调用 `goBack()`，确认下单按钮调用 `confirmOrder(orderId)`

- [x] 4. 实现 NavigationFlutterApi
  - [x] 4.1 创建 `lib/src/navigation_flutter_api_impl.dart`，实现 `NavigationFlutterApiImpl`
  - [x] 4.2 实现 `navigateToProductDetail`：使用 `router.go('/product_detail', extra: productId)`
  - [x] 4.3 实现 `navigateToOrderConfirm`：使用 `router.go('/order_confirm', extra: orderInfoMap)`

- [x] 5. 更新 main.dart 路由配置
  - [x] 5.1 在 GoRouter 中新增 `/product_detail` 路由，builder 从 `state.extra` 获取 productId
  - [x] 5.2 在 GoRouter 中新增 `/order_confirm` 路由，builder 从 `state.extra` 获取订单信息 Map
  - [x] 5.3 在 `initState` 中注册 `NavigationFlutterApi.setUp(NavigationFlutterApiImpl(_router))`
  - [x] 5.4 验证现有路由（`/`、`/answer_detail`、`/iconEditor`）不受影响

- [x] 6. 编译验证
  - [x] 6.1 运行 `fvm flutter pub get` 确保依赖正常
  - [x] 6.2 运行 `fvm flutter analyze` 验证编译通过

# 设计文档：单引擎架构混合栈 Demo

## 概述

本设计在 `apps/answer_detail_module` 现有架构基础上，新增两个 Flutter 页面（商品详情页 B、订单确认页 D）和对应的 Pigeon 导航通信接口，以复现单引擎架构下混合栈路由管理的痛点。

设计原则：
- **最小侵入**：保留现有路由和 Pigeon 接口不变，仅新增内容
- **教学优先**：页面 UI 保持简洁，重点展示架构问题
- **类型安全**：所有原生-Flutter 通信均通过 Pigeon 生成的类型安全接口

## 架构概览

```
┌─────────────────────────────────────────────────────┐
│                   iOS Host App                       │
│                                                     │
│  Native A ──→ Flutter B ──→ Native C ──→ Flutter D  │
│  (首页)      (商品详情)    (客服聊天)    (订单确认)    │
│                                                     │
│         ┌──── 单一 FlutterEngine ────┐              │
│         │  GoRouter (共享页面栈)       │              │
│         │  /product_detail (页面 B)   │              │
│         │  /order_confirm  (页面 D)   │              │
│         └────────────────────────────┘              │
│                                                     │
│  Pigeon 通信层:                                      │
│  NavigationFlutterApi (iOS → Flutter): 导航指令      │
│  NavigationHostApi    (Flutter → iOS): 操作请求      │
└─────────────────────────────────────────────────────┘
```

**痛点展示核心**：由于只有一个 FlutterEngine，当用户从 Native C 跳转到 Flutter D 时，GoRouter 执行 `go('/order_confirm')`，会**替换**掉之前 Flutter B 的路由状态。Flutter 端无法维护 B 和 D 两个独立的页面栈——这正是单引擎架构的核心缺陷。

## 详细设计

### 1. Pigeon 接口扩展

在现有 `pigeons/answer_detail_api.dart` 文件中新增导航相关的 Pigeon 接口定义。

#### 1.1 新增数据类

```dart
/// 订单信息，用于传递给 Order_Confirm_Page
class ApiOrderInfo {
  ApiOrderInfo({
    required this.orderId,
    required this.productName,
    required this.price,
  });

  final String orderId;
  final String productName;
  final double price;
}
```

#### 1.2 新增 FlutterApi（iOS → Flutter）

```dart
/// iOS → Flutter：原生端驱动 Flutter 页面导航
@FlutterApi()
abstract class NavigationFlutterApi {
  void navigateToProductDetail(String productId);
  void navigateToOrderConfirm(ApiOrderInfo orderInfo);
}
```

#### 1.3 新增 HostApi（Flutter → iOS）

```dart
/// Flutter → iOS：Flutter 端请求原生端执行操作
@HostApi()
abstract class NavigationHostApi {
  void openCustomerService();
  void goBack();
  void confirmOrder(String orderId);
}
```

#### 1.4 与现有接口的关系

- `AnswerDetailFlutterApi` 和 `AnswerDetailHostApi` 保持不变
- 新增的 `NavigationFlutterApi` 和 `NavigationHostApi` 是独立的 Pigeon 接口
- Pigeon 会为每组接口生成独立的 `setUp` / `setup` 方法，互不干扰

### 2. Flutter 页面实现

#### 2.1 商品详情页 (Product_Detail_Page)

**文件路径**：`apps/answer_detail_module/lib/src/pages/product_detail_page.dart`

```dart
class ProductDetailPage extends StatelessWidget {
  final String productId;
  final NavigationHostApi hostApi;

  // UI 结构:
  // ┌─────────────────────────────┐
  // │ AppBar: 商品详情 [返回按钮]    │
  // ├─────────────────────────────┤
  // │ 🏷️ 路径说明 Banner           │
  // │ "Flutter 页面 B - 商品详情"   │
  // │ "路径: Native A → Flutter B" │
  // ├─────────────────────────────┤
  // │ 商品名称                     │
  // │ 商品价格                     │
  // │ 商品描述                     │
  // ├─────────────────────────────┤
  // │ [联系客服] 按钮               │
  // ├─────────────────────────────┤
  // │ ⚠️ 痛点说明区域               │
  // │ 单引擎架构下，当从 Native C   │
  // │ 跳转到 Flutter D 时，本页面   │
  // │ 的路由状态会被覆盖...         │
  // └─────────────────────────────┘
}
```

**关键行为**：
- 通过构造函数接收 `productId`，使用硬编码的 Demo 商品数据展示
- "联系客服"按钮调用 `hostApi.openCustomerService()`
- 返回按钮调用 `hostApi.goBack()`
- 页面使用 `NavigationHostApi` 实例与原生端通信

#### 2.2 订单确认页 (Order_Confirm_Page)

**文件路径**：`apps/answer_detail_module/lib/src/pages/order_confirm_page.dart`

```dart
class OrderConfirmPage extends StatelessWidget {
  final String orderId;
  final String productName;
  final double price;
  final NavigationHostApi hostApi;

  // UI 结构:
  // ┌─────────────────────────────────────┐
  // │ AppBar: 订单确认 [返回按钮]           │
  // ├─────────────────────────────────────┤
  // │ 🏷️ 路径说明 Banner                   │
  // │ "Flutter 页面 D - 订单确认"           │
  // │ "路径: Native A → Flutter B →        │
  // │        Native C → Flutter D"        │
  // ├─────────────────────────────────────┤
  // │ 订单编号: ORD-XXXX                   │
  // │ 商品名称: XXX                        │
  // │ 商品价格: ¥XXX                       │
  // │ 收货地址: [占位文本]                  │
  // ├─────────────────────────────────────┤
  // │ [确认下单] 按钮                       │
  // └─────────────────────────────────────┘
}
```

**关键行为**：
- 通过构造函数接收订单信息（orderId, productName, price）
- "确认下单"按钮调用 `hostApi.confirmOrder(orderId)`
- 返回按钮调用 `hostApi.goBack()`

### 3. 路由配置

在 `main.dart` 的 GoRouter 配置中新增两条路由：

```dart
GoRoute(
  path: '/product_detail',
  builder: (context, state) {
    final productId = state.extra as String;
    return ProductDetailPage(
      productId: productId,
      hostApi: _navigationHostApi,
    );
  },
),
GoRoute(
  path: '/order_confirm',
  builder: (context, state) {
    final orderInfo = state.extra as Map<String, dynamic>;
    return OrderConfirmPage(
      orderId: orderInfo['orderId'] as String,
      productName: orderInfo['productName'] as String,
      price: orderInfo['price'] as double,
      hostApi: _navigationHostApi,
    );
  },
),
```

### 4. NavigationFlutterApi 实现

**文件路径**：`apps/answer_detail_module/lib/src/navigation_flutter_api_impl.dart`

```dart
class NavigationFlutterApiImpl implements NavigationFlutterApi {
  final GoRouter _router;

  NavigationFlutterApiImpl(this._router);

  @override
  void navigateToProductDetail(String productId) {
    _router.go('/product_detail', extra: productId);
  }

  @override
  void navigateToOrderConfirm(ApiOrderInfo orderInfo) {
    _router.go('/order_confirm', extra: {
      'orderId': orderInfo.orderId,
      'productName': orderInfo.productName,
      'price': orderInfo.price,
    });
  }
}
```

**注意**：这里使用 `go` 而非 `push`，这是**刻意为之**——`go` 会替换整个路由栈，正是单引擎痛点的体现。当 Host_App 从 Native C 调用 `navigateToOrderConfirm` 时，Flutter 端的 `/product_detail` 路由状态会被完全替换为 `/order_confirm`。

### 5. main.dart 集成

在 `_AnswerDetailModuleAppState.initState()` 中注册新的 Pigeon API：

```dart
@override
void initState() {
  super.initState();

  final navigationHostApi = NavigationHostApi();

  _router = GoRouter(
    initialLocation: '/',
    routes: [
      // ... 现有路由保持不变 ...
      // 新增路由
      GoRoute(path: '/product_detail', ...),
      GoRoute(path: '/order_confirm', ...),
    ],
  );

  // 注册现有 API
  AnswerDetailFlutterApi.setUp(AnswerDetailFlutterApiImpl(_router));
  // 注册新增导航 API
  NavigationFlutterApi.setUp(NavigationFlutterApiImpl(_router));
}
```

### 6. 文件结构变更

```
apps/answer_detail_module/
├── lib/
│   ├── main.dart                          # 修改：新增路由 + 注册 NavigationFlutterApi
│   └── src/
│       ├── pages/
│       │   ├── product_detail_page.dart   # 新增：商品详情页
│       │   └── order_confirm_page.dart    # 新增：订单确认页
│       ├── navigation_flutter_api_impl.dart # 新增：NavigationFlutterApi 实现
│       ├── generated/
│       │   └── answer_detail_api.g.dart   # 重新生成：包含新增接口
│       ├── answer_detail_flutter_api_impl.dart  # 不变
│       └── pigeon_converters.dart               # 不变
├── pigeons/
│   └── answer_detail_api.dart             # 修改：新增 NavigationFlutterApi/HostApi/ApiOrderInfo
└── pubspec.yaml                           # 不变
```

## 正确性属性

由于本功能是教学/演示性质的 UI 页面和平台通道集成，主要涉及：
- UI 渲染（Widget 存在性检查）
- 平台通道调用（Mock 验证方法调用）
- 路由配置（路由表结构验证）

这些场景适合使用示例测试（example-based tests），不适合属性测试（property-based tests）。原因：
1. 行为不随输入显著变化（页面展示固定内容）
2. 测试的是 UI 渲染和平台通道集成，非纯函数逻辑
3. 100 次迭代不会比 2-3 个示例发现更多 Bug

### 示例测试清单

| 验收标准 | 测试类型 | 测试描述 |
|---------|---------|---------|
| 1.2 商品信息展示 | Widget Test | 验证 ProductDetailPage 渲染商品名称、价格、描述 |
| 1.3 联系客服按钮 | Widget Test | 验证"联系客服"按钮存在 |
| 1.4 点击联系客服 | Widget Test | Mock NavigationHostApi，验证点击后调用 openCustomerService |
| 1.6 点击返回 | Widget Test | Mock NavigationHostApi，验证点击后调用 goBack |
| 2.2 订单信息展示 | Widget Test | 验证 OrderConfirmPage 渲染订单编号、商品名称、价格、地址 |
| 2.4 点击确认下单 | Widget Test | Mock NavigationHostApi，验证点击后调用 confirmOrder |
| 2.6 点击返回 | Widget Test | Mock NavigationHostApi，验证点击后调用 goBack |
| 5.3 路径说明文字 | Widget Test | 验证 ProductDetailPage 包含路径说明 Banner |
| 5.4 路径说明文字 | Widget Test | 验证 OrderConfirmPage 包含路径说明 Banner |
| 5.5 痛点说明文字 | Widget Test | 验证 ProductDetailPage 包含痛点说明区域 |

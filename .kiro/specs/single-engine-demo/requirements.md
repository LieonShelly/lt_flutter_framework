# 需求文档：单引擎架构混合栈 Demo

## 简介

本功能在 `apps/answer_detail_module` 中复现**单引擎架构 (Single Engine) 的核心缺点**——混合栈路由管理困难。通过构建一个原生-Flutter 交替跳转的 Demo 场景（原生 A → Flutter B → 原生 C → Flutter D），直观展示单引擎下页面栈状态共享导致的路由管理痛点。

本 Demo 为教学/演示用途，页面内容保持简洁，重点在于路由架构和原生-Flutter 通信机制的展示。

## 术语表

- **Single_Engine**：单引擎架构，整个原生 App 生命周期内只维护一个 FlutterEngine 实例
- **Mixed_Stack**：混合栈，原生页面与 Flutter 页面在同一导航栈中交替出现的路由模式
- **Router**：基于 GoRouter 的 Flutter 端路由管理器
- **Platform_Channel**：Flutter 与原生端之间的双向通信通道，本项目使用 Pigeon 生成类型安全的通信代码
- **Host_App**：集成 Flutter XCFramework 的 iOS 原生宿主工程
- **Product_Detail_Page**：商品详情页（Flutter 页面 B），展示商品信息
- **Order_Confirm_Page**：订单确认页（Flutter 页面 D），展示订单确认信息
- **Native_Page_A**：App 首页（原生页面），由 Host_App 实现
- **Native_Page_C**：客服聊天页（原生页面），由 Host_App 实现
- **Navigation_Api**：Pigeon 生成的导航通信接口，用于 Flutter 与原生端之间的页面跳转指令传递

## 需求

### 需求 1：商品详情页（Flutter 页面 B）

**用户故事：** 作为开发者，我希望在 Flutter 端实现一个商品详情页，以便在混合栈 Demo 中作为第一个 Flutter 页面展示。

#### 验收标准

1. WHEN Host_App 通过 Navigation_Api 发送 `navigateToProductDetail` 指令并携带商品 ID 参数, THE Router SHALL 导航至 `/product_detail` 路由并展示 Product_Detail_Page
2. THE Product_Detail_Page SHALL 展示以下商品信息：商品名称、商品价格、商品描述文本
3. THE Product_Detail_Page SHALL 包含一个"联系客服"按钮，用于触发跳转到 Native_Page_C
4. WHEN 用户点击"联系客服"按钮, THE Product_Detail_Page SHALL 通过 Platform_Channel 向 Host_App 发送 `openCustomerService` 指令
5. THE Product_Detail_Page SHALL 包含一个返回按钮，用于触发返回到 Native_Page_A
6. WHEN 用户点击返回按钮, THE Product_Detail_Page SHALL 通过 Platform_Channel 向 Host_App 发送 `goBack` 指令

### 需求 2：订单确认页（Flutter 页面 D）

**用户故事：** 作为开发者，我希望在 Flutter 端实现一个订单确认页，以便在混合栈 Demo 中作为第二个 Flutter 页面展示。

#### 验收标准

1. WHEN Host_App 通过 Navigation_Api 发送 `navigateToOrderConfirm` 指令并携带订单信息参数, THE Router SHALL 导航至 `/order_confirm` 路由并展示 Order_Confirm_Page
2. THE Order_Confirm_Page SHALL 展示以下订单信息：商品名称、商品价格、收货地址占位文本、订单编号
3. THE Order_Confirm_Page SHALL 包含一个"确认下单"按钮
4. WHEN 用户点击"确认下单"按钮, THE Order_Confirm_Page SHALL 通过 Platform_Channel 向 Host_App 发送 `confirmOrder` 指令
5. THE Order_Confirm_Page SHALL 包含一个返回按钮，用于触发返回到 Native_Page_C
6. WHEN 用户点击返回按钮, THE Order_Confirm_Page SHALL 通过 Platform_Channel 向 Host_App 发送 `goBack` 指令

### 需求 3：路由配置与管理

**用户故事：** 作为开发者，我希望在 `main.dart` 中配置好混合栈 Demo 所需的路由，以便 Host_App 能够通过 Platform_Channel 驱动 Flutter 端的页面导航。

#### 验收标准

1. THE Router SHALL 在现有路由配置基础上新增 `/product_detail` 和 `/order_confirm` 两条路由
2. THE Router SHALL 保留现有的 `/`、`/answer_detail` 和 `/iconEditor` 路由不受影响
3. WHEN Navigation_Api 接收到导航指令, THE Router SHALL 根据指令类型导航到对应的 Flutter 页面
4. IF Navigation_Api 接收到未知的导航指令, THEN THE Router SHALL 忽略该指令并在调试控制台输出警告日志

### 需求 4：Pigeon 导航通信接口

**用户故事：** 作为开发者，我希望通过 Pigeon 定义类型安全的导航通信接口，以便 Host_App 和 Flutter 端之间能够可靠地传递页面跳转指令和业务数据。

#### 验收标准

1. THE Navigation_Api SHALL 定义一个 `@FlutterApi` 接口，包含 `navigateToProductDetail` 方法，接收商品 ID 参数（String 类型）
2. THE Navigation_Api SHALL 定义一个 `@FlutterApi` 接口，包含 `navigateToOrderConfirm` 方法，接收订单信息参数（包含商品名称、价格、订单编号）
3. THE Navigation_Api SHALL 定义一个 `@HostApi` 接口，包含 `openCustomerService` 方法，用于 Flutter 端请求 Host_App 打开客服聊天页
4. THE Navigation_Api SHALL 定义一个 `@HostApi` 接口，包含 `goBack` 方法，用于 Flutter 端请求 Host_App 执行返回操作
5. THE Navigation_Api SHALL 定义一个 `@HostApi` 接口，包含 `confirmOrder` 方法，接收订单编号参数，用于 Flutter 端通知 Host_App 订单已确认
6. THE Navigation_Api SHALL 与现有的 `AnswerDetailFlutterApi` 和 `AnswerDetailHostApi` 共存于同一 Pigeon 定义文件中，互不干扰

### 需求 5：混合栈痛点展示

**用户故事：** 作为学习者，我希望通过 Demo 直观感受单引擎架构下混合栈路由管理的困难，以便理解为什么需要 FlutterEngineGroup 或 FlutterBoost 等方案。

#### 验收标准

1. WHILE Single_Engine 运行中且用户从 Native_Page_A 跳转到 Product_Detail_Page, THE Router SHALL 使用 `go` 方法导航（替换当前路由栈），展示单引擎下页面栈状态共享的特性
2. WHILE Single_Engine 运行中且用户从 Native_Page_C 跳转到 Order_Confirm_Page, THE Router SHALL 使用 `go` 方法导航（替换当前路由栈），展示同一引擎内路由状态被覆盖的问题
3. THE Product_Detail_Page SHALL 在页面顶部展示一段说明文字，描述当前处于混合栈的哪个位置（例如："Flutter 页面 B - 商品详情 | 路径：Native A → Flutter B"）
4. THE Order_Confirm_Page SHALL 在页面顶部展示一段说明文字，描述当前处于混合栈的哪个位置（例如："Flutter 页面 D - 订单确认 | 路径：Native A → Flutter B → Native C → Flutter D"）
5. THE Product_Detail_Page SHALL 在页面底部展示一段痛点说明文字，解释单引擎架构下为什么从 Native_Page_C 跳转到 Order_Confirm_Page 时，Product_Detail_Page 的状态会丢失

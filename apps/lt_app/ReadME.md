# lt_app — The Little Thing

> **一款帮助你持续自我反思、记录成长的轻量级 App**

---

## 目录

- [产品概述](#一产品概述)
- [核心功能](#二核心功能)
- [技术架构](#三技术架构)
- [工程结构](#四工程结构)
- [核心技术栈](#五核心技术栈)
- [模块依赖关系](#六模块依赖关系)
- [路由设计](#七路由设计)
- [依赖注入与 Provider 策略](#八依赖注入与-provider-策略)
- [网络层设计](#九网络层设计)
- [本地开发指南](#十本地开发指南)

---

## 一、产品概述

**The Little Thing** 是一款专注于「每日自我反思」的轻量级移动应用。App 以每日问题为核心驱动，帮助用户养成规律记录、回顾成长轨迹的习惯。结合 AI Copilot 辅助、日历可视化和区块链钱包能力，为用户提供智能、沉浸式的成长反思体验。

### 产品定位

| 维度 | 描述 |
|------|------|
| 目标用户 | 追求自我成长、关注内在生活质量的个人用户 |
| 核心价值 | 降低自我反思门槛，让每日记录成为一种习惯 |
| 产品风格 | 轻量、温暖、非打扰式 |
| 平台支持 | iOS / Android（Flutter 跨平台） |

---

## 二、核心功能

### 2.1 今日问题（Today Question）

- 每日推送一个引导性问题，作为自我反思的起点
- 在主界面以 Banner 形式常驻展示，轻触即可进入答题
- 支持多语言（中文 / 英文）

### 2.2 日历（Calendar）

- 以月历形式可视化展示历史反思记录
- 支持按日期导航，快速回顾特定日期的问题与答案
- 应用启动后默认进入日历页面（初始路由为 `/calendar`）

### 2.3 Thread（问题流）

- 以 Feed 流形式展示所有历史问题列表
- 支持浏览每个问题的详情与已有答案

### 2.4 添加答案（Add Answer）

- 为指定问题撰写并提交个人答案
- 支持附加图标（Icon）标记答案情绪/主题
- 以全屏覆盖（Root Navigator）形式呈现，避免 Tab 干扰

### 2.5 答案详情（Answer Detail）

- 查看某条答案的完整内容
- 支持查看问题背景信息
- 支持多语言本地化（`AnswerDetailLocalizations`）

### 2.6 AI Copilot（智能助手）

- 集成 AI 对话能力，辅助用户深入反思
- 独立 Chat API 端点，与主业务接口解耦
- 支持上下文感知的问答体验

### 2.7 用户中心（User）

- 查看和管理个人账户信息
- 支持登录 / 登出操作

### 2.8 钱包（Wallets）

- 集成 Web3 钱包功能（基于 `web3dart`）
- 支持查看钱包余额与交易记录
- 独立的 Wallet 领域模型与数据层

---

## 三、技术架构

`lt_app` 是整个 `lt_flutter_framework` Monorepo 的**应用壳（Shell App）**，本身不包含业务逻辑，仅负责：

1. **应用启动与初始化**
2. **全局路由聚合**
3. **依赖注入容器配置（ProviderScope Override）**
4. **将各功能模块组合成完整 App**

### 整体分层架构

```
┌────────────────────────────────────────────────────────┐
│                   Apps Layer (应用壳)                   │
│              apps/lt_app  ← 当前工程                    │
└────────────────────────────────────────────────────────┘
                          ↓ 依赖
┌────────────────────────────────────────────────────────┐
│              Features Layer (功能模块 · Presentation)   │
│   calendar / thread / copilot / user / wallets / ...   │
└────────────────────────────────────────────────────────┘
                          ↓ 依赖
┌────────────────────────────────────────────────────────┐
│              Domain Layer (业务逻辑 · 纯 Dart)          │
│   reflection_domain / user_domain / wallet_domain      │
└────────────────────────────────────────────────────────┘
                          ↑ 实现接口
┌────────────────────────────────────────────────────────┐
│              Data Layer (数据访问)                      │
│   reflection_data / user_data / wallet_data            │
└────────────────────────────────────────────────────────┘
                          ↓ 依赖
┌────────────────────────────────────────────────────────┐
│              Core Layer (基础设施)                      │
│       lt_network / lt_uicomponent / storage            │
└────────────────────────────────────────────────────────┘
```

**依赖方向**：单向向内，外层依赖内层，内层永不依赖外层。

---

## 四、工程结构

```
apps/lt_app/
├── pubspec.yaml              # 工程配置与依赖声明
├── analysis_options.yaml     # Dart 静态分析配置
├── lib/
│   ├── main.dart             # 应用入口
│   ├── theme_main.dart       # 主题调试入口
│   └── src/
│       ├── app_router.dart   # GoRouter 全局路由配置
│       ├── app_router.g.dart # 路由代码生成产物
│       ├── home_view.dart    # 主 Shell 页面（Tab 导航容器）
│       └── di/
│           └── app_providers.dart  # ProviderScope Overrides（DI 配置）
├── ios/                      # iOS 平台代码
├── android/                  # Android 平台代码
└── examples/                 # 示例代码（用于功能演示）
```

---

## 五、核心技术栈

| 类别 | 技术 / 库 | 版本 | 用途 |
|------|-----------|------|------|
| UI 框架 | Flutter | SDK ^3.8.1 | 跨平台 UI 渲染 |
| 状态管理 | flutter_riverpod | ^3.1.0 | 全局状态与依赖注入 |
| 路由 | go_router | ^17.0.0 | 声明式导航 |
| 网络请求 | dio | ^5.9.0 | HTTP 客户端 |
| 数据序列化 | freezed + json_annotation | ^3.1.0 / ^4.8.1 | 不可变数据模型 + JSON 序列化 |
| 本地存储 | flutter_secure_storage | ^10.0.0 | Token 安全存储 |
| 图片缓存 | cached_network_image | ^3.4.1 | 网络图片缓存 |
| SVG 支持 | flutter_svg | ^2.0.9 | SVG 资源渲染 |
| Web3 | web3dart | ^2.7.3 | 区块链钱包集成 |
| 国际化 | flutter_localizations + intl | SDK / ^0.20.2 | 多语言支持 |
| 代码生成 | build_runner + riverpod_generator | ^2.4.8 / ^4.0.0 | 自动生成 Provider 与 JSON 代码 |

---

## 六、模块依赖关系

### 6.1 引用的 Core 包

| 包名 | 路径 | 职责 |
|------|------|------|
| `lt_uicomponent` | `packages/core/lt_uicomponent` | 通用 UI 组件库、主题、图标 |
| `lt_network` | `packages/core/network` | 网络客户端封装、认证拦截器 |

### 6.2 引用的 Domain 包

| 包名 | 路径 | 业务领域 |
|------|------|----------|
| `reflection_domain` | `packages/domain/reflection_domain` | 问题、答案、日历 |
| `user_domain` | `packages/domain/user_domain` | 用户信息、认证 |
| `wallet_domain` | `packages/domain/wallet_domain` | 钱包、交易 |

### 6.3 引用的 Data 包

| 包名 | 路径 | 业务领域 |
|------|------|----------|
| `reflection_data` | `packages/data/reflection_data` | 反思数据访问实现 |
| `user_data` | `packages/data/user_data` | 用户数据访问实现 |
| `wallet_data` | `packages/data/wallet_data` | 钱包数据访问实现 |

### 6.4 引用的 Feature 包

| 包名 | 路径 | 功能 |
|------|------|------|
| `calendar` | `packages/features/calendar` | 日历反思视图 |
| `thread` | `packages/features/thread` | 问题流 |
| `today_question` | `packages/features/today_question` | 今日问题 Banner |
| `add_answer` | `packages/features/add_answer` | 添加答案 |
| `answer_detail` | `packages/features/answer_detail` | 答案详情 |
| `copilot` | `packages/features/copilot` | AI 助手 |
| `user` | `packages/features/user` | 用户中心 |
| `wallets` | `packages/features/wallets` | 钱包功能 |
| `feature_core` | `packages/features/feature_core` | Feature 共享基础（路由路径、TabBar 等） |

### 6.5 引用的工具包

| 包名 | 路径 | 功能 |
|------|------|------|
| `date_utl` | `packages/utls/date_utl` | 日期格式化工具 |
| `lt_annotation` | `packages/utls/lt_annotation` | 自定义代码注解（如 `@ltDeserialization`） |

---

## 七、路由设计

路由采用 **GoRouter + StatefulShellRoute** 实现 Tab 导航与全局路由的统一管理。

```dart
// src/app_router.dart

GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePath.calendar,  // 默认打开日历页
  routes: [
    // ① StatefulShellRoute：Tab Bar 导航（保持各 Tab 页面状态）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeView(navigationShell: navigationShell);
      },
      branches: [
        ...CalendarRouteConfig().shellBranches,   // Tab: 日历
        ...ThreadRouteConfig().shellBranches,     // Tab: Thread
        ...CopilotRouteConfig().shellBranches,    // Tab: AI Copilot
        ...UserRouteConfig().shellBranches,       // Tab: 用户中心
      ],
    ),

    // ② Top-Level Routes：以 Root Navigator 覆盖呈现（不受 Tab 影响）
    ...AnswerDetailRouteConfig(_rootNavigatorKey).routes,
    ...AddAnswerRouteConfig(_rootNavigatorKey).routes,
    ...WalletsRouteConfig().routes,
  ],
)
```

**设计要点**：

- `StatefulShellBranch` 保证各 Tab 独立维护页面状态，切换 Tab 不会重置页面
- 答案详情、添加答案使用 `_rootNavigatorKey` 覆盖呈现，实现全屏模态效果
- 每个 Feature 包自行导出 `RouteConfig`，路由定义与 UI 逻辑内聚在功能包内

### 路由路径常量（由 `feature_core` 统一维护）

```
AppRoutePath.calendar     → /calendar
AppRoutePath.thread       → /thread
AppRoutePath.copilot      → /copilot
AppRoutePath.user         → /user
```

---

## 八、依赖注入与 Provider 策略

### 8.1 ProviderScope Override

`lt_app` 在 `main.dart` 中通过 `ProviderScope` 的 `overrides` 将具体实现注入到 Provider 容器：

```dart
// main.dart
void main() {
  runApp(
    ProviderScope(
      overrides: AppProviders.overrides,
      child: const MyApp(),
    ),
  );
}
```

### 8.2 AppProviders（DI 配置核心）

```dart
// src/di/app_providers.dart

class AppProviders {
  static dynamic get overrides => [
    // ① 生产/调试环境切换：Token 存储
    // isProduction → SecureTokenStorage()
    // isDev       → MockTokenStorage()

    // ② 为各业务模块注入对应的 API Client
    reflection.apiClientProvider.overrideWith(...)  // 主 API
    reflection.chatApiClientProvider.overrideWith(...)  // Chat API（Copilot）
    user.apiClientProvider.overrideWith(...)
    wallet.apiClientProvider.overrideWith(...)
  ];
}
```

### 8.3 双 API Client 设计

| Client | Base URL | 用途 |
|--------|----------|------|
| `HttpApiClient(baseUrl: 'https://things.dvacode.tech')` | 主业务 API | 反思、用户、钱包 |
| `HttpApiClient(baseUrl: NetworkConfig.getChatApiBaseUrl())` | Chat API | AI Copilot 对话 |

### 8.4 环境切换策略

通过 Dart 编译时常量 `dart.vm.product` 自动区分环境：

```dart
const isProduction = bool.fromEnvironment('dart.vm.product');
return isProduction ? SecureTokenStorage() : MockTokenStorage();
```

- **Debug 模式**：使用 `MockTokenStorage`，无需真实 Token 即可调试
- **Release 模式**：使用 `SecureTokenStorage`，Token 加密存储于设备安全区

---

## 九、网络层设计

网络层封装于 `packages/core/network`（`lt_network` 包），`lt_app` 仅负责在 DI 中注入具体配置。

### 数据流完整链路

```
用户操作（UI）
    ↓
Controller（Riverpod StateNotifier）
    ↓  ref.read(useCaseProvider)
UseCase（Domain Layer）
    ↓  repository.fetchXXX()
Repository Interface（Domain Layer）
    ↑  implements
Repository Implementation（Data Layer）
    ↓  dataSource.fetchXXX()
DataSource（Remote / Local）
    ↓  apiClient.get/post()
HttpApiClient（Core Layer - Dio）
    ↓  HTTP Request
Backend API（https://things.dvacode.tech）
```

### Provider 依赖链

```
Feature UseCase Provider（Features Layer）
    ↓ ref.watch(repositoryProvider)
Repository Provider（Data Layer）
    ↓ ref.watch(dataSourceProvider)
DataSource Provider（Data Layer）
    ↓ ref.watch(apiClientProvider)
API Client Provider（Core Layer）← 由 lt_app DI Override 注入
    ↓ ref.watch(tokenStorageProvider)
Token Storage Provider（Core Layer）← 由 lt_app DI Override 注入
```

---

## 十、本地开发指南

### 环境要求

| 工具 | 版本要求 |
|------|----------|
| Flutter | 使用 FVM 管理，见根目录 `.fvmrc` |
| Dart SDK | ^3.8.1 |
| Xcode | 最新稳定版（iOS 开发） |
| Android Studio | 最新稳定版（Android 开发） |

### 快速启动

```bash
# 1. 在 Monorepo 根目录安装所有包依赖
fvm flutter pub get

# 2. 生成代码（Provider / JSON 序列化）
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 3. 运行应用（iOS 模拟器）
cd apps/lt_app
fvm flutter run

# 4. 运行应用（指定设备）
fvm flutter run -d <device_id>
```

### 代码生成

项目使用 `build_runner` 自动生成以下代码：

| 生成目标 | 来源注解 | 产物文件 |
|----------|----------|----------|
| Riverpod Provider | `@riverpod` | `*.g.dart` |
| 不可变数据类 | `@freezed` | `*.freezed.dart` |
| JSON 序列化 | `@JsonSerializable` | `*.g.dart` |
| 自定义反序列化 | `@ltDeserialization` | 见 `lt_annotation` |

```bash
# 监听模式（开发时推荐）
fvm flutter pub run build_runner watch --delete-conflicting-outputs
```

### 多语言

App 支持中英双语，语言资源分布在各 Feature 包中。以 `answer_detail` 为例：

```dart
localizationsDelegates: const [
  AnswerDetailLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [Locale('en'), Locale('zh')],
```

---

## 附录：关键设计决策

| 决策 | 原因 |
|------|------|
| Monorepo + Dart Workspace | 统一依赖版本，避免包版本冲突，跨包调试方便 |
| Feature 包自行创建 UseCase Provider | 保持 Provider 按需创建，避免全局 Provider 膨胀 |
| 双 API Client | AI Chat 接口与主业务接口天然解耦，便于独立扩展和替换 |
| Root Navigator 覆盖模态页面 | 添加答案、答案详情等场景需要脱离 Tab Bar，避免 UI 干扰 |
| Debug/Release 存储策略分离 | MockTokenStorage 让本地调试无需依赖真实鉴权环境 |
| StatefulShellRoute | 保留各 Tab 页面状态，提升 Tab 切换体验 |

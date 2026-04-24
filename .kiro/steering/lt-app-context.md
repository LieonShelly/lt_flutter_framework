# lt_app — 工程全局上下文

## 产品定位

`lt_app`（The Little Thing）是一款以**每日自我反思**为核心的轻量级移动 App，核心功能：今日问题、日历反思记录、Thread 问题流、AI Copilot 助手、用户中心、Web3 钱包。

`lt_app` 是整个 Monorepo 的**壳工程（Shell App）**，本身不含业务逻辑，只负责：
- 应用启动与初始化
- 全局路由聚合（GoRouter）
- ProviderScope DI 配置（override 各模块依赖）
- 将各 Feature 包组装成完整 App

---

## Clean Architecture 分层（严格遵守）

```
Apps → Features → Domain ← Data → Core
```

| 层级 | 路径 | 职责 |
|------|------|------|
| Core | `packages/core/` | 基础设施：网络、UI 组件库、安全存储 |
| Domain | `packages/domain/` | 纯 Dart：Entity、Repository 接口、UseCase |
| Data | `packages/data/` | 实现 Domain 接口：Model(DTO)、DataSource、Repository 实现、Providers |
| Features | `packages/features/` | UI 页面 + Controller + 按需 UseCase Providers |
| Apps | `apps/lt_app/` | 壳工程：路由聚合 + DI 配置 |

**依赖规则**：外层依赖内层，内层禁止依赖外层。Domain 层为纯 Dart，不依赖 Flutter。

---

## 关键包列表

### Core
- `lt_network`：Dio 网络客户端、认证拦截器、Token 刷新
- `lt_uicomponent`：通用组件库、主题、图标
- `storage`：SecureTokenStorage

### Domain
- `reflection_domain`：问题、答案、日历（Entity + Repository接口 + UseCase）
- `user_domain`：用户信息、认证
- `wallet_domain`：钱包、交易记录
- `booking_domain`：预约功能

### Data
- `reflection_data` / `user_data` / `wallet_data` / `booking_data`

### Features
- `calendar`, `thread`, `today_question`, `add_answer`, `answer_detail`
- `copilot`, `user`, `wallets`, `booking`, `shop`, `feature_core`

### Utils
- `date_utl`：日期工具
- `lt_annotation`：自定义注解（`@ltDeserialization`）
- `common`：通用工具

---

## 路由设计

- 使用 **GoRouter + StatefulShellRoute.indexedStack** 实现 Tab 导航
- Tab 页（Calendar / Thread / Copilot / User）：`StatefulShellBranch`，保留各 Tab 状态
- 全屏覆盖页（AddAnswer / AnswerDetail / Wallets）：使用 `_rootNavigatorKey`，脱离 Tab Bar
- 路由路径常量统一在 `feature_core` 的 `AppRoutePath` 中定义
- 默认初始路由：`AppRoutePath.calendar`（`/calendar`）
- 每个 Feature 包自行导出 `RouteConfig`，路由定义内聚于功能包

---

## DI / ProviderScope 规范

- `apps/lt_app/lib/src/di/app_providers.dart` 统一管理 override
- 环境策略：`dart.vm.product == true` → `SecureTokenStorage`；Debug → `MockTokenStorage`
- 双 API Client：
  - 主业务：`https://things.dvacode.tech`
  - AI Chat：`NetworkConfig.getChatApiBaseUrl()`（Copilot 独立）
- 各模块（reflection / user / wallet）持有独立的 `apiClientProvider` override

---

## Provider 分布策略

| 层级 | Provider 内容 | 位置 |
|------|--------------|------|
| Core | `apiClientProvider`, `tokenStorageProvider` | `packages/core/network` |
| Data | `RepositoryProvider`, `DataSourceProvider` | `packages/data/*/providers/` |
| Feature | `UseCaseProvider`（按需，仅本 Feature 需要的）| `packages/features/*/providers/` |

> **禁止**在 Data 层预先创建所有 UseCase Providers；UseCase Providers 属于 Feature 层，按需创建。

---

## Model（DTO）规范

```dart
@freezed
@ltDeserialization
class XxxModel with _$XxxModel {
  const factory XxxModel({required ...}) = _XxxModel;
  factory XxxModel.fromJson(Map<String, dynamic> json) => _$XxxModelFromJson(json);
  XxxEntity toEntity() { ... }              // DTO → Entity（必须）
  factory XxxModel.fromEntity(XxxEntity e) { ... } // Entity → DTO（需要时）
}
```

---

## 常用命令

```bash
make setup                        # 安装所有包依赖
make codegen                      # 全量代码生成
make codegen PACKAGE=lt_app       # 指定包代码生成
make watch PACKAGE=calendar       # 监听模式
make reset                        # clean + setup + codegen
fvm flutter run                   # 运行应用
fvm dart test                     # 运行 Dart 单元测试
```

> 所有 Flutter/Dart 命令必须加 `fvm` 前缀。

---

## 文档参考

- 产品与技术文档：`apps/lt_app/ReadME.md`
- 架构总览：`README.md`（项目根目录）
- API 文档：`docs/API/api.md`

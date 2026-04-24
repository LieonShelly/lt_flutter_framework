---
trigger: always_on
---

# lt_app 工程全局上下文

## 产品定位

`lt_app`（The Little Thing）是一款以**每日自我反思**为核心的轻量级移动 App。用户通过每日问题、日历、Thread 流和 AI Copilot 养成持续记录成长轨迹的习惯。技术上，`lt_app` 是整个 Monorepo 的**壳工程（Shell App）**，本身不包含业务逻辑，只负责：启动初始化、全局路由聚合、ProviderScope DI 配置。

---

## 架构原则（Clean Architecture · 严格遵守）

依赖方向：**单向向内，外层依赖内层，内层禁止依赖外层**

```
Apps → Features → Domain ← Data → Core
```

- **Domain**：纯 Dart，无任何 Flutter 依赖；定义 Entity、Repository 接口、UseCase
- **Data**：实现 Domain 接口；包含 Model(DTO)、DataSource、Repository 实现、Providers
- **Features**：UI 页面 + Riverpod Controller + 按需创建 UseCase Providers（不创建多余的）
- **Core**：网络(Dio)、UI 组件库、安全存储等基础设施
- **Apps/lt_app**：聚合所有 Feature，配置路由和 DI

---

## 技术栈

| 类别 | 方案 |
|------|------|
| 状态管理 / DI | Riverpod (`flutter_riverpod` + `@riverpod` 注解 + `riverpod_generator`) |
| 路由 | GoRouter + StatefulShellRoute（Tab 导航保留页面状态） |
| 网络 | Dio（封装于 `lt_network` Core 包），区分主 API 和 Chat API |
| 数据模型 | Freezed（不可变对象）+ json_serializable（JSON 序列化）|
| 本地存储 | flutter_secure_storage（Token 安全存储）|
| 代码生成 | build_runner（`.g.dart` / `.freezed.dart`）|
| 多语言 | flutter_localizations + intl（支持 zh / en）|
| Web3 | web3dart（钱包功能）|
| Flutter 版本管理 | FVM（`fvm flutter ...` 前缀）|

---

## 包结构速查

```
packages/
├── core/          lt_network · lt_uicomponent · storage · analysis_defaults
├── domain/        reflection_domain · user_domain · wallet_domain · booking_domain
├── data/          reflection_data · user_data · wallet_data · booking_data
├── features/      calendar · thread · today_question · add_answer · answer_detail
│                  copilot · user · wallets · booking · shop · feature_core
└── utls/          date_utl · lt_annotation · common

apps/
└── lt_app/        壳工程（当前工程）
```

---

## 路由约定

- 路由由 **GoRouter + StatefulShellRoute** 管理
- Tab 导航（Calendar / Thread / Copilot / User）使用 `StatefulShellBranch`，保留各 Tab 页面状态
- 全屏覆盖页面（AddAnswer / AnswerDetail）使用 `_rootNavigatorKey`，脱离 Tab Bar 呈现
- 路由路径常量统一在 `feature_core` 包的 `AppRoutePath` 中维护
- 默认初始路由：`AppRoutePath.calendar`（`/calendar`）

---

## DI / ProviderScope 约定

- `lt_app/lib/src/di/app_providers.dart` 统一管理所有 `ProviderScope` overrides
- 生产环境（`dart.vm.product == true`）：使用 `SecureTokenStorage`
- 调试环境：使用 `MockTokenStorage`，无需真实 Token
- 双 API Client：主业务用 `https://things.dvacode.tech`，AI Copilot 独立 Chat API
- 每个数据模块（reflection / user / wallet）各自持有独立的 `apiClientProvider` override

---

## Provider 分布策略（重要）

| 层级 | 位置 | 内容 |
|------|------|------|
| Core Layer | `packages/core/network` | apiClientProvider, tokenStorageProvider |
| Data Layer | `packages/data/*/providers/` | RepositoryProvider, DataSourceProvider |
| Feature Layer | `packages/features/*/providers/` | UseCaseProvider（只创建本 Feature 需要的）|

> ⚠️ **禁止**在 Data Layer 预先创建所有 UseCase Providers，UseCase Providers 属于 Feature 层按需创建。

---

## Data 层 Model 规范

每个 Model（DTO）必须包含：
- `@freezed` + `@ltDeserialization` 注解
- `fromJson` 工厂构造函数
- `toEntity()` 方法（DTO → Entity）
- `fromEntity()` 工厂方法（Entity → DTO，如需写回）

---

## 功能模块速查

| 功能 | Feature 包 | 对应 Domain/Data |
|------|-----------|-----------------|
| 日历 | `calendar` | `reflection_domain` / `reflection_data` |
| 问题流 | `thread` | `reflection_domain` / `reflection_data` |
| 今日问题 Banner | `today_question` | `reflection_domain` / `reflection_data` |
| 添加答案 | `add_answer` | `reflection_domain` / `reflection_data` |
| 答案详情 | `answer_detail` | `reflection_domain` / `reflection_data` |
| AI 助手 | `copilot` | Chat API（独立）|
| 用户中心 | `user` | `user_domain` / `user_data` |
| 钱包 | `wallets` | `wallet_domain` / `wallet_data` |

---

## 常用命令

```bash
# 安装所有包依赖
make setup

# 全局代码生成
make codegen

# 指定包代码生成
make codegen PACKAGE=lt_app
make codegen PACKAGE=reflection_data

# 监听模式（开发时）
make watch
make watch PACKAGE=calendar

# 清理 + 重置
make reset

# 运行测试
cd packages/domain/reflection_domain && fvm dart test
cd packages/features/calendar && fvm flutter test
```

> 所有 Flutter/Dart CLI 命令必须加 `fvm` 前缀（如 `fvm flutter pub get`）

---

## 文档参考

- 完整产品与技术文档：`apps/lt_app/ReadME.md`
- 架构总览：`README.md`（项目根目录）
- API 文档：`docs/API/api.md`
- 技术理论文档：`docs/theories/`

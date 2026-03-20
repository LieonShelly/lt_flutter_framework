# Clean Architecture 分析：shared_data 方案

## 问题

当前方案：所有 Data 模块依赖 `shared_data` 包来获取共享的 ApiClient Provider。

```
reflection_data ─┐
user_data ───────┼─→ shared_data (Provider)
wallet_data ─────┘
```

**疑问**：Data 层的包之间相互依赖，是否违反了 Clean Architecture？

## Clean Architecture 原则回顾

### 依赖规则（Dependency Rule）

> 源代码依赖只能指向内层（更稳定的层）

```
┌─────────────────────────────────────┐
│ Presentation (UI/Feature)           │  最外层
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│ Domain (Entities, UseCases)         │  业务逻辑层
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│ Data (Repositories, DataSources)    │  数据层
└─────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────┐
│ Infrastructure (Network, DB, etc)   │  基础设施层
└─────────────────────────────────────┘
```

### 关键问题

**Data 层内部的包可以相互依赖吗？**

## 分析：当前方案

### 当前依赖关系

```
reflection_data ─┐
user_data ───────┼─→ shared_data ─→ Core (network)
wallet_data ─────┘
```

### 问题点

1. **同层依赖**：Data 层的包（reflection_data）依赖另一个 Data 层的包（shared_data）
2. **职责混淆**：shared_data 既是 Data 层，又提供基础设施（Provider）
3. **不符合依赖规则**：Data 层的包应该只依赖 Domain 和 Infrastructure，不应该依赖同层的其他包

## ❌ 当前方案的问题

### 1. 违反了层级隔离

```
Data Layer
├── reflection_data  ──┐
├── user_data  ────────┼─→ shared_data  ← 同层依赖！
└── wallet_data  ──────┘
```

Clean Architecture 要求：
- ✅ 外层可以依赖内层
- ❌ 同层不应该相互依赖

### 2. shared_data 的定位不清晰

`shared_data` 包含：
- Provider（依赖注入配置）← 这是 Presentation 层的职责
- API 配置（业务 URL）← 这是业务配置

这些内容不应该在 Data 层！

### 3. 测试和维护问题

- Data 层的包之间产生了耦合
- 修改 shared_data 会影响所有 Data 包
- 单元测试时需要 mock shared_data

## ✅ 正确的方案

### 方案 1：将 Provider 配置移到 App 层（推荐）

Provider 配置本质上是**依赖注入配置**，应该在最外层（App 层）完成。

#### 架构

```
┌─────────────────────────────────────────────────────────┐
│ App Layer (apps/lt_app)                                 │
│ - 创建和配置所有 Provider                                │
│ - 组装依赖关系                                           │
│ - lib/src/providers/app_providers.dart                  │
└─────────────────────────────────────────────────────────┘
              ↓ 使用
┌─────────────────────────────────────────────────────────┐
│ Data Layer (packages/data/*)                            │
│ - reflection_data (只提供 Repository 实现)              │
│ - user_data (只提供 Repository 实现)                    │
│ - wallet_data (只提供 Repository 实现)                  │
│ - 不包含 Provider 配置                                   │
└─────────────────────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer (packages/core/network)                      │
│ - 提供 ApiClient 抽象和实现                              │
│ - 提供 TokenStorage 抽象和实现                           │
└─────────────────────────────────────────────────────────┘
```

#### 实现

##### 1. App 层创建共享 Provider

```dart
// apps/lt_app/lib/src/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';

// ============================================================================
// 全局共享的基础设施 Provider
// ============================================================================

/// 全局 TokenStorage（单例）
final appTokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? SecureTokenStorage() : MockTokenStorage();
  },
  name: 'appTokenStorageProvider',
);

/// 主 API Client（单例）
final appApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(appTokenStorageProvider);
    return createApiClient(
      baseUrl: 'https://things.dvacode.tech',
      tokenStorage: tokenStorage,
    );
  },
  name: 'appApiClientProvider',
);

/// Chat API Client（单例）
final chatApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(appTokenStorageProvider);
    return createApiClient(
      baseUrl: NetworkConfig.getChatApiBaseUrl(),
      tokenStorage: tokenStorage,
    );
  },
  name: 'chatApiClientProvider',
);
```

##### 2. Data 层只提供工厂函数

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

/// 创建 ReflectionRemoteDataSource 的工厂函数
ReflectionRemoteDataSource createReflectionRemoteDataSource(
  ApiClientType apiClient,
) {
  return ReflectionRemoteDataSourceImpl(apiClient);
}

/// 创建 ReflectionRepository 的工厂函数
ReflectionRepository createReflectionRepository(
  ReflectionRemoteDataSource dataSource,
) {
  return ReflectionRepositoryImpl(dataSource);
}

// 或者提供 Provider，但接受外部的 ApiClient
Provider<ReflectionRemoteDataSource> reflectionRemoteDataSourceProvider(
  Provider<ApiClientType> apiClientProvider,
) {
  return Provider<ReflectionRemoteDataSource>((ref) {
    final apiClient = ref.watch(apiClientProvider);
    return createReflectionRemoteDataSource(apiClient);
  });
}

Provider<ReflectionRepository> reflectionRepositoryProvider(
  Provider<ReflectionRemoteDataSource> dataSourceProvider,
) {
  return Provider<ReflectionRepository>((ref) {
    final dataSource = ref.watch(dataSourceProvider);
    return createReflectionRepository(dataSource);
  });
}
```

##### 3. App 层组装依赖

```dart
// apps/lt_app/lib/src/providers/app_providers.dart (续)
import 'package:reflection_data/reflection_data.dart';
import 'package:user_data/user_data.dart';
import 'package:wallet_data/wallet_data.dart';

// ============================================================================
// Data Layer Providers（在 App 层组装）
// ============================================================================

// Reflection
final reflectionDataSourceProvider = 
  reflectionRemoteDataSourceProvider(appApiClientProvider);

final reflectionRepositoryProvider = 
  reflectionRepositoryProvider(reflectionDataSourceProvider);

// User
final userDataSourceProvider = 
  userRemoteDataSourceProvider(appApiClientProvider);

final userRepositoryProvider = 
  userRepositoryProvider(userDataSourceProvider);

// Wallet
final walletDataSourceProvider = 
  walletRemoteDataSourceProvider(appApiClientProvider);

final walletRepositoryProvider = 
  walletRepositoryProvider(walletDataSourceProvider);
```

### 方案 2：将 shared_data 移到 Core 层

如果确实需要一个共享的配置包，应该将其放在 Core 层。

#### 重命名和重新定位

```
packages/core/shared_infrastructure/
├── lib/
│   ├── shared_infrastructure.dart
│   └── src/
│       ├── config/
│       │   └── api_config.dart
│       └── providers/
│           └── infrastructure_providers.dart  # 只提供基础设施 Provider
└── pubspec.yaml
```

但这仍然不是最佳方案，因为 Provider 配置应该在 App 层。

## 推荐方案对比

| 方案 | 优点 | 缺点 | 符合 Clean Architecture |
|------|------|------|------------------------|
| **方案 1：App 层配置** | ✅ 完全符合 Clean Architecture<br>✅ 依赖注入在最外层<br>✅ Data 层纯净<br>✅ 易于测试 | 需要在 App 层组装 | ✅ 完全符合 |
| 方案 2：Core 层 shared | ✅ 集中管理基础设施<br>✅ Data 层依赖内层 | Provider 配置不应在 Core 层 | ⚠️ 部分符合 |
| 当前方案：Data 层 shared | ✅ 实现简单 | ❌ 同层依赖<br>❌ 职责不清<br>❌ 违反依赖规则 | ❌ 不符合 |

## 最佳实践：方案 1 详细实现

### 1. 删除 shared_data 包

```bash
rm -rf packages/data/shared_data
```

### 2. Data 层只提供实现，不包含 Provider

```dart
// packages/data/reflection_data/lib/reflection_data.dart
library reflection_data;

// 只导出实现类和工厂函数
export 'src/datasources/datasources.dart';
export 'src/repositories/repositories.dart';
export 'src/models/models.dart';

// 不导出 Provider！
```

### 3. App 层统一配置

```dart
// apps/lt_app/lib/src/di/dependency_injection.dart
class DependencyInjection {
  static List<Override> get overrides => [
    // 可以在这里 override Provider 用于测试
  ];
  
  static List<Provider> get providers => [
    appTokenStorageProvider,
    appApiClientProvider,
    chatApiClientProvider,
    // ... 所有业务 Provider
  ];
}

// apps/lt_app/lib/main.dart
void main() {
  runApp(
    ProviderScope(
      overrides: DependencyInjection.overrides,
      child: MyApp(),
    ),
  );
}
```

### 4. Feature 层使用

```dart
// packages/features/copilot/lib/src/chat_page.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Feature 层通过 ref 获取 Provider，不需要知道具体实现
class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> _handleSubmitted(String text) async {
    // 从 App 层注入的 Provider 获取
    final apiClient = ref.read(chatApiClientProvider);
    // ...
  }
}
```

但这里有个问题：Feature 层如何知道 `chatApiClientProvider` 的名字？

**解决方案**：在 App 层导出 Provider

```dart
// apps/lt_app/lib/src/providers/providers.dart
export 'app_providers.dart';

// Feature 层导入
import 'package:lt_app/src/providers/providers.dart';
```

## 总结

### 当前方案的问题 ❌

1. **违反依赖规则**：Data 层的包相互依赖
2. **职责不清**：shared_data 既是 Data 又是配置
3. **不符合 Clean Architecture**

### 正确的方案 ✅

**Provider 配置应该在 App 层（最外层）完成**

理由：
1. ✅ 依赖注入是应用组装的职责，属于最外层
2. ✅ Data 层保持纯净，只提供实现
3. ✅ 符合依赖规则：App → Data → Core
4. ✅ 易于测试：可以在 App 层 override Provider
5. ✅ 灵活性：不同的 App 可以有不同的配置

### 依赖关系

```
App Layer (lt_app)
  ├─ 创建 appApiClientProvider
  ├─ 创建 appTokenStorageProvider
  └─ 组装所有 Repository Provider
       ↓ 使用
Data Layer (reflection_data, user_data, wallet_data)
  └─ 只提供实现类和工厂函数
       ↓ 依赖
Core Layer (network)
  └─ 提供 ApiClient 和 TokenStorage 抽象
```

这才是符合 Clean Architecture 的正确方案！

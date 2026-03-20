# Network 层 Provider 依赖注入策略

## 问题描述

当前 `packages/core/network` 包中的 `network_provider.dart` 存在架构问题：

```dart
// ❌ 问题：Core 层包含业务配置
const String kBaseUrl = 'https://things.dvacode.tech';  // 业务 URL
final tokenStorageProvider = Provider<TokenStorage>(...);
final apiClientProvider = Provider<ApiClientType>(...);
final chatApiClientProvider = Provider<ApiClientType>(...);
```

**冲突点**：
- Core 层是 Infrastructure 层，应该只提供通用工具和抽象
- 业务相关的配置（URL、具体的 Provider）不应该在 Core 层
- 违反了 Clean Architecture 的依赖规则

## 解决方案

### 方案：Core 层只提供工厂函数，Data 层负责 Provider 配置

**核心思想**：
- Core 层：提供创建 ApiClient 的工厂函数（纯函数，无状态）
- Data 层：负责创建具体的 Provider，配置业务 URL

### 架构分层

```
┌─────────────────────────────────────────────────────────┐
│ Data Layer (packages/data/*)                            │
│ - 创建具体的 Provider                                    │
│ - 配置业务 URL                                           │
│ - 选择 TokenStorage 实现                                 │
│ - 导出给上层使用                                         │
└─────────────────────────────────────────────────────────┘
                          ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer (packages/core/network)                      │
│ - 提供 ApiClient 抽象                                    │
│ - 提供 HttpApiClient 实现                                │
│ - 提供 TokenStorage 抽象                                 │
│ - 提供工厂函数（createApiClient）                        │
│ - 不包含任何业务配置                                     │
└─────────────────────────────────────────────────────────┘
```

## 实现步骤

### 1. Core 层重构

#### 1.1 移除 network_provider.dart

删除 `packages/core/network/lib/network/network_provider.dart`

#### 1.2 创建工厂函数文件

创建 `packages/core/network/lib/network/api_client_factory.dart`：

```dart
import '../network_core/api_client.dart';
import '../network_core/token_storage.dart';
import 'http_api_client.dart';

/// 创建 ApiClient 的工厂函数
/// Core 层只提供创建逻辑，不包含业务配置
ApiClientType createApiClient({
  required String baseUrl,
  required TokenStorage tokenStorage,
}) {
  return HttpApiClient(
    baseUrl: baseUrl,
    tokenStorage: tokenStorage,
  );
}
```

#### 1.3 更新 Core 层导出

`packages/core/network/lib/network.dart`：

```dart
library network;

// Core abstractions
export 'network_core/api_client.dart';
export 'network_core/token_storage.dart';
export 'network_core/app_exception.dart';

// Implementations
export 'network/http_api_client.dart';
export 'network/mock_token_storage.dart';
export 'network/secure_token_storage.dart';

// Factory functions (无状态，纯函数)
export 'network/api_client_factory.dart';

// Config (可以保留，因为是通用配置)
export 'network/network_config.dart';
```

### 2. Data 层配置

每个 Data 包负责创建自己的 Provider。

#### 2.1 示例：reflection_data

`packages/data/reflection_data/lib/src/providers/network_providers.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

// 业务配置
const String _kReflectionApiBaseUrl = 'https://things.dvacode.tech';

// TokenStorage Provider
final reflectionTokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(), // 或 SecureTokenStorage()
);

// ApiClient Provider
final reflectionApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(reflectionTokenStorageProvider);
  return createApiClient(
    baseUrl: _kReflectionApiBaseUrl,
    tokenStorage: tokenStorage,
  );
});
```

#### 2.2 示例：user_data

`packages/data/user_data/lib/src/providers/network_providers.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

const String _kUserApiBaseUrl = 'https://things.dvacode.tech';

final userTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

final userApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(userTokenStorageProvider);
  return createApiClient(
    baseUrl: _kUserApiBaseUrl,
    tokenStorage: tokenStorage,
  );
});
```

#### 2.3 示例：多个 API 端点

如果一个 Data 包需要访问多个 API：

```dart
// Chat API
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(reflectionTokenStorageProvider);
  return createApiClient(
    baseUrl: NetworkConfig.getChatApiBaseUrl(),
    tokenStorage: tokenStorage,
  );
});

// Main API
final mainApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(reflectionTokenStorageProvider);
  return createApiClient(
    baseUrl: 'https://things.dvacode.tech',
    tokenStorage: tokenStorage,
  );
});
```

### 3. 共享 TokenStorage 的情况

如果多个 Data 包需要共享同一个 TokenStorage：

#### 方案 A：在 App 层统一配置（推荐）

`apps/lt_app/lib/src/providers/app_providers.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

// 全局共享的 TokenStorage
final appTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
```

然后在各个 Data 层引用：

```dart
// packages/data/reflection_data/lib/src/providers/network_providers.dart
import 'package:lt_app/src/providers/app_providers.dart';

final reflectionApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(appTokenStorageProvider);
  return createApiClient(
    baseUrl: 'https://things.dvacode.tech',
    tokenStorage: tokenStorage,
  );
});
```

#### 方案 B：创建共享的 Data 包

创建 `packages/data/shared_data` 包：

```dart
// packages/data/shared_data/lib/src/providers/shared_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';

final sharedTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
```

### 4. 使用示例

#### 4.1 在 Repository 中使用

```dart
// packages/data/reflection_data/lib/src/repositories/reflection_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_providers.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  final ApiClientType _apiClient;

  ReflectionRepositoryImpl(this._apiClient);

  @override
  Future<List<Reflection>> getReflections() async {
    final response = await _apiClient.get('/reflections');
    // ...
  }
}

// Provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final apiClient = ref.watch(reflectionApiClientProvider);
  return ReflectionRepositoryImpl(apiClient);
});
```

#### 4.2 在 DataSource 中使用

```dart
// packages/data/reflection_data/lib/src/datasources/remote/reflection_remote_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/network_providers.dart';

class ReflectionRemoteDataSource {
  final ApiClientType _apiClient;

  ReflectionRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> fetchReflections() async {
    return await _apiClient.get('/reflections');
  }
}

// Provider
final reflectionRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(reflectionApiClientProvider);
  return ReflectionRemoteDataSource(apiClient);
});
```

## 优势

### ✅ 符合 Clean Architecture

- Core 层纯净，只包含基础设施代码
- Data 层负责业务配置
- 依赖方向正确：Data → Core

### ✅ 灵活性

- 每个 Data 包可以配置不同的 URL
- 可以为不同的 API 创建不同的 ApiClient
- 易于切换 TokenStorage 实现（Mock/Secure）

### ✅ 可测试性

- Core 层的工厂函数是纯函数，易于测试
- Data 层的 Provider 可以轻松 override
- 可以为测试注入 Mock ApiClient

### ✅ 可维护性

- 职责清晰：Core 提供工具，Data 配置业务
- 业务配置集中在 Data 层
- 修改 URL 不需要改动 Core 层

## 迁移检查清单

- [ ] 删除 `packages/core/network/lib/network/network_provider.dart`
- [ ] 创建 `packages/core/network/lib/network/api_client_factory.dart`
- [ ] 更新 `packages/core/network/lib/network.dart` 导出
- [ ] 在 `reflection_data` 创建 `network_providers.dart`
- [ ] 在 `user_data` 创建 `network_providers.dart`
- [ ] 在 `wallet_data` 创建 `network_providers.dart`
- [ ] 更新所有 Repository 和 DataSource 的依赖
- [ ] 更新 App 层的 Provider 引用
- [ ] 运行测试确保一切正常

## 注意事项

### NetworkConfig 的处理

`NetworkConfig` 包含代理配置和平台相关的 URL 获取，这些是通用工具，可以保留在 Core 层：

```dart
// ✅ 可以保留在 Core 层
class NetworkConfig {
  static String getProxyConfig(Uri uri) { ... }
  static String getChatApiBaseUrl() { ... }  // 平台相关的通用逻辑
}
```

但具体使用时，在 Data 层决定是否使用：

```dart
// Data 层决定使用哪个 URL
final chatApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return createApiClient(
    baseUrl: NetworkConfig.getChatApiBaseUrl(),  // 使用通用工具
    tokenStorage: tokenStorage,
  );
});
```

## 总结

通过这个重构：

1. **Core 层**：只提供工厂函数和抽象，不包含业务配置
2. **Data 层**：负责创建 Provider，配置业务 URL
3. **清晰的职责分离**：Infrastructure vs Business Configuration
4. **符合 Clean Architecture 原则**

这样的架构更加清晰、灵活、可维护！

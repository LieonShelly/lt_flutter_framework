# 共享 Network Provider 策略

## 问题

当前方案中，每个 Data 模块都创建了自己的 ApiClient 和 TokenStorage：

```dart
// ❌ 问题：多个实例
reflection_data: reflectionApiClientProvider + reflectionTokenStorageProvider
user_data: userApiClientProvider + userTokenStorageProvider
wallet_data: walletApiClientProvider + walletTokenStorageProvider
```

**问题**：
- ApiClient 被多次创建
- TokenStorage 被多次创建
- Token 无法在模块间共享
- 资源浪费

## 解决方案

创建一个共享的 Data 包 `shared_data`，统一管理 Network Provider。

### 方案架构

```
┌─────────────────────────────────────────────────────────┐
│ Data Layer (packages/data/*)                            │
│ - reflection_data                                       │
│ - user_data                                             │
│ - wallet_data                                           │
│   ↓ 依赖                                                │
│ - shared_data (共享的 Network Provider)                 │
└─────────────────────────────────────────────────────────┘
                          ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer (packages/core/network)                      │
│ - 提供 ApiClient 抽象和实现                              │
│ - 提供 TokenStorage 抽象和实现                           │
│ - 提供工厂函数                                           │
└─────────────────────────────────────────────────────────┘
```

## 实现步骤

### 1. 创建 shared_data 包

```bash
cd packages/data
dart create --template=package shared_data
```

### 2. shared_data 包结构

```
packages/data/shared_data/
├── lib/
│   ├── shared_data.dart
│   └── src/
│       ├── config/
│       │   └── api_config.dart          # API 配置
│       └── providers/
│           └── network_providers.dart    # 共享的 Network Provider
├── pubspec.yaml
└── README.md
```

### 3. 配置文件

#### pubspec.yaml

```yaml
name: shared_data
description: Shared data layer utilities and providers
publish_to: none
resolution: workspace

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.1.0
  network:
    path: ../../core/network
```

#### lib/shared_data.dart

```dart
library shared_data;

export 'src/config/api_config.dart';
export 'src/providers/network_providers.dart';
```

### 4. API 配置

#### lib/src/config/api_config.dart

```dart
/// API 配置
/// 
/// 集中管理所有 API 的 Base URL
class ApiConfig {
  ApiConfig._();

  /// 主 API Base URL
  static const String mainApiBaseUrl = 'https://things.dvacode.tech';

  /// Chat API Base URL (使用 NetworkConfig 的平台相关逻辑)
  /// 在 Provider 中动态获取
  
  /// 开发环境 API Base URL
  static const String devApiBaseUrl = 'https://dev.things.dvacode.tech';
  
  /// 生产环境 API Base URL
  static const String prodApiBaseUrl = 'https://things.dvacode.tech';
  
  /// 当前使用的 Base URL
  static String get currentBaseUrl {
    // 可以根据环境变量或配置切换
    return mainApiBaseUrl;
  }
}
```

### 5. 共享的 Network Provider

#### lib/src/providers/network_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network/network.dart';
import '../config/api_config.dart';

// ============================================================================
// Shared TokenStorage Provider
// ============================================================================

/// 全局共享的 TokenStorage Provider
/// 
/// 所有 Data 模块共享同一个 TokenStorage 实例
/// 确保 Token 在整个应用中保持一致
/// 
/// 开发环境使用 MockTokenStorage
/// 生产环境使用 SecureTokenStorage
final sharedTokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    // TODO: 根据环境切换
    // return SecureTokenStorage();  // 生产环境
    return MockTokenStorage();       // 开发环境
  },
  name: 'sharedTokenStorageProvider',
);

// ============================================================================
// Shared ApiClient Providers
// ============================================================================

/// 主 API Client Provider
/// 
/// 用于访问主要的业务 API
/// 所有需要访问主 API 的 Data 模块共享此实例
final sharedApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(sharedTokenStorageProvider);
    return createApiClient(
      baseUrl: ApiConfig.currentBaseUrl,
      tokenStorage: tokenStorage,
    );
  },
  name: 'sharedApiClientProvider',
);

/// Chat API Client Provider
/// 
/// 用于访问 Chat API
/// 使用平台相关的 URL 配置
final chatApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(sharedTokenStorageProvider);
    return createApiClient(
      baseUrl: NetworkConfig.getChatApiBaseUrl(),
      tokenStorage: tokenStorage,
    );
  },
  name: 'chatApiClientProvider',
);

// ============================================================================
// 扩展：如果需要访问其他 API
// ============================================================================

/// 示例：第三方 API Client
/// 
/// 如果需要访问不同的 API 端点，可以创建新的 Provider
/// 
/// ```dart
/// final thirdPartyApiClientProvider = Provider<ApiClientType>(
///   (ref) {
///     final tokenStorage = ref.watch(sharedTokenStorageProvider);
///     return createApiClient(
///       baseUrl: 'https://api.thirdparty.com',
///       tokenStorage: tokenStorage,
///     );
///   },
/// );
/// ```
```

### 6. 更新 Data 模块

#### reflection_data

删除 `lib/src/providers/network_providers.dart`，直接使用 shared_data：

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:shared_data/shared_data.dart';  // 使用共享的 Provider
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(sharedApiClientProvider);  // 使用共享的
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});
```

#### user_data

```dart
// packages/data/user_data/lib/src/providers/user_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_domain/user_domain.dart';
import 'package:shared_data/shared_data.dart';  // 使用共享的 Provider
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(sharedApiClientProvider);  // 使用共享的
  return UserRemoteDataSourceImpl(apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});
```

#### wallet_data

```dart
// packages/data/wallet_data/lib/src/providers/wallet_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_domain/wallet_domain.dart';
import 'package:shared_data/shared_data.dart';  // 使用共享的 Provider
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(sharedApiClientProvider);  // 使用共享的
  return WalletRemoteDataSourceImpl(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
});
```

### 7. 更新 pubspec.yaml 依赖

#### reflection_data/pubspec.yaml

```yaml
dependencies:
  shared_data:
    path: ../shared_data
```

#### user_data/pubspec.yaml

```yaml
dependencies:
  shared_data:
    path: ../shared_data
```

#### wallet_data/pubspec.yaml

```yaml
dependencies:
  shared_data:
    path: ../shared_data
```

### 8. 更新 Feature 层

#### copilot

```dart
// packages/features/copilot/lib/src/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:shared_data/shared_data.dart';  // 直接使用 shared_data

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> _handleSubmitted(String text) async {
    // ...
    final apiClient = ref.read(chatApiClientProvider);  // 使用共享的
    final response = await apiClient.post('/chat', data: {...});
    // ...
  }
}
```

### 9. 更新 workspace 配置

#### pubspec.yaml (root)

```yaml
workspace:
  # ... 其他包
  - packages/data/shared_data  # 添加 shared_data
```

## 优势

### ✅ 单例模式
- ApiClient 只创建一次
- TokenStorage 只创建一次
- Token 在所有模块间共享

### ✅ 集中管理
- API 配置集中在一个地方
- 易于切换环境（dev/staging/prod）
- 统一的 Token 管理策略

### ✅ 依赖清晰
```
reflection_data ─┐
user_data ───────┼─→ shared_data ─→ network (core)
wallet_data ─────┘
```

### ✅ 易于维护
- 修改 API URL 只需改一处
- 切换 TokenStorage 实现只需改一处
- 添加新的 API Client 很简单

## 使用示例

### 在 Repository 中使用

```dart
// 所有 Data 模块都使用相同的 ApiClient
final reflectionRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(sharedApiClientProvider);
  // ...
});

final userRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(sharedApiClientProvider);
  // ...
});
```

### 在 Feature 中使用

```dart
// Feature 层可以直接使用 shared_data 的 Provider
import 'package:shared_data/shared_data.dart';

final apiClient = ref.read(sharedApiClientProvider);
```

## 环境配置

### 开发环境 vs 生产环境

```dart
// lib/src/providers/network_providers.dart
final sharedTokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    
    if (isProduction) {
      return SecureTokenStorage();  // 生产环境
    } else {
      return MockTokenStorage();    // 开发环境
    }
  },
);
```

### 多环境 API URL

```dart
// lib/src/config/api_config.dart
enum Environment { dev, staging, prod }

class ApiConfig {
  static Environment current = Environment.dev;
  
  static String get currentBaseUrl {
    switch (current) {
      case Environment.dev:
        return 'https://dev.things.dvacode.tech';
      case Environment.staging:
        return 'https://staging.things.dvacode.tech';
      case Environment.prod:
        return 'https://things.dvacode.tech';
    }
  }
}
```

## 迁移步骤

1. ✅ 创建 `packages/data/shared_data` 包
2. ✅ 创建 API 配置文件
3. ✅ 创建共享的 Network Provider
4. ✅ 删除各 Data 模块的 network_providers.dart
5. ✅ 更新各 Data 模块的依赖
6. ✅ 更新各 Data 模块的 Provider 引用
7. ✅ 更新 Feature 层的引用
8. ✅ 更新 workspace 配置
9. ✅ 运行测试

## 总结

通过创建 `shared_data` 包：

1. **单例共享**：ApiClient 和 TokenStorage 只创建一次
2. **集中管理**：API 配置和 Provider 集中管理
3. **架构清晰**：依赖关系明确，符合 DRY 原则
4. **易于维护**：修改配置只需一处

这是更优的架构方案！

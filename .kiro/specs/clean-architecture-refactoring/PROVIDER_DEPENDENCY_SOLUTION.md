# Provider 依赖问题的解决方案

## 问题

如果把 Provider 配置放在 App 层，Feature 层要访问 Provider 时，就需要依赖 App 层：

```dart
// ❌ 问题：Feature 依赖 App
packages/features/add_answer
  └─ 依赖 apps/lt_app (获取 Provider)
```

这违反了依赖规则：**内层不应该依赖外层**！

## 核心矛盾

```
┌─────────────────────────────────────┐
│ App Layer                           │  ← Feature 不能依赖这里
│ - 创建 Provider                     │
└─────────────────────────────────────┘
              ↑ 需要访问？
┌─────────────────────────────────────┐
│ Feature Layer                       │
│ - 需要使用 Provider                 │
└─────────────────────────────────────┘
```

## 解决方案对比

### 方案 1：Data 层提供 Provider 定义（推荐）✅

**核心思想**：
- Data 层定义 Provider（但不配置具体实现）
- App 层通过 override 提供具体实现
- Feature 层使用 Data 层的 Provider

#### 架构

```
┌─────────────────────────────────────────────────────────┐
│ App Layer                                               │
│ - 通过 ProviderScope.overrides 配置具体实现            │
│ - 创建 ApiClient 实例                                   │
└─────────────────────────────────────────────────────────┘
              ↓ override
┌─────────────────────────────────────────────────────────┐
│ Feature Layer                                           │
│ - 使用 Data 层定义的 Provider                           │
└─────────────────────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Data Layer                                              │
│ - 定义 Provider（抽象）                                 │
│ - 提供默认实现（可选）                                  │
└─────────────────────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer                                              │
│ - 提供 ApiClient 抽象                                   │
└─────────────────────────────────────────────────────────┘
```

#### 实现细节

##### 1. Data 层定义 Provider（抽象）

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// Provider 定义（抽象，等待 App 层 override）
// ============================================================================

/// ApiClient Provider（抽象）
/// 
/// 这个 Provider 在 Data 层定义，但具体实例由 App 层通过 override 提供
/// 这样 Feature 层可以依赖 Data 层，而不需要依赖 App 层
final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in App layer',
  ),
  name: 'apiClientProvider',
);

/// Chat ApiClient Provider（抽象）
final chatApiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'chatApiClientProvider must be overridden in App layer',
  ),
  name: 'chatApiClientProvider',
);

// ============================================================================
// 业务 Provider（使用抽象的 ApiClient）
// ============================================================================

final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);  // 使用抽象 Provider
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
  name: 'reflectionRemoteDataSourceProvider',
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (ref) {
    final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
    return ReflectionRepositoryImpl(dataSource);
  },
  name: 'reflectionRepositoryProvider',
);
```

##### 2. App 层提供具体实现（override）

```dart
// apps/lt_app/lib/src/di/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:reflection_data/reflection_data.dart';
import 'package:user_data/user_data.dart';
import 'package:wallet_data/wallet_data.dart';

// ============================================================================
// App 层的具体实现
// ============================================================================

/// TokenStorage 实例（App 层创建）
final _tokenStorage = Provider<TokenStorage>(
  (ref) {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? SecureTokenStorage() : MockTokenStorage();
  },
);

/// 主 ApiClient 实例（App 层创建）
final _mainApiClient = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(_tokenStorage);
    return createApiClient(
      baseUrl: 'https://things.dvacode.tech',
      tokenStorage: tokenStorage,
    );
  },
);

/// Chat ApiClient 实例（App 层创建）
final _chatApiClient = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(_tokenStorage);
    return createApiClient(
      baseUrl: NetworkConfig.getChatApiBaseUrl(),
      tokenStorage: tokenStorage,
    );
  },
);

// ============================================================================
// Provider Overrides（提供给 ProviderScope）
// ============================================================================

class AppProviders {
  static List<Override> get overrides => [
    // Override Data 层定义的抽象 Provider
    apiClientProvider.overrideWithProvider(_mainApiClient),
    chatApiClientProvider.overrideWithProvider(_chatApiClient),
  ];
}
```

##### 3. App 入口配置

```dart
// apps/lt_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/di/app_providers.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: AppProviders.overrides,  // 注入具体实现
      child: const MyApp(),
    ),
  );
}
```

##### 4. Feature 层使用

```dart
// packages/features/add_answer/lib/src/add_answer_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_data/reflection_data.dart';  // 依赖 Data 层

@riverpod
class AddAnswerController extends _$AddAnswerController {
  @override
  FutureOr<void> build() {}

  Future<void> submitAnswer(String answer) async {
    // 使用 Data 层定义的 Provider
    final repository = ref.read(reflectionRepositoryProvider);
    await repository.submitAnswer(answer);
  }
}
```

#### 优势

✅ **符合依赖规则**
```
Feature → Data → Core
App → Data (通过 override)
```

✅ **职责清晰**
- Data 层：定义 Provider 接口
- App 层：提供具体实现
- Feature 层：使用 Provider

✅ **易于测试**
```dart
testWidgets('test feature', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
      child: MyWidget(),
    ),
  );
});
```

✅ **灵活性**
- 不同的 App 可以提供不同的实现
- 测试时可以轻松 mock

### 方案 2：使用 Riverpod 的 Family + Parameter ⚠️

通过参数传递依赖，但这会让代码变得复杂。

```dart
// Data 层
final reflectionRepositoryProvider = Provider.family<ReflectionRepository, ApiClientType>(
  (ref, apiClient) {
    final dataSource = ReflectionRemoteDataSourceImpl(apiClient);
    return ReflectionRepositoryImpl(dataSource);
  },
);

// Feature 层使用
final repository = ref.read(reflectionRepositoryProvider(apiClient));
```

❌ 问题：需要在每个地方传递 apiClient，代码冗余。

### 方案 3：保持 shared_data，但改名为 app_infrastructure ⚠️

将 `shared_data` 重命名为 `app_infrastructure`，明确其作为应用基础设施的定位。

```
packages/app_infrastructure/  # 应用级基础设施
├── lib/
│   └── src/
│       └── providers/
│           └── infrastructure_providers.dart
```

但这仍然是 Data 层的包依赖另一个 Data 层的包，不够优雅。

### 方案 4：使用 Service Locator 模式 ❌

使用 GetIt 等 Service Locator。

```dart
// App 层
GetIt.instance.registerSingleton<ApiClientType>(apiClient);

// Feature 层
final apiClient = GetIt.instance<ApiClientType>();
```

❌ 问题：
- 失去了 Riverpod 的响应式特性
- 失去了编译时类型检查
- 不推荐在 Flutter 中使用

## 推荐方案详细对比

| 方案 | 依赖方向 | 职责清晰度 | 易用性 | 测试性 | 推荐度 |
|------|---------|-----------|--------|--------|--------|
| **方案 1：Data 层定义 + App 层 override** | ✅ 正确 | ✅ 清晰 | ✅ 简单 | ✅ 容易 | ⭐⭐⭐⭐⭐ |
| 方案 2：Family + Parameter | ✅ 正确 | ⚠️ 一般 | ❌ 复杂 | ⚠️ 一般 | ⭐⭐ |
| 方案 3：app_infrastructure | ❌ 同层依赖 | ⚠️ 模糊 | ✅ 简单 | ✅ 容易 | ⭐⭐⭐ |
| 方案 4：Service Locator | ⚠️ 绕过 | ❌ 不清晰 | ⚠️ 一般 | ❌ 困难 | ⭐ |

## 方案 1 的完整示例

### 目录结构

```
packages/data/reflection_data/
├── lib/
│   ├── reflection_data.dart
│   └── src/
│       ├── providers/
│       │   └── reflection_providers.dart  # 定义抽象 Provider
│       ├── datasources/
│       └── repositories/

apps/lt_app/
├── lib/
│   ├── main.dart
│   └── src/
│       └── di/
│           └── app_providers.dart  # 提供具体实现
```

### 代码示例

#### reflection_data/lib/src/providers/reflection_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// 抽象 Provider（等待 App 层 override）
// ============================================================================

/// 全局 ApiClient Provider
/// 
/// 这是一个抽象 Provider，必须在 App 层通过 override 提供具体实现
/// 
/// Example:
/// ```dart
/// ProviderScope(
///   overrides: [
///     apiClientProvider.overrideWithProvider(myApiClientProvider),
///   ],
///   child: MyApp(),
/// )
/// ```
final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in App layer. '
    'Add it to ProviderScope.overrides in main.dart',
  ),
  name: 'apiClientProvider',
);

// ============================================================================
// 业务 Provider
// ============================================================================

final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (ref) {
    final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
    return ReflectionRepositoryImpl(dataSource);
  },
);
```

#### apps/lt_app/lib/src/di/app_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:reflection_data/reflection_data.dart' as reflection;
import 'package:user_data/user_data.dart' as user;
import 'package:wallet_data/wallet_data.dart' as wallet;

// ============================================================================
// App 层的基础设施 Provider
// ============================================================================

final _tokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? SecureTokenStorage() : MockTokenStorage();
  },
);

final _mainApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(_tokenStorageProvider);
    return createApiClient(
      baseUrl: 'https://things.dvacode.tech',
      tokenStorage: tokenStorage,
    );
  },
);

final _chatApiClientProvider = Provider<ApiClientType>(
  (ref) {
    final tokenStorage = ref.watch(_tokenStorageProvider);
    return createApiClient(
      baseUrl: NetworkConfig.getChatApiBaseUrl(),
      tokenStorage: tokenStorage,
    );
  },
);

// ============================================================================
// Provider Overrides
// ============================================================================

class AppProviders {
  /// 所有需要 override 的 Provider
  static List<Override> get overrides => [
    // Reflection Data
    reflection.apiClientProvider.overrideWithProvider(_mainApiClientProvider),
    reflection.chatApiClientProvider.overrideWithProvider(_chatApiClientProvider),
    
    // User Data
    user.apiClientProvider.overrideWithProvider(_mainApiClientProvider),
    
    // Wallet Data
    wallet.apiClientProvider.overrideWithProvider(_mainApiClientProvider),
  ];
}
```

#### apps/lt_app/lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/di/app_providers.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: AppProviders.overrides,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LittleThings',
      home: const HomePage(),
    );
  }
}
```

## 总结

### 推荐方案：Data 层定义 + App 层 override ✅

**核心思想**：
1. Data 层定义抽象 Provider（接口）
2. App 层通过 override 提供具体实现
3. Feature 层使用 Data 层的 Provider

**优势**：
- ✅ 符合依赖规则：Feature → Data → Core
- ✅ 职责清晰：定义和实现分离
- ✅ 易于测试：可以轻松 override
- ✅ 灵活性高：不同 App 可以有不同实现

**依赖关系**：
```
App Layer
  └─ override Data 层的抽象 Provider
       ↑
Feature Layer
  └─ 使用 Data 层的 Provider
       ↑
Data Layer
  └─ 定义抽象 Provider
       ↑
Core Layer
  └─ 提供基础设施
```

这是最符合 Clean Architecture 的方案！

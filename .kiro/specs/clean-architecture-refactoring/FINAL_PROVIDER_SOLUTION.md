# 最终 Provider 解决方案 ✅

## 实施完成

已成功实施"Data 层定义 + App 层 Override"方案，完全符合 Clean Architecture 原则。

## 方案概述

### 核心思想

1. **Data 层**：定义抽象 Provider（接口）
2. **App 层**：通过 `ProviderScope.overrides` 提供具体实现
3. **Feature 层**：使用 Data 层定义的 Provider

### 架构图

```
┌─────────────────────────────────────────────────────────┐
│ App Layer (apps/lt_app)                                 │
│ - lib/src/di/app_providers.dart                         │
│ - 创建 _mainApiClientProvider (单例)                    │
│ - 创建 _chatApiClientProvider (单例)                    │
│ - 通过 override 注入到 Data 层                          │
└─────────────────────────────────────────────────────────┘
              ↓ override
┌─────────────────────────────────────────────────────────┐
│ Feature Layer (packages/features/*)                     │
│ - copilot: 使用 chatApiClientProvider                   │
│ - add_answer: 使用 reflectionRepositoryProvider        │
│ - 依赖 Data 层的 Provider                               │
└─────────────────────────────────────────────────────────┘
              ↓ 使用
┌─────────────────────────────────────────────────────────┐
│ Data Layer (packages/data/*)                            │
│ - reflection_data: 定义 apiClientProvider (抽象)       │
│ - user_data: 定义 apiClientProvider (抽象)             │
│ - wallet_data: 定义 apiClientProvider (抽象)           │
│ - 提供业务 Provider (使用抽象 ApiClient)                │
└─────────────────────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer (packages/core/network)                      │
│ - 提供 ApiClient 抽象和实现                              │
│ - 提供 TokenStorage 抽象和实现                           │
│ - 提供工厂函数 createApiClient()                        │
└─────────────────────────────────────────────────────────┘
```

## 完成的工作

### 1. Data 层 - 定义抽象 Provider ✅

#### reflection_data
```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart

// 抽象 Provider（等待 App 层 override）
final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in App layer',
  ),
);

final chatApiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'chatApiClientProvider must be overridden in App layer',
  ),
);

// 业务 Provider（使用抽象）
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

#### user_data
```dart
// packages/data/user_data/lib/src/providers/user_providers.dart

final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError('...'),
);

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return UserRemoteDataSourceImpl(apiClient);
  },
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) {
    final dataSource = ref.watch(userRemoteDataSourceProvider);
    return UserRepositoryImpl(dataSource);
  },
);
```

#### wallet_data
```dart
// packages/data/wallet_data/lib/src/providers/wallet_providers.dart

final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError('...'),
);

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return WalletRemoteDataSourceImpl(apiClient);
  },
);

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) {
    final dataSource = ref.watch(walletRemoteDataSourceProvider);
    return WalletRepositoryImpl(dataSource);
  },
);
```

### 2. App 层 - 提供具体实现 ✅

```dart
// apps/lt_app/lib/src/di/app_providers.dart

// 基础设施 Provider（App 层创建，单例）
final _tokenStorageProvider = Provider<TokenStorage>((ref) {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  return isProduction ? SecureTokenStorage() : MockTokenStorage();
});

final _mainApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  return createApiClient(
    baseUrl: 'https://things.dvacode.tech',
    tokenStorage: tokenStorage,
  );
});

final _chatApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  return createApiClient(
    baseUrl: NetworkConfig.getChatApiBaseUrl(),
    tokenStorage: tokenStorage,
  );
});

// Provider Overrides
class AppProviders {
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

```dart
// apps/lt_app/lib/main.dart

void main() {
  runApp(
    ProviderScope(
      overrides: AppProviders.overrides,  // 注入具体实现
      child: const MyApp(),
    ),
  );
}
```

### 3. Feature 层 - 使用 Data 层 Provider ✅

```dart
// packages/features/copilot/lib/src/chat_page.dart
import 'package:reflection_data/reflection_data.dart';

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> _handleSubmitted(String text) async {
    // 使用 Data 层定义的 Provider
    final apiClient = ref.read(chatApiClientProvider);
    final response = await apiClient.post('/chat', data: {...});
  }
}
```

```dart
// packages/features/add_answer/lib/src/add_answer_controller.dart
import 'package:reflection_data/reflection_data.dart';

@riverpod
class AddAnswerController extends _$AddAnswerController {
  Future<void> submitAnswer(String answer) async {
    // 使用 Data 层定义的 Provider
    final repository = ref.read(reflectionRepositoryProvider);
    await repository.submitAnswer(answer);
  }
}
```

### 4. 清理工作 ✅

- ✅ 删除 `packages/data/shared_data` 包
- ✅ 更新所有 Data 包的 pubspec.yaml（移除 shared_data 依赖）
- ✅ 更新 copilot 的 pubspec.yaml（使用 reflection_data）
- ✅ 从 workspace 配置中移除 shared_data
- ✅ 运行 `pub get` 验证成功

## 依赖关系

### 包依赖
```
Feature Layer
  └─ 依赖 Data Layer (使用定义的 Provider)

Data Layer
  └─ 依赖 Core Layer (使用 ApiClient 抽象)

App Layer
  └─ 依赖 Data Layer (通过 override 注入实现)
  └─ 依赖 Core Layer (创建 ApiClient 实例)
```

### Provider 流程
```
1. Data 层定义抽象 Provider
   ↓
2. App 层创建具体实现
   ↓
3. App 层通过 override 注入
   ↓
4. Feature 层使用 Data 层的 Provider
   ↓
5. 运行时获得 App 层注入的实例
```

## 优势

### ✅ 符合 Clean Architecture

**依赖规则**：
- Feature → Data → Core ✅
- App → Data (通过 override) ✅
- 没有依赖反转 ✅
- 没有同层依赖 ✅

### ✅ 单例共享

- ApiClient 只创建一次（在 App 层）
- TokenStorage 只创建一次（在 App 层）
- 所有模块共享同一个实例
- 节省资源，Token 统一管理

### ✅ 职责清晰

| 层级 | 职责 |
|------|------|
| Core | 提供抽象和实现 |
| Data | 定义 Provider 接口 |
| App | 提供具体实现和配置 |
| Feature | 使用 Provider |

### ✅ 易于测试

```dart
testWidgets('test feature', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // 轻松 override 为 Mock
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
      child: MyWidget(),
    ),
  );
});
```

### ✅ 灵活性高

- 不同的 App 可以提供不同的实现
- 可以根据环境切换实现（dev/prod）
- 易于添加新的 API Client

## 使用示例

### 在 Data 层定义新的 Provider

```dart
// packages/data/new_data/lib/src/providers/new_providers.dart

// 1. 定义抽象 Provider
final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError('Must be overridden in App layer'),
);

// 2. 使用抽象 Provider
final newRepositoryProvider = Provider<NewRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // ...
});
```

### 在 App 层注入实现

```dart
// apps/lt_app/lib/src/di/app_providers.dart

class AppProviders {
  static List<Override> get overrides => [
    // ... 其他 overrides
    
    // 添加新的 override
    new_data.apiClientProvider.overrideWithProvider(_mainApiClientProvider),
  ];
}
```

### 在 Feature 层使用

```dart
// packages/features/new_feature/lib/src/new_page.dart
import 'package:new_data/new_data.dart';

final repository = ref.read(newRepositoryProvider);
```

## 环境配置

### 切换 TokenStorage

```dart
// apps/lt_app/lib/src/di/app_providers.dart

final _tokenStorageProvider = Provider<TokenStorage>((ref) {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  
  if (isProduction) {
    return SecureTokenStorage();  // 生产环境
  } else {
    return MockTokenStorage();    // 开发环境
  }
});
```

### 切换 API URL

```dart
// apps/lt_app/lib/src/di/app_providers.dart

final _mainApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  final baseUrl = env == 'dev' 
    ? 'https://dev.things.dvacode.tech'
    : 'https://things.dvacode.tech';
  
  return createApiClient(
    baseUrl: baseUrl,
    tokenStorage: tokenStorage,
  );
});
```

## 总结

### 问题解决 ✅

1. ❌ 原问题：Core 层包含业务配置
   ✅ 解决：Core 层只提供工厂函数

2. ❌ 原问题：Data 层包相互依赖（shared_data）
   ✅ 解决：删除 shared_data，Data 层只定义抽象

3. ❌ 原问题：Feature 依赖 App（依赖反转）
   ✅ 解决：Feature 依赖 Data，App 通过 override 注入

### 最终架构 ✅

```
App Layer (配置和组装)
  ↓ override
Data Layer (定义接口)
  ↑ 使用
Feature Layer (业务逻辑)

所有层都依赖 Core Layer (基础设施)
```

**完全符合 Clean Architecture！**

### 关键文件

- `apps/lt_app/lib/src/di/app_providers.dart` - App 层配置
- `apps/lt_app/lib/main.dart` - 注入 overrides
- `packages/data/*/lib/src/providers/*_providers.dart` - Data 层定义
- `packages/features/*/lib/src/*.dart` - Feature 层使用

## 相关文档

- [Provider Dependency Solution](./PROVIDER_DEPENDENCY_SOLUTION.md)
- [Clean Architecture Analysis](./CLEAN_ARCHITECTURE_ANALYSIS.md)
- [Network Layer Provider Strategy](./NETWORK_LAYER_PROVIDER_STRATEGY.md)

---

**实施完成！架构清晰、符合规范、易于维护！** ✅

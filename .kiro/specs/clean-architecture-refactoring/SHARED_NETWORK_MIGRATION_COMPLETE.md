# 共享 Network Provider 迁移完成 ✅

## 问题解决

原问题：每个 Data 模块都创建了自己的 ApiClient 和 TokenStorage，导致：
- ❌ ApiClient 被多次创建
- ❌ TokenStorage 被多次创建  
- ❌ Token 无法在模块间共享
- ❌ 资源浪费

## 解决方案

创建 `shared_data` 包，统一管理所有 Data 模块的 Network Provider。

## 完成的工作

### 1. 创建 shared_data 包 ✅

```
packages/data/shared_data/
├── lib/
│   ├── shared_data.dart
│   └── src/
│       ├── config/
│       │   └── api_config.dart          # API 配置
│       └── providers/
│           └── network_providers.dart    # 共享的 Network Provider
└── pubspec.yaml
```

### 2. 核心文件

#### api_config.dart
```dart
class ApiConfig {
  static const String mainApiBaseUrl = 'https://things.dvacode.tech';
  static String get currentBaseUrl => mainApiBaseUrl;
}
```

#### network_providers.dart
```dart
// 全局共享的 TokenStorage（单例）
final sharedTokenStorageProvider = Provider<TokenStorage>(...);

// 全局共享的 ApiClient（单例）
final sharedApiClientProvider = Provider<ApiClientType>(...);

// Chat API Client
final chatApiClientProvider = Provider<ApiClientType>(...);
```

### 3. 更新的包

#### reflection_data ✅
- ❌ 删除 `lib/src/providers/network_providers.dart`
- ✅ 更新 `reflection_providers.dart` 使用 `sharedApiClientProvider`
- ✅ 更新 `pubspec.yaml` 添加 `shared_data` 依赖
- ✅ 移除 `lt_network` 直接依赖

#### user_data ✅
- ❌ 删除 `lib/src/providers/network_providers.dart`
- ✅ 更新 `user_providers.dart` 使用 `sharedApiClientProvider`
- ✅ 更新 `pubspec.yaml` 添加 `shared_data` 依赖
- ✅ 移除 `lt_network` 直接依赖

#### wallet_data ✅
- ❌ 删除 `lib/src/providers/network_providers.dart`
- ✅ 更新 `wallet_providers.dart` 使用 `sharedApiClientProvider`
- ✅ 更新 `pubspec.yaml` 添加 `shared_data` 依赖
- ✅ 移除 `lt_network` 直接依赖

#### copilot (Feature) ✅
- ✅ 更新 `chat_page.dart` 从 `shared_data` 导入
- ✅ 更新 `pubspec.yaml` 添加 `shared_data` 依赖
- ✅ 移除 `lt_network` 和 `reflection_data` 依赖

### 4. 更新 workspace 配置 ✅

```yaml
# pubspec.yaml (root)
workspace:
  # ...
  - packages/data/shared_data  # 新增
```

## 架构对比

### Before (❌ 多实例)

```
reflection_data ──→ reflectionApiClient + reflectionTokenStorage
user_data ────────→ userApiClient + userTokenStorage
wallet_data ──────→ walletApiClient + walletTokenStorage
                    ↑ 3个实例，资源浪费
```

### After (✅ 单例共享)

```
reflection_data ─┐
user_data ───────┼─→ shared_data ──→ sharedApiClient + sharedTokenStorage
wallet_data ─────┘                    ↑ 单例，所有模块共享
```

## 代码示例

### 在 Data 层使用

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:shared_data/shared_data.dart';

final reflectionRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(sharedApiClientProvider);  // 共享的单例
  return ReflectionRemoteDataSourceImpl(apiClient);
});
```

### 在 Feature 层使用

```dart
// packages/features/copilot/lib/src/chat_page.dart
import 'package:shared_data/shared_data.dart';

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> _handleSubmitted(String text) async {
    final apiClient = ref.read(chatApiClientProvider);  // 共享的单例
    final response = await apiClient.post('/chat', data: {...});
  }
}
```

## 优势

### ✅ 单例模式
- ApiClient 只创建一次
- TokenStorage 只创建一次
- Token 在所有模块间共享
- 节省内存和资源

### ✅ 集中管理
- API 配置集中在 `ApiConfig`
- Network Provider 集中在 `shared_data`
- 易于切换环境（dev/staging/prod）

### ✅ 依赖清晰
```
Data Layer (reflection_data, user_data, wallet_data)
    ↓
Shared Data Layer (shared_data)
    ↓
Core Layer (network)
```

### ✅ 易于维护
- 修改 API URL：只需改 `ApiConfig`
- 切换 TokenStorage：只需改 `sharedTokenStorageProvider`
- 添加新 API：在 `shared_data` 添加新 Provider

## 依赖关系

```
┌─────────────────────────────────────────┐
│ Feature Layer                           │
│ - copilot (使用 chatApiClientProvider)  │
└─────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────┐
│ Data Layer                              │
│ - reflection_data                       │
│ - user_data                             │
│ - wallet_data                           │
│   (使用 sharedApiClientProvider)        │
└─────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────┐
│ Shared Data Layer                       │
│ - shared_data                           │
│   (提供共享的 Provider)                 │
└─────────────────────────────────────────┘
              ↓ 依赖
┌─────────────────────────────────────────┐
│ Core Layer                              │
│ - network                               │
│   (提供 ApiClient 和 TokenStorage)      │
└─────────────────────────────────────────┘
```

## 环境配置

### 切换 TokenStorage

```dart
// packages/data/shared_data/lib/src/providers/network_providers.dart
final sharedTokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    const isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? SecureTokenStorage() : MockTokenStorage();
  },
);
```

### 切换 API URL

```dart
// packages/data/shared_data/lib/src/config/api_config.dart
class ApiConfig {
  static String get currentBaseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'prod');
    switch (env) {
      case 'dev':
        return 'https://dev.things.dvacode.tech';
      case 'staging':
        return 'https://staging.things.dvacode.tech';
      default:
        return 'https://things.dvacode.tech';
    }
  }
}
```

## 测试

### 单元测试

```dart
test('shared providers return same instance', () {
  final container = ProviderContainer();
  
  final client1 = container.read(sharedApiClientProvider);
  final client2 = container.read(sharedApiClientProvider);
  
  expect(identical(client1, client2), true);  // 同一个实例
});
```

### Override Provider

```dart
testWidgets('can override shared provider', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedApiClientProvider.overrideWithValue(mockApiClient),
      ],
      child: MyApp(),
    ),
  );
});
```

## 后续优化建议

### 1. 添加环境配置

创建 `Environment` 枚举和配置管理：

```dart
enum Environment { dev, staging, prod }

class AppConfig {
  static Environment current = Environment.dev;
  
  static void setEnvironment(Environment env) {
    current = env;
  }
}
```

### 2. 添加日志

在 `shared_data` 中添加网络请求日志：

```dart
final sharedApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(sharedTokenStorageProvider);
  final client = createApiClient(
    baseUrl: ApiConfig.currentBaseUrl,
    tokenStorage: tokenStorage,
  );
  
  // 添加日志
  debugPrint('🌐 ApiClient created with baseUrl: ${ApiConfig.currentBaseUrl}');
  
  return client;
});
```

### 3. 添加错误处理

统一的错误处理策略：

```dart
class ApiErrorHandler {
  static void handle(AppException error) {
    // 统一错误处理
  }
}
```

## 相关文档

- [Shared Network Provider Strategy](./SHARED_NETWORK_PROVIDER_STRATEGY.md)
- [Network Layer Provider Strategy](./NETWORK_LAYER_PROVIDER_STRATEGY.md)
- [Network Provider Migration Summary](./NETWORK_PROVIDER_MIGRATION_SUMMARY.md)

## 迁移完成 ✅

所有 Data 模块现在共享同一个 ApiClient 和 TokenStorage 实例！

架构更加清晰、高效、易于维护！

# Network Provider 迁移总结

## 迁移完成 ✅

已成功将 Network Provider 从 Core 层迁移到 Data 层，解决了架构冲突问题。

## 变更内容

### 1. Core 层 (packages/core/network)

#### 删除的文件
- ❌ `lib/network/network_provider.dart` - 包含业务配置的 Provider

#### 新增的文件
- ✅ `lib/network/api_client_factory.dart` - 纯函数工厂，无业务配置

#### 更新的文件
- ✅ `lib/network.dart` - 更新导出，移除 network_provider，添加 api_client_factory

### 2. Data 层

#### reflection_data (packages/data/reflection_data)
- ✅ 新增 `lib/src/providers/network_providers.dart`
  - `reflectionTokenStorageProvider`
  - `reflectionApiClientProvider`
  - `chatApiClientProvider`
- ✅ 更新 `lib/src/providers/providers.dart` - 导出 network_providers
- ✅ 更新 `lib/src/providers/reflection_providers.dart` - 使用新的 provider

#### user_data (packages/data/user_data)
- ✅ 新增 `lib/src/providers/network_providers.dart`
  - `userTokenStorageProvider`
  - `userApiClientProvider`
- ✅ 更新 `lib/src/providers/user_providers.dart` - 使用新的 provider

#### wallet_data (packages/data/wallet_data)
- ✅ 新增 `lib/src/providers/network_providers.dart`
  - `walletTokenStorageProvider`
  - `walletApiClientProvider`
- ✅ 更新 `lib/src/providers/wallet_providers.dart` - 使用新的 provider

### 3. Feature 层

#### copilot (packages/features/copilot)
- ✅ 更新 `lib/src/chat_page.dart` - 从 reflection_data 导入 chatApiClientProvider

## 架构改进

### Before (❌ 问题)

```
┌─────────────────────────────────────┐
│ Data Layer                          │
│ - 依赖 Core 层的 Provider           │
│ - 无法控制业务配置                  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Core Layer                          │
│ - ❌ 包含业务 URL                   │
│ - ❌ 创建具体的 Provider            │
│ - ❌ 违反 Infrastructure 职责       │
└─────────────────────────────────────┘
```

### After (✅ 正确)

```
┌─────────────────────────────────────┐
│ Data Layer                          │
│ - ✅ 创建自己的 Provider            │
│ - ✅ 配置业务 URL                   │
│ - ✅ 选择 TokenStorage 实现         │
└─────────────────────────────────────┘
              ↓ 使用
┌─────────────────────────────────────┐
│ Core Layer                          │
│ - ✅ 只提供抽象和实现               │
│ - ✅ 提供工厂函数                   │
│ - ✅ 无业务配置                     │
└─────────────────────────────────────┘
```

## 代码对比

### Core 层 - Before

```dart
// ❌ packages/core/network/lib/network/network_provider.dart
const String kBaseUrl = 'https://things.dvacode.tech';  // 业务配置

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});
```

### Core 层 - After

```dart
// ✅ packages/core/network/lib/network/api_client_factory.dart
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

### Data 层 - After

```dart
// ✅ packages/data/reflection_data/lib/src/providers/network_providers.dart
const String _kReflectionApiBaseUrl = 'https://things.dvacode.tech';

final reflectionTokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

final reflectionApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(reflectionTokenStorageProvider);
  return createApiClient(
    baseUrl: _kReflectionApiBaseUrl,
    tokenStorage: tokenStorage,
  );
});
```

## 使用方式

### 在 Repository 中使用

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'network_providers.dart';

final reflectionRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(reflectionApiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
});
```

### 在 Feature 中使用

```dart
// packages/features/copilot/lib/src/chat_page.dart
import 'package:reflection_data/reflection_data.dart';

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> _handleSubmitted(String text) async {
    final apiClient = ref.read(chatApiClientProvider);
    final response = await apiClient.post('/chat', data: {...});
  }
}
```

## 优势总结

### ✅ 架构清晰
- Core 层职责单一：提供基础设施
- Data 层职责明确：配置业务逻辑
- 符合 Clean Architecture 原则

### ✅ 灵活性高
- 每个 Data 包可以独立配置 URL
- 可以为不同 API 创建不同的 Client
- 易于切换 TokenStorage 实现

### ✅ 可测试性强
- Core 层工厂函数是纯函数
- Data 层 Provider 可以轻松 override
- 易于注入 Mock 实现

### ✅ 可维护性好
- 业务配置集中在 Data 层
- 修改 URL 不影响 Core 层
- 依赖关系清晰

## 后续建议

### 1. 统一 TokenStorage

如果多个模块需要共享 TokenStorage，可以考虑：

**选项 A：在 App 层创建全局 Provider**
```dart
// apps/lt_app/lib/src/providers/app_providers.dart
final appTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
```

**选项 B：创建 shared_data 包**
```dart
// packages/data/shared_data/lib/src/providers/shared_providers.dart
final sharedTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
```

### 2. 环境配置

考虑添加环境配置支持：

```dart
// packages/data/reflection_data/lib/src/config/api_config.dart
class ReflectionApiConfig {
  static String get baseUrl {
    switch (Environment.current) {
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

### 3. 生产环境切换

记得在生产环境切换到 SecureTokenStorage：

```dart
final reflectionTokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),  // 生产环境
  // (ref) => MockTokenStorage(),  // 开发环境
);
```

## 相关文档

- [Network Layer Provider Strategy](.kiro/specs/clean-architecture-refactoring/NETWORK_LAYER_PROVIDER_STRATEGY.md)
- [Provider Strategy V2](.kiro/specs/clean-architecture-refactoring/PROVIDER_STRATEGY_V2.md)
- [Third Party SDK Integration](.kiro/specs/clean-architecture-refactoring/THIRD_PARTY_SDK_INTEGRATION.md)

## 迁移完成 ✅

所有相关文件已更新，架构问题已解决！

# Provider 组织策略 - 最终方案（混合方案）

## 🎯 核心原则

基于对 Clean Architecture 的深入理解，我们采用**混合方案**来组织 Provider：

### 层次理解

```
┌─────────────────────────────────────────────────────────────┐
│ Domain Layer (广义 - 业务领域层)                            │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Presentation Sub-layer (Features)                       │ │
│ │ - UI (Widgets, Pages)                                   │ │
│ │ - Controllers (State Management)                        │ │
│ │ - UseCase Providers ✅                                  │ │
│ └─────────────────────────────────────────────────────────┘ │
│              ↓ 使用                                          │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Business Logic Sub-layer (Domain)                       │ │
│ │ - Entities (Business Objects)                           │ │
│ │ - UseCases (Business Rules)                             │ │
│ │ - Repository Interfaces                                 │ │
│ │ - 不包含 Providers ❌                                    │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
              ↑ 实现
┌─────────────────────────────────────────────────────────────┐
│ Data Layer                                                  │
│ - Models (DTO)                                              │
│ - DataSources                                               │
│ - Repository 实现                                           │
│ - Repository & DataSource Providers ✅                      │
└─────────────────────────────────────────────────────────────┘
              ↓ 使用
┌─────────────────────────────────────────────────────────────┐
│ Infrastructure Layer (Core)                                 │
│ - Network, Storage, UI Components                           │
│ - Infrastructure Providers ✅                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Provider 分层策略

### 1. Core Layer - Infrastructure Providers

**位置**：`packages/core/network/lib/network/network_provider.dart`

**职责**：提供基础设施相关的 Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'token_storage.dart';
import 'mock_token_storage.dart';

const String kBaseUrl = 'https://things.dvacode.tech';

/// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

/// API Client Provider
final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});
```

**包含的 Providers**：
- `tokenStorageProvider` - Token 存储
- `apiClientProvider` - API 客户端

---

### 2. Data Layer - Repository & DataSource Providers

**位置**：`packages/data/*/lib/src/providers/*_providers.dart`

**职责**：提供数据访问相关的 Provider（Repository 和 DataSource）

#### Reflection Data

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// Reflection Data Layer - Dependency Injection
// 只包含 DataSource 和 Repository Providers
// UseCase Providers 由 Features 层根据需要创建
// ============================================================================

/// DataSource Provider
final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
);

/// Repository Provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});
```

#### User Data

```dart
// packages/data/user_data/lib/src/providers/user_providers.dart
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});
```

#### Wallet Data

```dart
// packages/data/wallet_data/lib/src/providers/wallet_providers.dart
final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
});
```

**包含的 Providers**：
- `*RemoteDataSourceProvider` - 远程数据源
- `*RepositoryProvider` - Repository 实现

---

### 3. Features Layer - UseCase Providers

**位置**：`packages/features/*/lib/src/providers/*_providers.dart`

**职责**：根据 Feature 的需要创建 UseCase Providers

#### Calendar Feature

```dart
// packages/features/calendar/lib/src/providers/calendar_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

// ============================================================================
// Calendar Feature - UseCase Providers
// Features 层根据自己的需要创建 UseCase Providers
// ============================================================================

/// 获取日历反思数据的 UseCase Provider
final fetchCalendarReflectionsProvider = Provider<FetchCalendarReflections>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchCalendarReflectionsImpl(repository);
});

/// 获取今日问题的 UseCase Provider
final fetchTodayQuestionProvider = Provider<FetchTodayQuestion>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionImpl(repository);
});
```

#### Thread Feature

```dart
// packages/features/thread/lib/src/providers/thread_providers.dart
final fetchThreadQuestionsProvider = Provider<FetchThreadQuestions>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchThreadQuestionsImpl(repository);
});

final fetchAnswerDetailProvider = Provider<FetchAnswerDetail>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchAnswerDetailImpl(repository);
});
```

#### Add Answer Feature

```dart
// packages/features/add_answer/lib/src/providers/add_answer_providers.dart
final submitAnswerProvider = Provider<SubmitAnswer>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return SubmitAnswerImpl(repository);
});
```

#### Today Question Feature

```dart
// packages/features/today_question/lib/src/providers/today_question_providers.dart
final fetchTodayQuestionProvider = Provider<FetchTodayQuestion>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionImpl(repository);
});
```

**包含的 Providers**：
- Feature 需要的 UseCase Providers

---

## 🔄 完整的依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│ Apps Layer (lt_app)                                         │
│ - 只负责启动应用                                             │
│ - 配置 ProviderScope                                        │
│ - 不包含业务 Providers                                      │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Features Layer (calendar, thread, ...)                      │
│ - UI Pages                                                  │
│ - Controllers                                               │
│ - UseCase Providers ✅                                      │
│   • fetchCalendarReflectionsProvider                        │
│   • fetchThreadQuestionsProvider                            │
│   • submitAnswerProvider                                    │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Data Layer (reflection_data, user_data, wallet_data)        │
│ - Models (DTO)                                              │
│ - DataSources                                               │
│ - Repository 实现                                           │
│ - Repository & DataSource Providers ✅                      │
│   • reflectionRepositoryProvider                            │
│   • reflectionRemoteDataSourceProvider                      │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Domain Layer (reflection_domain, user_domain, wallet_domain)│
│ - Entities                                                  │
│ - Repository 接口                                           │
│ - UseCases                                                  │
│ - 不包含 Providers ❌                                        │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Core Layer (network, storage, ui_components)                │
│ - ApiClient                                                 │
│ - TokenStorage                                              │
│ - Infrastructure Providers ✅                               │
│   • apiClientProvider                                       │
│   • tokenStorageProvider                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 为什么采用混合方案？

### 1. 职责清晰

每一层只包含自己职责范围内的 Provider：

- **Core Layer**：基础设施 Providers（ApiClient, TokenStorage）
- **Data Layer**：数据访问 Providers（Repository, DataSource）
- **Features Layer**：业务用例 Providers（UseCases）
- **Domain Layer**：不包含 Providers（纯业务逻辑）

### 2. 避免循环依赖

```
✅ 正确的依赖关系：
Apps → Features (使用 UseCase Providers) → Data (使用 Repository Providers) → Domain → Core

❌ 错误的依赖关系（如果 Provider 在 Apps）：
Apps (包含 Providers) → Features → Apps (使用 Providers) ❌ 循环依赖！
```

### 3. 灵活性

Features 可以根据自己的需要组合不同的 UseCases：

```dart
// Calendar Feature 需要两个 UseCases
final fetchCalendarReflectionsProvider = ...;
final fetchTodayQuestionProvider = ...;

// Thread Feature 需要不同的 UseCases
final fetchThreadQuestionsProvider = ...;
final fetchAnswerDetailProvider = ...;
```

### 4. 可测试性

每一层的 Provider 都可以独立测试和替换：

```dart
// 测试 Calendar Feature
final container = ProviderContainer(
  overrides: [
    // 只覆盖 Repository Provider
    reflectionRepositoryProvider.overrideWithValue(mockRepository),
  ],
);

// UseCase Provider 会自动使用 Mock Repository
final useCase = container.read(fetchCalendarReflectionsProvider);
```

---

## 📝 使用示例

### 1. 在 Controller 中使用 UseCase Provider

```dart
// packages/features/calendar/lib/src/calendar_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'providers/calendar_providers.dart';  // ✅ 导入 Feature 的 Providers

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    _fetchCalendarData(DateTime.now());
    return CalendarState(...);
  }
  
  Future<void> _fetchCalendarData(DateTime month) async {
    // ✅ 使用 Feature 层的 UseCase Provider
    final fetchReflections = ref.read(fetchCalendarReflectionsProvider);
    
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    
    try {
      final reflections = await fetchReflections(start: start, end: end);
      
      final reflectionMap = <String, CalendarDayEntity>{};
      for (final day in reflections) {
        reflectionMap[day.date] = day;
      }
      
      state = state.copyWith(
        reflections: AsyncValue.data(reflectionMap),
      );
    } catch (e, st) {
      state = state.copyWith(
        reflections: AsyncValue.error(e, st),
      );
    }
  }
}
```

### 2. Feature 的 pubspec.yaml 配置

```yaml
# packages/features/calendar/pubspec.yaml
name: calendar
description: Calendar feature
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter
  
  # Riverpod
  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  
  # Domain Layer (Entities, UseCases, Interfaces)
  reflection_domain:
    path: ../../domain/reflection_domain
  
  # Data Layer (Repository Providers)
  reflection_data:
    path: ../../data/reflection_data
  
  # Core
  lt_uicomponent:
    path: ../../core/lt_uicomponent
  
  # Utilities
  date_utl:
    path: ../../utls/date_utl

dev_dependencies:
  build_runner: ^2.4.13
  riverpod_generator: ^4.0.0
```

---

## 📊 Provider 分布总结

### Core Layer
```
packages/core/network/lib/network/
└── network_provider.dart
    ├── tokenStorageProvider
    └── apiClientProvider
```

### Data Layer
```
packages/data/reflection_data/lib/src/providers/
└── reflection_providers.dart
    ├── reflectionRemoteDataSourceProvider
    └── reflectionRepositoryProvider

packages/data/user_data/lib/src/providers/
└── user_providers.dart
    ├── userRemoteDataSourceProvider
    └── userRepositoryProvider

packages/data/wallet_data/lib/src/providers/
└── wallet_providers.dart
    ├── walletRemoteDataSourceProvider
    └── walletRepositoryProvider
```

### Features Layer
```
packages/features/calendar/lib/src/providers/
└── calendar_providers.dart
    ├── fetchCalendarReflectionsProvider
    └── fetchTodayQuestionProvider

packages/features/thread/lib/src/providers/
└── thread_providers.dart
    ├── fetchThreadQuestionsProvider
    └── fetchAnswerDetailProvider

packages/features/add_answer/lib/src/providers/
└── add_answer_providers.dart
    └── submitAnswerProvider

packages/features/today_question/lib/src/providers/
└── today_question_providers.dart
    └── fetchTodayQuestionProvider
```

---

## 🎯 总结

### Provider 的三层分布

1. **Core Layer** - Infrastructure Providers
   - `apiClientProvider`
   - `tokenStorageProvider`

2. **Data Layer** - Repository & DataSource Providers
   - `*RemoteDataSourceProvider`
   - `*RepositoryProvider`

3. **Features Layer** - UseCase Providers
   - `fetch*Provider`
   - `submit*Provider`
   - `get*Provider`

### 关键原则

- ✅ **职责清晰**：每一层只包含自己职责范围内的 Provider
- ✅ **避免循环依赖**：Features 不依赖 Apps
- ✅ **灵活组合**：Features 根据需要创建 UseCase Providers
- ✅ **易于测试**：可以独立测试和替换每一层的 Provider
- ✅ **模块化**：每个模块自包含，易于维护

这就是最终的混合方案！它结合了各种方案的优点，既保持了架构的纯净性，又提供了灵活性和可测试性。

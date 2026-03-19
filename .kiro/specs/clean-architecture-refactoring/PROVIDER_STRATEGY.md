# Provider 组织策略 - Clean Architecture

## 🎯 核心原则

在模块化 Clean Architecture 中，Provider 的放置遵循以下核心原则：

### 1. Domain Layer - 不包含 Provider
```
❌ 错误做法：
packages/domain/reflection_domain/lib/src/providers/
  └── reflection_providers.dart  # Domain 层不应该有 Provider

✅ 正确做法：
packages/domain/reflection_domain/lib/src/
  ├── entities/
  ├── repositories/
  └── usecases/
  # 没有 providers/ 目录
```

**原因**：
- Domain Layer 应该是纯 Dart，不依赖任何框架
- 保持业务逻辑的可移植性
- 便于单元测试（不需要 Riverpod）

### 2. Data Layer - 不包含 Provider
```
❌ 错误做法：
packages/data/reflection_data/lib/src/providers/
  └── data_providers.dart  # Data 层不应该有 Provider

✅ 正确做法：
packages/data/reflection_data/lib/src/
  ├── models/
  ├── datasources/
  └── repositories/
  # 没有 providers/ 目录
```

**原因**：
- Data Layer 应该专注于数据访问
- 保持层的纯净性
- 避免循环依赖

### 3. Apps Layer - 统一管理所有 Provider（推荐）
```
✅ 正确做法：
apps/lt_app/lib/src/di/
  ├── providers.dart                    # 统一导出
  ├── infrastructure_providers.dart     # 基础设施 Providers
  ├── reflection_providers.dart         # Reflection 模块 Providers
  ├── user_providers.dart               # User 模块 Providers
  └── wallet_providers.dart             # Wallet 模块 Providers
```

**原因**：
- 这是依赖注入的"组合根"（Composition Root）
- 集中管理所有依赖关系
- 易于测试和替换实现
- 清晰的依赖关系可视化

---

## 📦 推荐的 Provider 组织结构

### 目录结构

```
apps/lt_app/lib/src/di/
├── providers.dart                    # 统一导出所有 Providers
├── infrastructure_providers.dart     # 基础设施层 Providers
│   ├── tokenStorageProvider
│   └── apiClientProvider
│
├── reflection_providers.dart         # Reflection 模块 Providers
│   ├── reflectionRemoteDataSourceProvider
│   ├── reflectionRepositoryProvider
│   ├── fetchThreadQuestionsProvider
│   ├── fetchTodayQuestionProvider
│   ├── fetchCalendarReflectionsProvider
│   ├── submitAnswerProvider
│   └── fetchAnswerDetailProvider
│
├── user_providers.dart               # User 模块 Providers
│   ├── userRemoteDataSourceProvider
│   ├── userRepositoryProvider
│   ├── getCurrentUserProvider
│   ├── updateProfileProvider
│   └── logoutProvider
│
└── wallet_providers.dart             # Wallet 模块 Providers
    ├── walletRemoteDataSourceProvider
    ├── walletRepositoryProvider
    ├── getWalletProvider
    └── getTransactionsProvider
```

### 文件内容示例

#### 1. infrastructure_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';

// ============================================================================
// Infrastructure Layer - Dependency Injection
// ============================================================================

const String kBaseUrl = 'https://things.dvacode.tech';

// Token Storage
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

// API Client
final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});
```

#### 2. reflection_providers.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';
import 'infrastructure_providers.dart';

// ============================================================================
// Reflection Module - Dependency Injection
// ============================================================================

// DataSource Layer
final reflectionRemoteDataSourceProvider =
    Provider<ReflectionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
});

// Repository Layer
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});

// UseCase Layer
final fetchThreadQuestionsProvider = Provider<FetchThreadQuestions>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchThreadQuestionsImpl(repository);
});

final fetchTodayQuestionProvider = Provider<FetchTodayQuestion>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionImpl(repository);
});

final fetchCalendarReflectionsProvider =
    Provider<FetchCalendarReflections>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchCalendarReflectionsImpl(repository);
});

final submitAnswerProvider = Provider<SubmitAnswer>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return SubmitAnswerImpl(repository);
});

final fetchAnswerDetailProvider = Provider<FetchAnswerDetail>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchAnswerDetailImpl(repository);
});
```

#### 3. providers.dart（统一导出）

```dart
/// Dependency Injection - Composition Root
/// 
/// 这个文件是整个应用的依赖注入配置中心（Composition Root）。
/// 所有的 Provider 都在这里统一导出，便于管理和维护。
library providers;

// Infrastructure Providers
export 'infrastructure_providers.dart';

// Business Module Providers
export 'reflection_providers.dart';
export 'user_providers.dart';
export 'wallet_providers.dart';
```

---

## 🔄 依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│ Apps Layer - Dependency Injection (Composition Root)        │
│ apps/lt_app/lib/src/di/                                     │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Infrastructure Providers                            │   │
│ │ - tokenStorageProvider                              │   │
│ │ - apiClientProvider                                 │   │
│ └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Reflection Providers                                │   │
│ │ - reflectionRemoteDataSourceProvider                │   │
│ │ - reflectionRepositoryProvider                      │   │
│ │ - fetchThreadQuestionsProvider                      │   │
│ │ - fetchTodayQuestionProvider                        │   │
│ │ - fetchCalendarReflectionsProvider                  │   │
│ │ - submitAnswerProvider                              │   │
│ │ - fetchAnswerDetailProvider                         │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ User Providers                                      │   │
│ │ - userRemoteDataSourceProvider                      │   │
│ │ - userRepositoryProvider                            │   │
│ │ - getCurrentUserProvider                            │   │
│ │ - updateProfileProvider                             │   │
│ │ - logoutProvider                                    │   │
│ └─────────────────────────────────────────────────────┘   │
│                                                             │
│ ┌─────────────────────────────────────────────────────┐   │
│ │ Wallet Providers                                    │   │
│ │ - walletRemoteDataSourceProvider                    │   │
│ │ - walletRepositoryProvider                          │   │
│ │ - getWalletProvider                                 │   │
│ │ - getTransactionsProvider                           │   │
│ └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Features Layer                                              │
│ - 使用 ref.read(fetchThreadQuestionsProvider)               │
│ - 使用 ref.read(getCurrentUserProvider)                     │
│ - 使用 ref.read(getWalletProvider)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 为什么这样设计？

### 1. 符合依赖倒置原则（DIP）

```dart
// Domain Layer - 定义接口（不依赖框架）
abstract interface class ReflectionRepository {
  Future<List<QuestionEntity>> fetchThreadQuestions();
}

// Data Layer - 实现接口（不依赖框架）
class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _dataSource;
  
  @override
  Future<List<QuestionEntity>> fetchThreadQuestions() async {
    final models = await _dataSource.fetchThreadQuestions();
    return models.map((m) => m.toEntity()).toList();
  }
}

// Apps Layer - 依赖注入（使用框架）
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});
```

### 2. 组合根（Composition Root）模式

**组合根**是依赖注入的核心概念：
- 所有依赖关系在应用的入口点（根）组合
- 业务逻辑层不知道具体的实现
- 易于替换实现（如测试时使用 Mock）

```dart
// 生产环境
final apiClientProvider = Provider<ApiClientType>((ref) {
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});

// 测试环境
final apiClientProvider = Provider<ApiClientType>((ref) {
  return MockApiClient();  // 使用 Mock 实现
});
```

### 3. 单一职责原则（SRP）

每一层都有明确的职责：
- **Domain Layer**：定义业务规则和接口
- **Data Layer**：实现数据访问
- **Apps Layer**：组合依赖关系

### 4. 易于测试

```dart
// 测试 UseCase 时，不需要 Riverpod
test('FetchThreadQuestions should sort by pinned', () async {
  // Arrange
  final mockRepository = MockReflectionRepository();
  final useCase = FetchThreadQuestionsImpl(mockRepository);
  
  when(mockRepository.fetchThreadQuestions())
      .thenAnswer((_) async => [question1, question2]);
  
  // Act
  final result = await useCase();
  
  // Assert
  expect(result.first.pinned, true);
});
```

---

## 🚀 使用示例

### 在 Feature 中使用 Provider

```dart
// packages/features/calendar/lib/src/calendar_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';

// 导入 Apps Layer 的 Providers
import 'package:ltapp_flutter/src/di/providers.dart';

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    _fetchCalendarData(DateTime.now());
    return CalendarState(...);
  }
  
  Future<void> _fetchCalendarData(DateTime month) async {
    // 使用 Apps Layer 提供的 Provider
    final fetchReflections = ref.read(fetchCalendarReflectionsProvider);
    
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    
    try {
      // 调用 UseCase
      final reflections = await fetchReflections(start: start, end: end);
      
      // 使用 Entity
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

### 在测试中替换 Provider

```dart
// test/calendar_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

void main() {
  test('CalendarController should fetch reflections', () async {
    // 创建 Mock
    final mockUseCase = MockFetchCalendarReflections();
    
    // 创建 ProviderContainer 并覆盖 Provider
    final container = ProviderContainer(
      overrides: [
        fetchCalendarReflectionsProvider.overrideWithValue(mockUseCase),
      ],
    );
    
    // 测试逻辑
    when(mockUseCase(start: any, end: any))
        .thenAnswer((_) async => [mockCalendarDay]);
    
    final controller = container.read(calendarControllerProvider.notifier);
    await controller._fetchCalendarData(DateTime.now());
    
    // 验证
    verify(mockUseCase(start: any, end: any)).called(1);
  });
}
```

---

## 🔧 添加新模块时的 Provider 配置

### 示例：添加 Payment 模块

**1. 创建 payment_providers.dart**

```dart
// apps/lt_app/lib/src/di/payment_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_domain/payment_domain.dart';
import 'package:payment_data/payment_data.dart';
import 'infrastructure_providers.dart';

// ============================================================================
// Payment Module - Dependency Injection
// ============================================================================

// DataSource Layer
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSourceImpl(apiClient);
});

// Repository Layer
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(dataSource);
});

// UseCase Layer
final createPaymentProvider = Provider<CreatePayment>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return CreatePaymentImpl(repository);
});

final getPaymentsProvider = Provider<GetPayments>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetPaymentsImpl(repository);
});
```

**2. 在 providers.dart 中导出**

```dart
// apps/lt_app/lib/src/di/providers.dart
library providers;

export 'infrastructure_providers.dart';
export 'reflection_providers.dart';
export 'user_providers.dart';
export 'wallet_providers.dart';
export 'payment_providers.dart';  // 新增
```

**3. 在 Feature 中使用**

```dart
// packages/features/payment/lib/src/payment_controller.dart
import 'package:ltapp_flutter/src/di/providers.dart';

@riverpod
class PaymentController extends _$PaymentController {
  Future<void> createPayment(double amount) async {
    final createPayment = ref.read(createPaymentProvider);
    final payment = await createPayment(amount);
    // ...
  }
}
```

---

## 📊 对比：不同的 Provider 放置策略

### 方案 1：Domain Layer 包含 Provider（❌ 不推荐）

```
packages/domain/reflection_domain/
  ├── lib/
  │   ├── src/
  │   │   ├── entities/
  │   │   ├── repositories/
  │   │   ├── usecases/
  │   │   └── providers/          # ❌ Domain 层包含 Provider
  │   │       └── reflection_providers.dart
  │   └── reflection_domain.dart
  └── pubspec.yaml
      dependencies:
        flutter_riverpod: ^3.1.0  # ❌ Domain 层依赖框架
```

**问题**：
- ❌ Domain Layer 不再是纯 Dart
- ❌ 违反了依赖倒置原则
- ❌ 难以移植到其他框架
- ❌ 测试时必须依赖 Riverpod

### 方案 2：Data Layer 包含 Provider（⚠️ 可行但不推荐）

```
packages/data/reflection_data/
  ├── lib/
  │   ├── src/
  │   │   ├── models/
  │   │   ├── datasources/
  │   │   ├── repositories/
  │   │   └── providers/          # ⚠️ Data 层包含 Provider
  │   │       └── data_providers.dart
  │   └── reflection_data.dart
  └── pubspec.yaml
      dependencies:
        flutter_riverpod: ^3.1.0  # ⚠️ Data 层依赖框架
```

**问题**：
- ⚠️ Data Layer 依赖 Riverpod
- ⚠️ 不够灵活（难以替换 DI 框架）
- ⚠️ 职责不够清晰

**优点**：
- ✅ 每个模块自包含
- ✅ 可以独立发布

### 方案 3：Apps Layer 统一管理（✅ 推荐）

```
apps/lt_app/lib/src/di/
  ├── providers.dart                    # ✅ 统一导出
  ├── infrastructure_providers.dart     # ✅ 基础设施
  ├── reflection_providers.dart         # ✅ Reflection 模块
  ├── user_providers.dart               # ✅ User 模块
  └── wallet_providers.dart             # ✅ Wallet 模块
```

**优点**：
- ✅ Domain 和 Data 层保持纯净
- ✅ 集中管理所有依赖
- ✅ 易于测试和替换实现
- ✅ 符合组合根模式
- ✅ 清晰的依赖关系

**缺点**：
- ⚠️ 所有 Provider 在一个地方（但可以通过文件分离解决）

---

## 🎯 总结

### 推荐的 Provider 组织策略

1. **Domain Layer**：不包含 Provider（纯 Dart）
2. **Data Layer**：不包含 Provider（保持纯净）
3. **Apps Layer**：统一管理所有 Provider（组合根）

### 关键原则

- ✅ **依赖倒置**：高层模块不依赖低层模块
- ✅ **单一职责**：每一层只负责自己的职责
- ✅ **组合根**：所有依赖在应用入口组合
- ✅ **易于测试**：可以轻松替换实现

### 文件组织

```
apps/lt_app/lib/src/di/
├── providers.dart                    # 统一导出
├── infrastructure_providers.dart     # 基础设施
├── reflection_providers.dart         # 业务模块 1
├── user_providers.dart               # 业务模块 2
└── wallet_providers.dart             # 业务模块 3
```

这种组织方式既保持了架构的纯净性，又提供了灵活性和可测试性！

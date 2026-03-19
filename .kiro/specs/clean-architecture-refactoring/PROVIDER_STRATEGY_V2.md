# Provider 组织策略 V2 - 正确的依赖关系

## 🎯 问题分析

### 之前的错误方案

```
❌ 错误：Provider 放在 Apps Layer

Apps Layer (包含 Providers)
  ↓ 依赖
Features Layer
  ↓ 需要导入 Apps Layer 的 Providers ❌ 循环依赖！
```

**问题**：
- Features 层需要使用 Provider
- 如果 Provider 在 Apps 层，Features 就要依赖 Apps
- 但 Apps 本身就依赖 Features
- 形成循环依赖！

### 正确的方案

```
✅ 正确：Provider 放在 Data Layer

Apps Layer (壳，只负责启动)
  ↓ 依赖
Features Layer (Presentation)
  ↓ 依赖
Data Layer (包含 Providers)
  ↓ 依赖
Domain Layer (纯业务逻辑，不包含 Provider)
  ↓ 依赖
Core Layer (Infrastructure)
```

---

## 📦 正确的 Provider 组织结构

### 目录结构

```
packages/
├── domain/                          # 不包含 Provider
│   ├── reflection_domain/
│   │   └── lib/
│   │       ├── src/
│   │       │   ├── entities/
│   │       │   ├── repositories/
│   │       │   └── usecases/
│   │       └── reflection_domain.dart
│   ├── user_domain/
│   └── wallet_domain/
│
├── data/                            # 包含 Provider ✅
│   ├── reflection_data/
│   │   └── lib/
│   │       ├── src/
│   │       │   ├── models/
│   │       │   ├── datasources/
│   │       │   ├── repositories/
│   │       │   └── providers/      # ✅ Provider 在这里
│   │       │       └── reflection_providers.dart
│   │       └── reflection_data.dart (导出 providers)
│   ├── user_data/
│   │   └── lib/
│   │       ├── src/
│   │       │   └── providers/      # ✅ Provider 在这里
│   │       │       └── user_providers.dart
│   │       └── user_data.dart
│   └── wallet_data/
│       └── lib/
│           ├── src/
│           │   └── providers/      # ✅ Provider 在这里
│           │       └── wallet_providers.dart
│           └── wallet_data.dart
│
├── features/                        # 使用 Data Layer 的 Provider
│   ├── calendar/
│   │   └── lib/
│   │       └── src/
│   │           └── calendar_controller.dart
│   │               # import 'package:reflection_data/reflection_data.dart';
│   │               # 使用 fetchCalendarReflectionsProvider
│   └── ...
│
└── core/                            # Infrastructure
    └── network/
        └── lib/
            └── network/
                └── network_provider.dart  # apiClientProvider
```

---

## 🔄 依赖关系图

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
│ - 使用 Data Layer 的 Providers                              │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Data Layer (reflection_data, user_data, wallet_data)        │
│ - Models (DTO)                                              │
│ - DataSources                                               │
│ - Repository 实现                                           │
│ - Providers ✅ (提供依赖注入)                                │
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
│ - Infrastructure Providers (apiClientProvider)              │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 为什么 Provider 应该在 Data Layer？

### 1. 避免循环依赖

```dart
// ✅ 正确的依赖关系
Features → Data (使用 Providers) → Domain → Core

// ❌ 错误的依赖关系（循环依赖）
Apps → Features → Apps (使用 Providers) ❌
```

### 2. 符合职责划分

**Data Layer 的职责**：
- 实现 Domain 层的接口
- 提供数据访问
- **提供依赖注入配置** ✅

**Domain Layer 的职责**：
- 定义业务规则
- 定义接口
- 不关心实现细节
- **不包含框架依赖** ✅

### 3. 模块化和独立性

每个 Data 模块都是自包含的：
- `reflection_data` 包含自己的 Providers
- `user_data` 包含自己的 Providers
- `wallet_data` 包含自己的 Providers

### 4. 易于测试

```dart
// 测试时可以覆盖 Data Layer 的 Provider
final container = ProviderContainer(
  overrides: [
    // 覆盖 reflection_data 的 Provider
    reflectionRepositoryProvider.overrideWithValue(mockRepository),
  ],
);
```

---

## 📝 实现示例

### 1. Core Layer - Infrastructure Providers

```dart
// packages/core/network/lib/network/network_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'token_storage.dart';
import 'mock_token_storage.dart';

const String kBaseUrl = 'https://things.dvacode.tech';

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => MockTokenStorage(),
);

// API Client Provider
final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});
```

### 2. Data Layer - Business Providers

```dart
// packages/data/reflection_data/lib/src/providers/reflection_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// DataSource Provider
final reflectionRemoteDataSourceProvider =
    Provider<ReflectionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
});

// Repository Provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});

// UseCase Providers
final fetchThreadQuestionsProvider = Provider<FetchThreadQuestions>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchThreadQuestionsImpl(repository);
});

final fetchCalendarReflectionsProvider =
    Provider<FetchCalendarReflections>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchCalendarReflectionsImpl(repository);
});

// ... 其他 UseCases
```

```dart
// packages/data/reflection_data/lib/reflection_data.dart
library reflection_data;

export 'src/models/models.dart';
export 'src/datasources/datasources.dart';
export 'src/repositories/repositories.dart';
export 'src/providers/providers.dart';  // ✅ 导出 Providers
```

### 3. Features Layer - 使用 Providers

```dart
// packages/features/calendar/lib/src/calendar_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';  // ✅ 导入 Data Layer

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    _fetchCalendarData(DateTime.now());
    return CalendarState(...);
  }
  
  Future<void> _fetchCalendarData(DateTime month) async {
    // ✅ 使用 Data Layer 提供的 Provider
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

### 4. Apps Layer - 只负责启动

```dart
// apps/lt_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app_router.dart';

void main() {
  runApp(
    const ProviderScope(  // ✅ 只配置 ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'Little Thing',
      theme: ThemeData(...),
    );
  }
}
```

---

## 🔧 Feature 的 pubspec.yaml 配置

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
  
  # Domain Layer (只依赖接口和实体)
  reflection_domain:
    path: ../../domain/reflection_domain
  
  # Data Layer (使用 Providers)
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

## 📊 对比：两种方案

### 方案 1：Provider 在 Apps Layer（❌ 错误）

```
Apps Layer
  ├── providers.dart (包含所有 Providers)
  └── main.dart

Features Layer
  └── calendar_controller.dart
      import 'package:ltapp_flutter/src/di/providers.dart';  ❌ 依赖 Apps
```

**问题**：
- ❌ Features 依赖 Apps
- ❌ Apps 依赖 Features
- ❌ 循环依赖！

### 方案 2：Provider 在 Data Layer（✅ 正确）

```
Data Layer
  └── reflection_data/
      ├── providers/
      │   └── reflection_providers.dart
      └── reflection_data.dart (导出 providers)

Features Layer
  └── calendar_controller.dart
      import 'package:reflection_data/reflection_data.dart';  ✅ 依赖 Data
```

**优势**：
- ✅ 依赖方向正确：Features → Data → Domain → Core
- ✅ 没有循环依赖
- ✅ 模块化和独立性
- ✅ 易于测试

---

## 🎯 总结

### Provider 的正确位置

1. **Domain Layer** - ❌ 不包含 Provider
   - 纯 Dart，不依赖框架
   - 只定义接口和业务逻辑

2. **Data Layer** - ✅ 包含 Provider
   - 实现 Domain 接口
   - 提供依赖注入配置
   - 每个模块自包含

3. **Features Layer** - 使用 Data Layer 的 Provider
   - 导入 Data Layer
   - 使用 Provider 获取 UseCase

4. **Apps Layer** - 只负责启动
   - 配置 ProviderScope
   - 不包含业务 Providers

### 依赖关系

```
Apps → Features → Data (Providers) → Domain → Core
```

### 关键原则

- ✅ **避免循环依赖**：Features 不能依赖 Apps
- ✅ **模块化**：每个 Data 模块包含自己的 Providers
- ✅ **职责清晰**：Data 层负责依赖注入
- ✅ **易于测试**：可以覆盖 Data Layer 的 Providers

这才是正确的 Clean Architecture 实现方式！

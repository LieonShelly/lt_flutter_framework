# Flutter Super App - Clean Architecture

## 项目简介

这是一个基于 Flutter 的企业级应用框架，采用 **标准 Clean Architecture** + **Monorepo** 架构设计。项目严格遵循依赖倒置原则，实现了清晰的分层结构：Core 层（基础设施）、Data 层（数据访问）、Domain 层（业务逻辑）、Features 层（功能模块）、Apps 层（应用入口）。

项目使用 Riverpod 进行状态管理和依赖注入，GoRouter 处理路由导航，Dio 实现网络请求。每个业务模块都拆分为独立的 Domain 和 Data 包，支持高度模块化和代码复用。采用 Entity-Repository-UseCase 模式封装业务逻辑，通过接口抽象实现依赖倒置，便于单元测试和维护。

## 核心特性

- ✅ **标准 Clean Architecture**：严格的分层架构，依赖方向单向向内
- ✅ **模块化设计**：按业务领域拆分 Domain 和 Data 层
- ✅ **依赖倒置**：Domain 层定义接口，Data 层实现接口
- ✅ **类型安全**：使用 Freezed 和 JSON Serializable
- ✅ **依赖注入**：Riverpod 管理所有依赖
- ✅ **代码生成**：自动生成 Provider、JSON 序列化代码

## 技术栈

- **状态管理**: Riverpod (flutter_riverpod + riverpod_annotation)
- **路由管理**: GoRouter
- **网络请求**: Dio
- **数据序列化**: Freezed + JSON Serializable
- **本地存储**: Flutter Secure Storage
- **代码生成**: Build Runner

---

## 项目架构

### 整体结构

```
ltapp_flutter/
├── apps/                          # 应用层
│   ├── lt_app/                    # 主应用（壳）
│   └── algorithm_app/             # 算法学习应用
│
└── packages/                      # 共享包（按职责分层）
    ├── core/                      # 核心基础设施层
    │   ├── network/               # 网络层
    │   ├── lt_uicomponent/        # UI 组件库
    │   └── storage/               # 本地存储
    │
    ├── domain/                    # 业务逻辑层（按业务模块拆分）
    │   ├── reflection_domain/     # 反思业务领域
    │   ├── user_domain/           # 用户业务领域
    │   └── wallet_domain/         # 钱包业务领域
    │
    ├── data/                      # 数据访问层（按业务模块拆分）
    │   ├── reflection_data/       # 反思数据访问
    │   ├── user_data/             # 用户数据访问
    │   └── wallet_data/           # 钱包数据访问
    │
    ├── features/                  # 功能模块层（Presentation）
    │   ├── calendar/              # 日历功能
    │   ├── thread/                # Thread 问题列表
    │   ├── today_question/        # 今日问题
    │   ├── add_answer/            # 添加答案
    │   ├── answer_detail/         # 答案详情
    │   ├── copilot/               # AI 助手
    │   ├── user/                  # 用户中心
    │   └── wallet/                # 钱包功能
    │
    └── utls/                      # 工具层
        ├── date_utl/              # 日期工具
        └── lt_annotation/         # 自定义注解
```

### Clean Architecture 分层详解

```
┌─────────────────────────────────────────────────────────────┐
│                     Apps Layer                              │
│                  (应用入口 - 壳)                             │
│              apps/lt_app, apps/algorithm_app                │
└─────────────────────────────────────────────────────────────┘
                            ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│                  Features Layer                             │
│              (功能模块 - Presentation)                       │
│    packages/features/* (Page, Controller, State)            │
│    - 包含 UI 页面和状态管理                                  │
│    - 创建自己需要的 UseCase Providers                        │
└─────────────────────────────────────────────────────────────┘
                            ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│                   Domain Layer                              │
│                (业务逻辑 - 纯 Dart)                          │
│         packages/domain/* (按业务模块拆分)                   │
│    - Entities: 业务实体（纯 Dart 类）                        │
│    - Repository Interfaces: 仓储接口                         │
│    - UseCases: 业务用例（封装业务逻辑）                       │
└─────────────────────────────────────────────────────────────┘
                            ↑ 实现接口
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│                 (数据访问实现)                               │
│          packages/data/* (按业务模块拆分)                    │
│    - Models: 数据模型（DTO，支持 JSON 序列化）               │
│    - Repository Implementations: 仓储实现                    │
│    - DataSources: 数据源（Remote/Local）                    │
│    - Providers: Repository & DataSource Providers           │
└─────────────────────────────────────────────────────────────┘
                            ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│                    Core Layer                               │
│                  (基础设施)                                  │
│              packages/core/*                                │
│    - Network: API 客户端、拦截器                             │
│    - Storage: 本地存储                                       │
│    - UI Components: 通用 UI 组件                             │
│    - Providers: Infrastructure Providers                    │
└─────────────────────────────────────────────────────────────┘
```

### 依赖规则

1. **依赖方向**：单向向内，外层依赖内层，内层不依赖外层
2. **Domain 层独立**：纯 Dart 代码，不依赖 Flutter 框架
3. **接口在 Domain**：Repository 接口定义在 Domain 层
4. **实现在 Data**：Repository 实现在 Data 层
5. **Provider 分布**：
   - Core Layer: Infrastructure Providers (apiClient, tokenStorage)
   - Data Layer: Repository & DataSource Providers
   - Features Layer: UseCase Providers (每个 Feature 创建自己需要的)

---

## 分层详解

### 1. Core Layer（基础设施层）

提供与框架和平台相关的基础设施服务。

```
packages/core/
├── network/                       # 网络层
│   ├── api_client.dart            # API 客户端接口
│   ├── http_api_client.dart       # Dio 实现
│   ├── auth_interceptor.dart      # 认证拦截器
│   ├── refresh_token_interceptor.dart  # Token 刷新
│   ├── app_exception.dart         # 统一异常处理
│   └── network_provider.dart      # Network Providers
│
├── lt_uicomponent/                # UI 组件库
│   ├── theme/                     # 主题配置
│   │   ├── app_style.dart         # 文字样式
│   │   ├── theme.dart             # 主题定义
│   │   └── icon_name.dart         # 图标名称
│   ├── widgets/                   # 通用组件
│   └── image_processor/           # 图片处理
│
└── storage/                       # 本地存储
    └── secure_token_storage.dart  # Token 安全存储
```

**职责**：
- 网络请求封装
- 本地存储
- UI 组件库
- 平台相关功能

**依赖**：无（最底层）

### 2. Domain Layer（业务逻辑层）

纯 Dart 代码，包含业务实体、业务规则和业务用例。按业务领域模块化拆分。

#### 2.1 Reflection Domain（反思业务领域）

```
packages/domain/reflection_domain/
├── lib/
│   ├── src/
│   │   ├── entities/              # 业务实体
│   │   │   ├── answer_entity.dart
│   │   │   ├── question_entity.dart
│   │   │   ├── calendar_entity.dart
│   │   │   ├── category_entity.dart
│   │   │   └── icon_entity.dart
│   │   │
│   │   ├── repositories/          # 仓储接口
│   │   │   └── reflection_repository.dart
│   │   │
│   │   └── usecases/              # 业务用例
│   │       ├── fetch_thread_questions.dart
│   │       ├── fetch_today_question.dart
│   │       ├── fetch_calendar_reflections.dart
│   │       ├── submit_answer.dart
│   │       └── fetch_answer_detail.dart
│   │
│   └── reflection_domain.dart     # 导出文件
│
└── pubspec.yaml
```

**Entity 示例**：
```dart
/// 答案实体（纯业务对象）
class AnswerEntity {
  final String id;
  final String content;
  final String createdYmd;
  final IconEntity? icon;
  final QuestionEntity? question;

  const AnswerEntity({
    required this.id,
    required this.content,
    required this.createdYmd,
    this.icon,
    this.question,
  });
}
```

**Repository 接口示例**：
```dart
/// 反思仓储接口（定义契约）
abstract interface class ReflectionRepository {
  Future<List<QuestionEntity>> FetchThreadQuestionsUseCase();
  Future<QuestionEntity> fetchTodayQuestion();
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });
  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });
  Future<AnswerEntity> fetchAnswerDetail(String answerId);
}
```

**UseCase 示例**：
```dart
/// 获取 Thread 问题列表的用例接口
abstract interface class FetchThreadQuestionsUseCaseType {
  Future<List<QuestionEntity>> call();
}

/// 获取 Thread 问题列表的用例实现
class FetchThreadQuestionsUseCase implements FetchThreadQuestionsUseCaseType {
  final ReflectionRepository _repository;

  const FetchThreadQuestionsUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> call() async {
    return await _repository.FetchThreadQuestionsUseCase();
  }
}
```

#### 2.2 User Domain（用户业务领域）

```
packages/domain/user_domain/
├── lib/src/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
│       ├── get_current_user.dart
│       └── logout.dart
└── pubspec.yaml
```

#### 2.3 Wallet Domain（钱包业务领域）

```
packages/domain/wallet_domain/
├── lib/src/
│   ├── entities/
│   │   ├── wallet_entity.dart
│   │   └── transaction_entity.dart
│   ├── repositories/
│   │   └── wallet_repository.dart
│   └── usecases/
│       ├── get_wallet.dart
│       └── get_transactions.dart
└── pubspec.yaml
```

**职责**：
- 定义业务实体（Entity）
- 定义业务规则（UseCase）
- 定义数据访问接口（Repository Interface）
- 纯业务逻辑，不包含任何框架依赖

**依赖**：无（纯 Dart）

### 3. Data Layer（数据访问层）

实现 Domain 层定义的 Repository 接口，处理数据的获取和存储。按业务领域模块化拆分。

#### 3.1 Reflection Data（反思数据访问）

```
packages/data/reflection_data/
├── lib/
│   ├── src/
│   │   ├── models/                # 数据模型（DTO）
│   │   │   ├── answer_model.dart
│   │   │   ├── question_model.dart
│   │   │   ├── calendar_model.dart
│   │   │   ├── category_model.dart
│   │   │   └── icon_model.dart
│   │   │
│   │   ├── datasources/           # 数据源
│   │   │   └── remote/
│   │   │       └── reflection_remote_datasource.dart
│   │   │
│   │   ├── repositories/          # 仓储实现
│   │   │   └── reflection_repository_impl.dart
│   │   │
│   │   └── providers/             # Providers
│   │       └── reflection_providers.dart
│   │
│   └── reflection_data.dart       # 导出文件
│
└── pubspec.yaml
```

**Model 示例**（DTO - Data Transfer Object）：
```dart
@freezed
@ltDeserialization
class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required String id,
    required String content,
    required String createdYmd,
    IconModel? icon,
    QuestionModel? question,
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  /// DTO → Entity 转换
  AnswerEntity toEntity() {
    return AnswerEntity(
      id: id,
      content: content,
      createdYmd: createdYmd,
      icon: icon?.toEntity(),
      question: question?.toEntity(),
    );
  }

  /// Entity → DTO 转换
  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(
      id: entity.id,
      content: entity.content,
      createdYmd: entity.createdYmd,
      icon: entity.icon != null ? IconModel.fromEntity(entity.icon!) : null,
      question: entity.question != null 
          ? QuestionModel.fromEntity(entity.question!) 
          : null,
    );
  }
}
```

**DataSource 示例**：
```dart
/// 反思远程数据源接口
abstract interface class ReflectionRemoteDataSource {
  Future<List<QuestionModel>> FetchThreadQuestionsUseCase();
  Future<QuestionModel> fetchTodayQuestion();
  Future<List<CalendarDayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });
  Future<AnswerModel> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });
}

/// 反思远程数据源实现
class ReflectionRemoteDataSourceImpl implements ReflectionRemoteDataSource {
  final ApiClientType _apiClient;

  const ReflectionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<QuestionModel>> FetchThreadQuestionsUseCase() async {
    final response = await _apiClient.get('/api/thread-view');
    return (response['data'] as List)
        .map((e) => QuestionModel.fromJson(e))
        .toList();
  }
  
  // ... 其他方法实现
}
```

**Repository 实现示例**：
```dart
/// 反思仓储实现
class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _remoteDataSource;

  const ReflectionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<QuestionEntity>> FetchThreadQuestionsUseCase() async {
    final models = await _remoteDataSource.FetchThreadQuestionsUseCase();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    final model = await _remoteDataSource.submitAnswer(
      questionId: questionId,
      content: content,
      iconId: iconId,
    );
    return model.toEntity();
  }
  
  // ... 其他方法实现
}
```

**Data Layer Providers**：
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';

part 'reflection_providers.g.dart';

/// DataSource Provider
@riverpod
ReflectionRemoteDataSource reflectionRemoteDataSource(
  ReflectionRemoteDataSourceRef ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
}

/// Repository Provider
@riverpod
ReflectionRepository reflectionRepository(
  ReflectionRepositoryRef ref,
) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
}
```

#### 3.2 User Data & Wallet Data

结构与 Reflection Data 类似，分别处理用户和钱包相关的数据访问。

**职责**：
- 实现 Repository 接口
- 定义数据模型（Model/DTO）
- 处理数据源（Remote/Local）
- JSON 序列化/反序列化
- Entity ↔ Model 转换
- 提供 Repository 和 DataSource Providers

**依赖**：Domain Layer, Core Layer

### 4. Features Layer（功能模块层 - Presentation）

包含 UI 页面、状态管理和 UseCase Providers。每个功能模块独立封装。

```
packages/features/
├── calendar/                      # 日历功能
│   ├── lib/src/
│   │   ├── calendar_page.dart     # UI 页面
│   │   ├── calendar_controller.dart  # 状态管理
│   │   ├── calendar_month_view.dart  # 子组件
│   │   └── providers/
│   │       └── calendar_providers.dart  # UseCase Providers
│   └── pubspec.yaml
│
├── thread/                        # Thread 问题列表
├── today_question/                # 今日问题
├── add_answer/                    # 添加答案
├── answer_detail/                 # 答案详情
├── copilot/                       # AI 助手
├── user/                          # 用户中心
└── wallet/                        # 钱包功能
```

**Controller 示例**（状态管理）：
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:reflection_data/reflection_data.dart';
import 'providers/calendar_providers.dart';

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  CalendarState build() {
    final now = DateTime.now();
    _fetchCalendarData(now);
    return CalendarState(
      focusedMonth: now,
      selectedDate: now,
    );
  }

  Future<void> _fetchCalendarData(DateTime month) async {
    // 从 Feature 自己的 Provider 获取 UseCase
    final useCase = ref.read(fetchCalendarReflectionsProvider);
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    try {
      final entities = await useCase(start: start, end: end);
      // 更新状态...
    } catch (e, stack) {
      // 错误处理...
    }
  }
}
```

**Feature UseCase Providers**：
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

/// Calendar Feature 创建自己需要的 UseCase Providers

/// 获取日历反思数据的 UseCase Provider
final fetchCalendarReflectionsProvider = Provider<FetchCalendarReflections>((
  ref,
) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchCalendarReflectionsImpl(repository);
});

/// 获取今日问题的 UseCase Provider
final fetchTodayQuestionProvider = Provider<FetchTodayQuestion>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionImpl(repository);
});
```

**职责**：
- UI 页面（Page/Widget）
- 状态管理（Controller）
- 创建自己需要的 UseCase Providers
- 用户交互逻辑

**依赖**：Domain Layer, Data Layer, Core Layer

**重要说明**：
- 每个 Feature 只创建自己需要的 UseCase Providers
- 避免创建不使用的 Providers
- 通过 Data Layer 的 Repository Provider 获取 Repository 实例

### 5. Apps Layer（应用层）

应用入口，聚合所有功能模块。

```
apps/lt_app/
├── lib/
│   ├── main.dart                  # 应用入口
│   ├── src/
│   │   ├── app_router.dart        # 路由配置
│   │   ├── home_view.dart         # 主页
│   │   └── di/                    # 依赖注入（可选）
│   │       ├── infrastructure_providers.dart
│   │       └── providers.dart
│   └── examples/                  # 示例代码
└── pubspec.yaml
```

**main.dart 示例**：
```dart
void main() {
  runApp(
    const ProviderScope(
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFDF8),
      ),
    );
  }
}
```

**职责**：
- 应用启动和初始化
- 全局路由配置
- 依赖注入容器（ProviderScope）
- 聚合功能模块

**依赖**：Features Layer, Core Layer

---

## 数据流向

### 完整的数据流

```
用户操作
    ↓
UI (Widget/Page)
    ↓
Controller (Riverpod StateNotifier)
    ↓ ref.read(useCaseProvider)
UseCase (Business Logic - Domain Layer)
    ↓ repository.fetchXXX()
Repository Interface (Domain Layer)
    ↑ implements
Repository Implementation (Data Layer)
    ↓ dataSource.fetchXXX()
DataSource (Remote/Local - Data Layer)
    ↓ apiClient.get/post()
API Client (Core Layer)
    ↓ HTTP Request
Backend API
```

### Provider 依赖链

```
Feature UseCase Provider (Features Layer)
    ↓ ref.watch(repositoryProvider)
Repository Provider (Data Layer)
    ↓ ref.watch(dataSourceProvider)
DataSource Provider (Data Layer)
    ↓ ref.watch(apiClientProvider)
API Client Provider (Core Layer)
    ↓ ref.watch(tokenStorageProvider)
Token Storage Provider (Core Layer)
```

### 状态更新流程

```dart
// 1. Controller 从 Feature 的 Provider 获取 UseCase
final useCase = ref.read(FetchThreadQuestionsUseCaseProvider);

// 2. 调用 UseCase（返回 Entity）
final entities = await useCase.execute();

// 3. 更新状态
state = state.copyWith(
  questions: AsyncValue.data(entities),
);

// 4. UI 自动响应（通过 ref.watch）
ref.watch(threadControllerProvider).questions.when(
  loading: () => CircularProgressIndicator(),
  data: (entities) => ListView(...),
  error: (e, s) => ErrorWidget(e),
)
```

---

## Provider 分布策略

### 1. Core Layer Providers

**位置**：`packages/core/network/lib/network/network_provider.dart`

```dart
// Infrastructure Providers
final tokenStorageProvider = Provider<TokenStorageType>(
  (ref) => MockTokenStorage(),
);

final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});
```

**职责**：提供基础设施服务（API Client, Storage 等）

### 2. Data Layer Providers

**位置**：`packages/data/*/lib/src/providers/*_providers.dart`

```dart
// DataSource Provider
@riverpod
ReflectionRemoteDataSource reflectionRemoteDataSource(
  ReflectionRemoteDataSourceRef ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
}

// Repository Provider
@riverpod
ReflectionRepository reflectionRepository(
  ReflectionRepositoryRef ref,
) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
}
```

**职责**：提供 Repository 和 DataSource 实例

### 3. Features Layer Providers

**位置**：`packages/features/*/lib/src/providers/*_providers.dart`

```dart
// UseCase Providers（每个 Feature 只创建自己需要的）
final fetchCalendarReflectionsProvider = Provider<FetchCalendarReflections>((
  ref,
) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchCalendarReflectionsImpl(repository);
});
```

**职责**：创建 Feature 需要的 UseCase 实例

**重要原则**：
- ✅ 每个 Feature 只创建自己需要的 UseCase Providers
- ✅ 避免在 Data Layer 创建所有 UseCase Providers
- ✅ 保持 Provider 的按需创建原则

---

## 模块化设计

### 按业务领域拆分

每个业务领域都有独立的 Domain 和 Data 包：

| 业务领域 | Domain 包 | Data 包 | 说明 |
|---------|----------|---------|------|
| 反思 | reflection_domain | reflection_data | 问题、答案、日历等 |
| 用户 | user_domain | user_data | 用户信息、登录登出 |
| 钱包 | wallet_domain | wallet_data | 钱包、交易记录 |

### 模块独立性

```
reflection_domain (纯 Dart)
    ↑ 实现接口
reflection_data (依赖 reflection_domain + core)
    ↑ 使用
calendar feature (依赖 reflection_domain + reflection_data)
```

**优势**：
- ✅ 高内聚低耦合
- ✅ 独立开发和测试
- ✅ 可复用性强
- ✅ 易于维护和扩展

---

## 核心设计模式

### 1. Repository 模式

**目的**：隔离数据源，提供统一的数据访问接口

```dart
// Domain Layer - 定义接口
abstract interface class ReflectionRepository {
  Future<List<QuestionEntity>> FetchThreadQuestionsUseCase();
}

// Data Layer - 实现接口
class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _remoteDataSource;
  
  @override
  Future<List<QuestionEntity>> FetchThreadQuestionsUseCase() async {
    final models = await _remoteDataSource.FetchThreadQuestionsUseCase();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

### 2. UseCase 模式

**目的**：封装业务逻辑，单一职责

```dart
// 每个 UseCase 只做一件事
abstract interface class FetchThreadQuestionsUseCaseType {
  Future<List<QuestionEntity>> call();
}

class FetchThreadQuestionsUseCase implements FetchThreadQuestionsUseCaseType {
  final ReflectionRepository _repository;
  
  const FetchThreadQuestionsUseCase(this._repository);
  
  @override
  Future<List<QuestionEntity>> call() async {
    return await _repository.FetchThreadQuestionsUseCase();
  }
}
```

### 3. Dependency Injection（依赖注入）

**目的**：解耦依赖，便于测试

```dart
// 使用 Riverpod 进行依赖注入
@riverpod
ReflectionRepository reflectionRepository(
  ReflectionRepositoryRef ref,
) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
}

// Controller 中使用
final useCase = ref.read(FetchThreadQuestionsUseCaseProvider);
```

### 4. Entity-Model 转换

**目的**：分离业务实体和数据模型

```dart
// Model (DTO) - 支持 JSON 序列化
@freezed
class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required String id,
    required String content,
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  // DTO → Entity
  AnswerEntity toEntity() {
    return AnswerEntity(id: id, content: content);
  }

  // Entity → DTO
  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(id: entity.id, content: entity.content);
  }
}
```

---

## 开发指南

## 开发指南

### 自动化脚本

项目提供了一套 Dart 脚本工具来简化日常开发任务，位于 `shell/` 目录。

#### 快速开始

```bash
# 使用 Makefile（推荐）
make setup      # 安装所有依赖
make clean      # 清理构建产物
make codegen    # 运行代码生成
make watch      # 监听模式代码生成
make reset      # 完整重置（清理+安装+生成）

# 或直接使用 Dart 脚本
dart shell/bin/setup.dart
dart shell/bin/clean.dart
dart shell/bin/codegen.dart
dart shell/bin/codegen.dart --watch
```

详细文档请查看 [shell/README.md](shell/README.md)

### 代码生成

```bash
# 为所有 Data 包生成代码
cd packages/data/reflection_data
flutter pub run build_runner build --delete-conflicting-outputs

# 为所有 Feature 包生成代码
cd packages/features/calendar
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式（开发时推荐）
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 添加新功能模块

#### 1. 创建 Domain 包

```bash
cd packages/domain
mkdir my_feature_domain
cd my_feature_domain
flutter create --template=package .
```

**目录结构**：
```
my_feature_domain/
├── lib/
│   ├── src/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   └── my_feature_domain.dart
└── pubspec.yaml
```

#### 2. 创建 Data 包

```bash
cd packages/data
mkdir my_feature_data
cd my_feature_data
flutter create --template=package .
```

**目录结构**：
```
my_feature_data/
├── lib/
│   ├── src/
│   │   ├── models/
│   │   ├── datasources/
│   │   ├── repositories/
│   │   └── providers/
│   └── my_feature_data.dart
└── pubspec.yaml
```

**pubspec.yaml 添加依赖**：
```yaml
dependencies:
  # Domain dependency
  my_feature_domain:
    path: ../../domain/my_feature_domain
  
  # Core dependencies
  lt_network:
    path: ../../core/network
  
  # Code generation
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0
  riverpod_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^3.2.3
  json_serializable: ^6.11.2
  riverpod_generator: ^4.0.0+1
```

#### 3. 创建 Feature 包

```bash
cd packages/features
mkdir my_feature
cd my_feature
flutter create --template=package .
```

**pubspec.yaml 添加依赖**：
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.1.0
  riverpod_annotation: ^4.0.0
  
  # Domain & Data dependencies
  my_feature_domain:
    path: ../../domain/my_feature_domain
  my_feature_data:
    path: ../../data/my_feature_data
  
  # Core dependencies
  lt_uicomponent:
    path: ../../core/lt_uicomponent

dev_dependencies:
  build_runner: ^2.4.8
  riverpod_generator: ^4.0.0+1
```

#### 4. 在 App 中注册

**apps/lt_app/pubspec.yaml**：
```yaml
dependencies:
  my_feature:
    path: ../../packages/features/my_feature
```

**apps/lt_app/lib/src/app_router.dart**：
```dart
import 'package:my_feature/my_feature.dart';

// 添加路由
GoRoute(
  path: '/my-feature',
  builder: (context, state) => const MyFeaturePage(),
),
```

### 测试策略

#### 1. Domain Layer 测试（单元测试）

```dart
// test/usecases/fetch_thread_questions_test.dart
void main() {
  late MockReflectionRepository mockRepository;
  late FetchThreadQuestionsUseCase useCase;

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = FetchThreadQuestionsUseCase(mockRepository);
  });

  test('should return list of questions from repository', () async {
    // Arrange
    final questions = [
      QuestionEntity(id: '1', title: 'Test Question'),
    ];
    when(mockRepository.FetchThreadQuestionsUseCase())
        .thenAnswer((_) async => questions);

    // Act
    final result = await useCase();

    // Assert
    expect(result, questions);
    verify(mockRepository.FetchThreadQuestionsUseCase()).called(1);
  });
}
```

#### 2. Data Layer 测试（集成测试）

```dart
// test/repositories/reflection_repository_impl_test.dart
void main() {
  late MockReflectionRemoteDataSource mockDataSource;
  late ReflectionRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockReflectionRemoteDataSource();
    repository = ReflectionRepositoryImpl(mockDataSource);
  });

  test('should return entities when datasource call is successful', () async {
    // Arrange
    final models = [
      QuestionModel(id: '1', title: 'Test'),
    ];
    when(mockDataSource.FetchThreadQuestionsUseCase())
        .thenAnswer((_) async => models);

    // Act
    final result = await repository.FetchThreadQuestionsUseCase();

    // Assert
    expect(result, isA<List<QuestionEntity>>());
    expect(result.length, 1);
    expect(result[0].id, '1');
  });
}
```

#### 3. Features Layer 测试（Widget 测试）

```dart
// test/calendar_page_test.dart
void main() {
  testWidgets('should display calendar when data is loaded', (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        fetchCalendarReflectionsProvider.overrideWith(
          (ref) => MockFetchCalendarReflections(),
        ),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: CalendarPage()),
      ),
    );

    // Assert
    expect(find.byType(CalendarMonthView), findsOneWidget);
  });
}
```

---

## 架构优势

### 1. 符合 SOLID 原则

- **S**ingle Responsibility: 每个类只有一个职责
- **O**pen/Closed: 对扩展开放，对修改关闭
- **L**iskov Substitution: 接口可替换实现
- **I**nterface Segregation: 接口隔离，按需定义
- **D**ependency Inversion: 依赖抽象而非具体实现

### 2. 高可测试性

- Domain Layer 纯 Dart，易于单元测试
- 接口抽象，便于 Mock
- 依赖注入，便于替换实现

### 3. 高可维护性

- 分层清晰，职责明确
- 模块化设计，独立开发
- 代码复用性高

### 4. 高扩展性

- 新增功能只需添加新模块
- 不影响现有代码
- 支持多团队并行开发

### 5. 技术栈独立

- Domain Layer 不依赖 Flutter
- 可以轻松迁移到其他平台
- 业务逻辑可复用

---

## 与标准 Clean Architecture 对比

| 方面 | 标准 Clean Architecture | 本项目实现 | 符合度 |
|------|------------------------|-----------|--------|
| **分层结构** | Presentation/Domain/Data/Framework | Features/Domain/Data/Core | ✅ 完全符合 |
| **依赖方向** | 单向向内 | 单向向内 | ✅ 完全符合 |
| **Domain 层** | 纯业务逻辑，不依赖框架 | 纯 Dart，不依赖 Flutter | ✅ 完全符合 |
| **Entity** | 独立的业务实体 | 独立的 Entity 类 | ✅ 完全符合 |
| **Repository 接口** | 定义在 Domain 层 | 定义在 Domain 层 | ✅ 完全符合 |
| **Repository 实现** | 在 Data 层 | 在 Data 层 | ✅ 完全符合 |
| **UseCase** | 在 Domain 层 | 在 Domain 层 | ✅ 完全符合 |
| **DTO** | 在 Data 层 | Model 在 Data 层 | ✅ 完全符合 |
| **依赖注入** | 使用 DI 框架 | 使用 Riverpod | ✅ 完全符合 |
| **模块化** | 按功能模块拆分 | 按业务领域拆分 | ✅ 完全符合 |

**结论**：本项目严格遵循标准 Clean Architecture 原则，实现了清晰的分层架构和依赖倒置。

---

## 常见问题

### Q1: 为什么要分 Entity 和 Model？

**A**: 
- **Entity**（Domain Layer）：纯业务对象，不包含任何框架依赖，代表业务概念
- **Model**（Data Layer）：数据传输对象（DTO），支持 JSON 序列化，用于网络传输

这样做的好处：
- Domain Layer 保持纯净，不依赖任何框架
- 业务逻辑不受数据格式变化影响
- 便于单元测试

### Q2: 为什么 UseCase 要单独封装？

**A**: 
- 单一职责原则：每个 UseCase 只做一件事
- 便于测试：可以独立测试业务逻辑
- 便于复用：多个 Controller 可以共享同一个 UseCase
- 便于维护：业务逻辑集中管理

### Q3: Provider 为什么要分层？

**A**: 
- **Core Layer Providers**: 基础设施服务，全局共享
- **Data Layer Providers**: Repository 和 DataSource，按业务模块提供
- **Features Layer Providers**: UseCase，按需创建，避免冗余

这样做避免了循环依赖，保持了清晰的依赖方向。

### Q4: 如何处理跨模块依赖？

**A**: 
- 通过 Domain Layer 的接口进行通信
- 避免 Feature 之间直接依赖
- 使用事件总线或状态管理进行解耦

### Q5: 为什么不把所有 UseCase Providers 放在 Data Layer？

**A**: 
- 避免创建不使用的 Providers
- 保持按需创建原则
- 每个 Feature 只创建自己需要的 UseCase
- 减少不必要的依赖

---

## 相关文档

- [Clean Architecture 重构文档](.kiro/specs/clean-architecture-refactoring/)
- [Provider 策略文档](.kiro/specs/clean-architecture-refactoring/PROVIDER_STRATEGY_FINAL.md)
- [模块化架构文档](.kiro/specs/clean-architecture-refactoring/MODULAR_ARCHITECTURE.md)
- [共享依赖管理](docs/shared-dependencies.md)

---

## 项目状态

- ✅ Core Layer 完成
- ✅ Domain Layer 完成（reflection, user, wallet）
- ✅ Data Layer 完成（reflection, user, wallet）
- ✅ Features Layer 完成（calendar, thread, today_question, add_answer, answer_detail, user, wallet, copilot）
- ✅ Apps Layer 完成
- ✅ Provider 分层完成
- ✅ 代码生成配置完成

---

## 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 许可证

本项目采用 MIT 许可证。

---

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。

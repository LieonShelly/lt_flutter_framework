# 模块化 Clean Architecture 架构文档

## 🎯 架构概述

我们已经将 Clean Architecture 重构为完全模块化的结构，每个业务模块都有独立的 Domain 和 Data 包。

## 📦 新的包结构

```
packages/
├── domain/                          # Domain Layer（按业务模块拆分）
│   ├── reflection_domain/           # 反思业务模块
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── entities/        # 业务实体
│   │   │   │   │   ├── question_entity.dart
│   │   │   │   │   ├── answer_entity.dart
│   │   │   │   │   ├── calendar_entity.dart
│   │   │   │   │   ├── category_entity.dart
│   │   │   │   │   └── icon_entity.dart
│   │   │   │   ├── repositories/    # Repository 接口
│   │   │   │   │   └── reflection_repository.dart
│   │   │   │   └── usecases/        # UseCase
│   │   │   │       ├── fetch_thread_questions.dart
│   │   │   │       ├── fetch_today_question.dart
│   │   │   │       ├── fetch_calendar_reflections.dart
│   │   │   │       ├── submit_answer.dart
│   │   │   │       └── fetch_answer_detail.dart
│   │   │   └── reflection_domain.dart
│   │   └── pubspec.yaml
│   │
│   ├── user_domain/                 # 用户业务模块
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── user_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_current_user.dart
│   │   │   │       ├── update_profile.dart
│   │   │   │       └── logout.dart
│   │   │   └── user_domain.dart
│   │   └── pubspec.yaml
│   │
│   └── wallet_domain/               # 钱包业务模块
│       ├── lib/
│       │   ├── src/
│       │   │   ├── entities/
│       │   │   │   └── wallet_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── wallet_repository.dart
│       │   │   └── usecases/
│       │   │       ├── get_wallet.dart
│       │   │       └── get_transactions.dart
│       │   └── wallet_domain.dart
│       └── pubspec.yaml
│
├── data/                            # Data Layer（按业务模块拆分）
│   ├── reflection_data/             # 反思数据模块
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── models/          # DTO
│   │   │   │   │   ├── question_model.dart
│   │   │   │   │   ├── answer_model.dart
│   │   │   │   │   ├── calendar_model.dart
│   │   │   │   │   ├── category_model.dart
│   │   │   │   │   └── icon_model.dart
│   │   │   │   ├── datasources/     # 数据源
│   │   │   │   │   └── remote/
│   │   │   │   │       └── reflection_remote_datasource.dart
│   │   │   │   └── repositories/    # Repository 实现
│   │   │   │       └── reflection_repository_impl.dart
│   │   │   └── reflection_data.dart
│   │   └── pubspec.yaml
│   │
│   ├── user_data/                   # 用户数据模块
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── remote/
│   │   │   │   │       └── user_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── user_repository_impl.dart
│   │   │   └── user_data.dart
│   │   └── pubspec.yaml
│   │
│   └── wallet_data/                 # 钱包数据模块
│       ├── lib/
│       │   ├── src/
│       │   │   ├── models/
│       │   │   │   └── wallet_model.dart
│       │   │   ├── datasources/
│       │   │   │   └── remote/
│       │   │   │       └── wallet_remote_datasource.dart
│       │   │   └── repositories/
│       │   │       └── wallet_repository_impl.dart
│       │   └── wallet_data.dart
│       └── pubspec.yaml
│
├── features/                        # Presentation Layer
│   ├── calendar/
│   ├── thread/
│   ├── today_question/
│   └── ...
│
└── core/                            # Infrastructure Layer
    ├── network/
    ├── storage/
    └── lt_uicomponent/
```

---

## 🔄 依赖关系

### 模块化依赖图

```
┌─────────────────────────────────────────────────────────────┐
│ Apps (lt_app)                                               │
│ - 依赖所有 domain 和 data 模块                               │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Features (calendar, thread, ...)                            │
│ - 依赖对应的 domain 模块                                     │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌──────────────────────┐    ┌──────────────────────┐
│ Domain Modules       │    │ Core                 │
│ - reflection_domain  │    │ - UI Components      │
│ - user_domain        │    │ - Theme              │
│ - wallet_domain      │    └──────────────────────┘
└──────────────────────┘
         ↑ 实现
┌─────────────────────────────────────────────────────────────┐
│ Data Modules                                                │
│ - reflection_data (依赖 reflection_domain)                  │
│ - user_data (依赖 user_domain)                              │
│ - wallet_data (依赖 wallet_domain)                          │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Core                                                        │
│ - Network (ApiClient)                                       │
│ - Storage                                                   │
└─────────────────────────────────────────────────────────────┘
```

### 具体依赖关系

**Reflection Domain**
- 依赖：无（纯 Dart）
- 被依赖：reflection_data, calendar, thread, today_question, add_answer, answer_detail

**Reflection Data**
- 依赖：reflection_domain, lt_network, lt_annotation
- 被依赖：apps/lt_app

**User Domain**
- 依赖：无（纯 Dart）
- 被依赖：user_data, user feature

**User Data**
- 依赖：user_domain, lt_network, lt_annotation
- 被依赖：apps/lt_app

**Wallet Domain**
- 依赖：无（纯 Dart）
- 被依赖：wallet_data, wallet feature

**Wallet Data**
- 依赖：wallet_domain, lt_network, lt_annotation
- 被依赖：apps/lt_app

---

## 💡 模块化的优势

### 1. 独立开发和测试

每个业务模块都是独立的包，可以：
- 独立开发
- 独立测试
- 独立版本管理
- 独立发布（如果需要）

### 2. 清晰的职责边界

```dart
// Reflection Domain - 只关心反思业务逻辑
reflection_domain/
  ├── entities/      # 反思相关的实体
  ├── repositories/  # 反思相关的接口
  └── usecases/      # 反思相关的用例

// Reflection Data - 只关心反思数据访问
reflection_data/
  ├── models/        # 反思相关的 DTO
  ├── datasources/   # 反思相关的数据源
  └── repositories/  # 反思相关的实现
```

### 3. 更好的可维护性

- 修改反思功能，只需要关注 `reflection_domain` 和 `reflection_data`
- 修改用户功能，只需要关注 `user_domain` 和 `user_data`
- 不会影响其他业务模块

### 4. 更容易扩展

添加新的业务模块（如 Payment）：
```
1. 创建 packages/domain/payment_domain/
2. 创建 packages/data/payment_data/
3. 在 apps/lt_app 中添加依赖
4. 创建对应的 feature
```

### 5. 更小的依赖范围

**之前（单一 domain_layer）**：
```yaml
# calendar feature 依赖
dependencies:
  domain_layer:  # 包含所有业务逻辑（reflection + user + wallet）
```

**现在（模块化）**：
```yaml
# calendar feature 依赖
dependencies:
  reflection_domain:  # 只包含反思业务逻辑
```

---

## 📝 使用示例

### 在 Feature 中使用

```dart
// packages/features/calendar/pubspec.yaml
dependencies:
  reflection_domain:
    path: ../../domain/reflection_domain

// packages/features/calendar/lib/src/calendar_controller.dart
import 'package:reflection_domain/reflection_domain.dart';

@riverpod
class CalendarController extends _$CalendarController {
  Future<void> _fetchCalendarData(DateTime month) async {
    // 使用 reflection_domain 的 UseCase
    final fetchReflections = ref.read(fetchCalendarReflectionsProvider);
    
    final reflections = await fetchReflections(
      start: start,
      end: end,
    );
    
    // 使用 reflection_domain 的 Entity
    final reflectionMap = <String, CalendarDayEntity>{};
    for (final day in reflections) {
      reflectionMap[day.date] = day;
    }
  }
}
```

### 在 Apps 中配置依赖注入

```dart
// apps/lt_app/lib/src/di/providers.dart
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';
import 'package:user_domain/user_domain.dart';
import 'package:user_data/user_data.dart';
import 'package:wallet_domain/wallet_domain.dart';
import 'package:wallet_data/wallet_data.dart';

// Reflection Module
final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
});

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});

final fetchThreadQuestionsProvider = Provider<FetchThreadQuestions>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchThreadQuestionsImpl(repository);
});

// User Module
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});

final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetCurrentUserImpl(repository);
});

// Wallet Module
// ... 类似的配置
```

---

## 🔧 添加新业务模块的步骤

### 示例：添加 Payment 模块

**1. 创建 Domain 模块**

```bash
# 创建目录结构
mkdir -p packages/domain/payment_domain/lib/src/{entities,repositories,usecases}

# 创建 pubspec.yaml
cat > packages/domain/payment_domain/pubspec.yaml << EOF
name: payment_domain
description: Payment domain layer
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  equatable: ^2.0.5
EOF

# 创建实体
cat > packages/domain/payment_domain/lib/src/entities/payment_entity.dart << EOF
class PaymentEntity {
  final String id;
  final double amount;
  final String status;
  
  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.status,
  });
}
EOF

# 创建 Repository 接口
cat > packages/domain/payment_domain/lib/src/repositories/payment_repository.dart << EOF
import '../entities/entities.dart';

abstract interface class PaymentRepository {
  Future<PaymentEntity> createPayment(double amount);
  Future<List<PaymentEntity>> getPayments();
}
EOF

# 创建 UseCase
cat > packages/domain/payment_domain/lib/src/usecases/create_payment.dart << EOF
import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class CreatePayment {
  Future<PaymentEntity> call(double amount);
}

class CreatePaymentImpl implements CreatePayment {
  final PaymentRepository _repository;
  
  const CreatePaymentImpl(this._repository);
  
  @override
  Future<PaymentEntity> call(double amount) async {
    if (amount <= 0) {
      throw ArgumentError('金额必须大于 0');
    }
    return await _repository.createPayment(amount);
  }
}
EOF
```

**2. 创建 Data 模块**

```bash
# 创建目录结构
mkdir -p packages/data/payment_data/lib/src/{models,datasources/remote,repositories}

# 创建 pubspec.yaml
cat > packages/data/payment_data/pubspec.yaml << EOF
name: payment_data
description: Payment data layer
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  payment_domain:
    path: ../../domain/payment_domain
  lt_network:
    path: ../../core/network
  freezed_annotation: ^3.1.0
  json_annotation: ^4.9.0
  lt_annotation:
    path: ../../utls/lt_annotation

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^3.2.3
  json_serializable: ^6.8.0
EOF

# 创建 Model
# 创建 DataSource
# 创建 Repository 实现
```

**3. 在 Apps 中添加依赖**

```yaml
# apps/lt_app/pubspec.yaml
dependencies:
  payment_domain:
    path: ../../packages/domain/payment_domain
  payment_data:
    path: ../../packages/data/payment_data
```

**4. 配置依赖注入**

```dart
// apps/lt_app/lib/src/di/providers.dart
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSourceImpl(apiClient);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(dataSource);
});

final createPaymentProvider = Provider<CreatePayment>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return CreatePaymentImpl(repository);
});
```

---

## 📊 对比：单一 vs 模块化

### 单一 Domain/Data Layer

```
packages/
├── domain_layer/          # 包含所有业务逻辑
│   ├── entities/          # 所有实体混在一起
│   ├── repositories/      # 所有接口混在一起
│   └── usecases/          # 所有用例混在一起
│
└── data_layer/            # 包含所有数据访问
    ├── models/            # 所有 DTO 混在一起
    ├── datasources/       # 所有数据源混在一起
    └── repositories/      # 所有实现混在一起
```

**问题**：
- ❌ 职责不清晰
- ❌ 难以独立测试
- ❌ 修改一个模块可能影响其他模块
- ❌ 依赖范围过大

### 模块化 Domain/Data Layer

```
packages/
├── domain/
│   ├── reflection_domain/  # 只包含反思业务逻辑
│   ├── user_domain/        # 只包含用户业务逻辑
│   └── wallet_domain/      # 只包含钱包业务逻辑
│
└── data/
    ├── reflection_data/    # 只包含反思数据访问
    ├── user_data/          # 只包含用户数据访问
    └── wallet_data/        # 只包含钱包数据访问
```

**优势**：
- ✅ 职责清晰
- ✅ 易于独立测试
- ✅ 修改隔离
- ✅ 依赖范围最小化

---

## 🎯 总结

模块化的 Clean Architecture 提供了：

1. **更好的可维护性**：每个业务模块独立，修改不会相互影响
2. **更清晰的职责**：每个包只关注一个业务领域
3. **更容易扩展**：添加新模块不影响现有模块
4. **更小的依赖**：Feature 只依赖需要的 Domain 模块
5. **更好的测试性**：可以独立测试每个模块

这是一个真正的模块化、可扩展、易维护的架构！

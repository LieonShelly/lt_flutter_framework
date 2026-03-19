# Clean Architecture 重构需求文档

## 项目背景

当前项目采用实用主义的分层架构，虽然借鉴了 Clean Architecture 的核心思想，但存在以下问题：

1. **命名误导**：`packages/domain` 实际是 Presentation 层，包含 UI 和 Controller
2. **缺少纯 Domain 层**：没有独立的业务实体（Entity）层
3. **Service 层职责过重**：同时承担 Domain 层和 Data 层的职责
4. **DTO 当作 Entity 使用**：数据传输对象直接作为业务实体

## 重构目标

将项目重构为标准的 Clean Architecture，实现：

1. **清晰的分层**：Presentation → Domain → Data → Infrastructure
2. **纯业务逻辑层**：Domain 层不依赖任何框架
3. **依赖倒置**：高层模块不依赖低层模块，都依赖抽象
4. **职责单一**：每一层只负责自己的职责

## 目标架构

### 分层结构

```
┌─────────────────────────────────────────────────────────────┐
│ Presentation Layer (packages/features/*)                    │
│ - UI Pages (Widgets)                                        │
│ - Controllers (Riverpod State Management)                   │
│ - View States (Freezed)                                     │
│ 依赖：Domain Layer + Infrastructure Layer                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Domain Layer (packages/domain/*)                            │
│ - Entities (纯业务实体 - 纯 Dart)                           │
│ - Repository Interfaces (抽象接口)                          │
│ - UseCases (业务逻辑封装)                                    │
│ 依赖：无（纯 Dart，不依赖任何框架）                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Data Layer (packages/data/*)                                │
│ - Models (DTO - 数据传输对象)                                │
│ - DataSources (Remote/Local)                                │
│ - Repository Implementations                                │
│ 依赖：Domain Layer + Infrastructure Layer                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Infrastructure Layer (packages/core/*)                      │
│ - Network (Dio, HTTP Client)                                │
│ - Storage (Secure Storage, Cache)                           │
│ - UI Components (Theme, Widgets)                            │
│ 依赖：Flutter Framework + Third-party Libraries             │
└─────────────────────────────────────────────────────────────┘
```

### 包结构

```
packages/
├── domain/                          # Domain Layer（新增）
│   ├── entities/                    # 业务实体
│   │   ├── question_entity.dart
│   │   ├── answer_entity.dart
│   │   ├── calendar_entity.dart
│   │   └── user_entity.dart
│   │
│   ├── repositories/                # Repository 接口
│   │   ├── reflection_repository.dart
│   │   ├── user_repository.dart
│   │   └── wallet_repository.dart
│   │
│   └── usecases/                    # UseCase
│       ├── reflection/
│       │   ├── fetch_thread_questions.dart
│       │   ├── fetch_today_question.dart
│       │   ├── fetch_calendar_reflections.dart
│       │   └── submit_answer.dart
│       ├── user/
│       └── wallet/
│
├── data/                            # Data Layer（从 service 重构）
│   ├── models/                      # DTO
│   │   ├── question_model.dart
│   │   ├── answer_model.dart
│   │   └── calendar_model.dart
│   │
│   ├── datasources/                 # 数据源
│   │   ├── remote/
│   │   │   ├── reflection_remote_datasource.dart
│   │   │   └── user_remote_datasource.dart
│   │   └── local/
│   │       └── cache_datasource.dart
│   │
│   └── repositories/                # Repository 实现
│       ├── reflection_repository_impl.dart
│       ├── user_repository_impl.dart
│       └── wallet_repository_impl.dart
│
├── features/                        # Presentation Layer（从 domain 重命名）
│   ├── calendar/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   ├── controllers/
│   │   │   └── states/
│   │   └── calendar.dart
│   │
│   ├── thread/
│   ├── today_question/
│   ├── add_answer/
│   ├── answer_detail/
│   ├── copilot/
│   ├── user/
│   └── wallet/
│
├── core/                            # Infrastructure Layer（保持不变）
│   ├── network/
│   ├── storage/
│   └── lt_uicomponent/
│
└── utls/                            # 工具层（保持不变）
```

## 重构原则

### 1. Domain Layer 原则

- **纯 Dart**：不依赖 Flutter 框架
- **不依赖外部包**：除了基础的 Dart 包（如 `equatable`）
- **业务逻辑核心**：包含所有业务规则
- **接口定义**：定义 Repository 接口，不关心实现

### 2. Data Layer 原则

- **实现 Domain 接口**：Repository 实现 Domain 层定义的接口
- **数据转换**：DTO ↔ Entity 转换
- **数据源隔离**：Remote 和 Local 数据源分离
- **依赖注入**：通过构造函数注入依赖

### 3. Presentation Layer 原则

- **只关心 UI**：不包含业务逻辑
- **调用 UseCase**：通过 UseCase 执行业务逻辑
- **状态管理**：使用 Riverpod 管理状态
- **响应式 UI**：通过 `ref.watch()` 响应状态变化

### 4. Infrastructure Layer 原则

- **框架集成**：封装第三方库
- **接口抽象**：提供抽象接口
- **可替换性**：实现可以轻松替换

## 重构范围

### 包含的模块

1. **Reflection Service** → Domain + Data
   - 日历反思
   - 今日问题
   - Thread 问题列表
   - 答案提交

2. **Feature Modules** → Features
   - calendar
   - thread
   - today_question
   - add_answer
   - answer_detail
   - copilot
   - user
   - wallet

### 不包含的模块

- `algorithm_app`（独立应用，不需要重构）
- `core/*`（基础设施层，保持不变）
- `utls/*`（工具层，保持不变）

## 成功标准

1. **编译通过**：所有代码可以正常编译
2. **功能正常**：所有功能可以正常运行
3. **测试通过**：现有测试（如果有）继续通过
4. **依赖正确**：依赖方向符合 Clean Architecture
5. **代码清晰**：职责明确，易于维护

## 风险评估

### 高风险

- **大量文件移动**：可能导致 import 错误
- **依赖关系复杂**：需要仔细处理依赖顺序

### 中风险

- **代码生成**：Freezed 和 JSON Serializable 需要重新生成
- **Provider 依赖**：Riverpod Provider 需要更新

### 低风险

- **业务逻辑不变**：只是重新组织代码结构
- **渐进式重构**：可以分步骤进行

## 时间估算

- **阶段 1**：创建新包结构（30 分钟）
- **阶段 2**：分离 Entity 和 DTO（1 小时）
- **阶段 3**：重组 Repository 和 UseCase（1.5 小时）
- **阶段 4**：重命名 features（30 分钟）
- **阶段 5**：更新依赖关系（1 小时）
- **阶段 6**：测试和修复（1 小时）

**总计**：约 5.5 小时

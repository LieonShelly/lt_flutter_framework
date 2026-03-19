# Clean Architecture 重构设计文档

## 设计概述

本文档详细说明如何将现有架构重构为标准的 Clean Architecture，包括每一层的职责、数据流向、以及具体的实现细节。

## 架构设计

### 1. Domain Layer（领域层）

**职责**：定义业务规则和业务逻辑，不依赖任何框架。

#### 1.1 Entities（业务实体）

纯 Dart 类，表示业务概念，不包含任何框架依赖。

```dart
// packages/domain/lib/entities/question_entity.dart
class QuestionEntity {
  final String id;
  final String title;
  final CategoryEntity category;
  final bool pinned;
  final CategoryEntity? subCategory;
  final List<AnswerEntity> answers;
  
  const QuestionEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.pinned,
    this.subCategory,
    required this.answers,
  });
  
  // 业务方法
  bool get hasAnswers => answers.isNotEmpty;
  bool get isAnsweredToday {
    if (answers.isEmpty) return false;
    final today = DateTime.now();
    return answers.any((a) => _isSameDay(a.createdAt, today));
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// packages/domain/lib/entities/answer_entity.dart
class AnswerEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final QuestionEntity? question;
  final IconEntity? icon;
  
  const AnswerEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    this.question,
    this.icon,
  });
}

// packages/domain/lib/entities/calendar_entity.dart
class CalendarDayEntity {
  final String date; // YYYY-MM-DD
  final List<AnswerEntity> answers;
  
  const CalendarDayEntity({
    required this.date,
    required this.answers,
  });
  
  bool get hasReflection => answers.isNotEmpty;
}

class CategoryEntity {
  final String id;
  final String name;
  final String? color;
  
  const CategoryEntity({
    required this.id,
    required this.name,
    this.color,
  });
}

class IconEntity {
  final String id;
  final String url;
  
  const IconEntity({
    required this.id,
    required this.url,
  });
}
```

#### 1.2 Repositories（仓储接口）

定义数据访问的抽象接口，不关心实现细节。

```dart
// packages/domain/lib/repositories/reflection_repository.dart
abstract interface class ReflectionRepository {
  /// 获取日历视图数据
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });
  
  /// 获取今日问题
  Future<List<QuestionEntity>> fetchTodayQuestions();
  
  /// 获取 Thread 问题列表
  Future<List<QuestionEntity>> fetchThreadQuestions();
  
  /// 提交答案
  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });
  
  /// 获取答案详情
  Future<AnswerEntity> fetchAnswerDetail(String answerId);
}

// packages/domain/lib/repositories/user_repository.dart
abstract interface class UserRepository {
  Future<UserEntity> getCurrentUser();
  Future<void> updateProfile(UserEntity user);
  Future<void> logout();
}

// packages/domain/lib/repositories/wallet_repository.dart
abstract interface class WalletRepository {
  Future<WalletEntity> getWallet();
  Future<List<TransactionEntity>> getTransactions();
}
```

#### 1.3 UseCases（用例）

封装业务逻辑，每个 UseCase 负责一个具体的业务操作。

```dart
// packages/domain/lib/usecases/reflection/fetch_thread_questions.dart
abstract interface class FetchThreadQuestions {
  Future<List<QuestionEntity>> call();
}

class FetchThreadQuestionsImpl implements FetchThreadQuestions {
  final ReflectionRepository _repository;
  
  const FetchThreadQuestionsImpl(this._repository);
  
  @override
  Future<List<QuestionEntity>> call() async {
    final questions = await _repository.fetchThreadQuestions();
    
    // 业务逻辑：按 pinned 和日期排序
    questions.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return 0;
    });
    
    return questions;
  }
}

// packages/domain/lib/usecases/reflection/fetch_today_question.dart
abstract interface class FetchTodayQuestion {
  Future<List<QuestionEntity>> call();
}

class FetchTodayQuestionImpl implements FetchTodayQuestion {
  final ReflectionRepository _repository;
  
  const FetchTodayQuestionImpl(this._repository);
  
  @override
  Future<List<QuestionEntity>> call() async {
    return await _repository.fetchTodayQuestions();
  }
}

// packages/domain/lib/usecases/reflection/fetch_calendar_reflections.dart
abstract interface class FetchCalendarReflections {
  Future<List<CalendarDayEntity>> call({
    required DateTime start,
    required DateTime end,
  });
}

class FetchCalendarReflectionsImpl implements FetchCalendarReflections {
  final ReflectionRepository _repository;
  
  const FetchCalendarReflectionsImpl(this._repository);
  
  @override
  Future<List<CalendarDayEntity>> call({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _repository.fetchCalendarView(start: start, end: end);
  }
}

// packages/domain/lib/usecases/reflection/submit_answer.dart
abstract interface class SubmitAnswer {
  Future<AnswerEntity> call({
    required String questionId,
    required String content,
    String? iconId,
  });
}

class SubmitAnswerImpl implements SubmitAnswer {
  final ReflectionRepository _repository;
  
  const SubmitAnswerImpl(this._repository);
  
  @override
  Future<AnswerEntity> call({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    // 业务验证
    if (content.trim().isEmpty) {
      throw ArgumentError('答案内容不能为空');
    }
    
    if (content.length > 1000) {
      throw ArgumentError('答案内容不能超过 1000 字');
    }
    
    return await _repository.submitAnswer(
      questionId: questionId,
      content: content,
      iconId: iconId,
    );
  }
}
```

#### 1.4 Domain Layer 包结构

```
packages/domain/
├── lib/
│   ├── entities/
│   │   ├── question_entity.dart
│   │   ├── answer_entity.dart
│   │   ├── calendar_entity.dart
│   │   ├── category_entity.dart
│   │   ├── icon_entity.dart
│   │   ├── user_entity.dart
│   │   ├── wallet_entity.dart
│   │   └── entities.dart              # 导出文件
│   │
│   ├── repositories/
│   │   ├── reflection_repository.dart
│   │   ├── user_repository.dart
│   │   ├── wallet_repository.dart
│   │   └── repositories.dart          # 导出文件
│   │
│   ├── usecases/
│   │   ├── reflection/
│   │   │   ├── fetch_thread_questions.dart
│   │   │   ├── fetch_today_question.dart
│   │   │   ├── fetch_calendar_reflections.dart
│   │   │   ├── submit_answer.dart
│   │   │   └── reflection_usecases.dart
│   │   ├── user/
│   │   │   ├── get_current_user.dart
│   │   │   ├── update_profile.dart
│   │   │   └── user_usecases.dart
│   │   ├── wallet/
│   │   │   └── wallet_usecases.dart
│   │   └── usecases.dart              # 导出文件
│   │
│   └── domain.dart                    # 主导出文件
│
└── pubspec.yaml
```

**pubspec.yaml**:
```yaml
name: domain
description: Domain layer with business logic and entities
version: 1.0.0

environment:
  sdk: ^3.5.0

dependencies:
  # 只依赖纯 Dart 包
  equatable: ^2.0.5  # 用于值对象比较（可选）

dev_dependencies:
  test: ^1.24.0
```

---

### 2. Data Layer（数据层）

**职责**：实现 Domain 层定义的接口，处理数据的获取、存储和转换。

#### 2.1 Models（DTO - 数据传输对象）

用于网络请求和本地存储的数据模型，包含序列化逻辑。

```dart
// packages/data/lib/models/question_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:domain/entities/entities.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const QuestionModel._();
  
  const factory QuestionModel({
    required String id,
    required String title,
    required CategoryModel category,
    @Default(false) bool pinned,
    @JsonKey(name: 'sub_category') CategoryModel? subCategory,
    @Default([]) List<AnswerModel> answers,
  }) = _QuestionModel;
  
  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
  
  // DTO → Entity 转换
  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      title: title,
      category: category.toEntity(),
      pinned: pinned,
      subCategory: subCategory?.toEntity(),
      answers: answers.map((a) => a.toEntity()).toList(),
    );
  }
  
  // Entity → DTO 转换
  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      title: entity.title,
      category: CategoryModel.fromEntity(entity.category),
      pinned: entity.pinned,
      subCategory: entity.subCategory != null
          ? CategoryModel.fromEntity(entity.subCategory!)
          : null,
      answers: entity.answers.map((a) => AnswerModel.fromEntity(a)).toList(),
    );
  }
}

@freezed
class AnswerModel with _$AnswerModel {
  const AnswerModel._();
  
  const factory AnswerModel({
    required String id,
    required String content,
    @JsonKey(name: 'created_ymd') required String createdYmd,
    QuestionModel? question,
    IconModel? icon,
  }) = _AnswerModel;
  
  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
  
  AnswerEntity toEntity() {
    return AnswerEntity(
      id: id,
      content: content,
      createdAt: DateTime.parse(createdYmd),
      question: question?.toEntity(),
      icon: icon?.toEntity(),
    );
  }
  
  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(
      id: entity.id,
      content: entity.content,
      createdYmd: entity.createdAt.toIso8601String().split('T')[0],
      question: entity.question != null
          ? QuestionModel.fromEntity(entity.question!)
          : null,
      icon: entity.icon != null ? IconModel.fromEntity(entity.icon!) : null,
    );
  }
}

@freezed
class CategoryModel with _$CategoryModel {
  const CategoryModel._();
  
  const factory CategoryModel({
    required String id,
    required String name,
    String? color,
  }) = _CategoryModel;
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  
  CategoryEntity toEntity() {
    return CategoryEntity(id: id, name: name, color: color);
  }
  
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(id: entity.id, name: entity.name, color: entity.color);
  }
}
```

#### 2.2 DataSources（数据源）

封装数据获取的具体实现。

```dart
// packages/data/lib/datasources/remote/reflection_remote_datasource.dart
import 'package:network/network.dart';
import '../../models/models.dart';

abstract interface class ReflectionRemoteDataSource {
  Future<List<CalendarDayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });
  
  Future<List<QuestionModel>> fetchTodayQuestions();
  Future<List<QuestionModel>> fetchThreadQuestions();
  
  Future<AnswerModel> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });
}

class ReflectionRemoteDataSourceImpl implements ReflectionRemoteDataSource {
  final ApiClientType _apiClient;
  
  const ReflectionRemoteDataSourceImpl(this._apiClient);
  
  @override
  Future<List<CalendarDayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _apiClient.get(
      '/api/calendar-view',
      queryParameters: {
        'start': start.toIso8601String().split('T')[0],
        'end': end.toIso8601String().split('T')[0],
      },
    );
    
    final data = response['data'] as List;
    return data.map((json) => CalendarDayModel.fromJson(json)).toList();
  }
  
  @override
  Future<List<QuestionModel>> fetchThreadQuestions() async {
    final response = await _apiClient.get('/api/thread-view');
    final data = response['data'] as List;
    return data.map((json) => QuestionModel.fromJson(json)).toList();
  }
  
  @override
  Future<List<QuestionModel>> fetchTodayQuestions() async {
    final response = await _apiClient.get('/api/qod');
    final data = response['data'] as List;
    return data.map((json) => QuestionModel.fromJson(json)).toList();
  }
  
  @override
  Future<AnswerModel> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    final response = await _apiClient.post(
      '/api/answers',
      data: {
        'question_id': questionId,
        'content': content,
        if (iconId != null) 'icon_id': iconId,
      },
    );
    
    return AnswerModel.fromJson(response['data']);
  }
}
```

#### 2.3 Repositories（仓储实现）

实现 Domain 层定义的 Repository 接口。

```dart
// packages/data/lib/repositories/reflection_repository_impl.dart
import 'package:domain/repositories/repositories.dart';
import 'package:domain/entities/entities.dart';
import '../datasources/remote/reflection_remote_datasource.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _remoteDataSource;
  
  const ReflectionRepositoryImpl(this._remoteDataSource);
  
  @override
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  }) async {
    final models = await _remoteDataSource.fetchCalendarView(
      start: start,
      end: end,
    );
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<QuestionEntity>> fetchThreadQuestions() async {
    final models = await _remoteDataSource.fetchThreadQuestions();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<QuestionEntity>> fetchTodayQuestions() async {
    final models = await _remoteDataSource.fetchTodayQuestions();
    return models.map((m) => m.toEntity()).toList();
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
  
  @override
  Future<AnswerEntity> fetchAnswerDetail(String answerId) async {
    // 实现获取答案详情
    throw UnimplementedError();
  }
}
```

#### 2.4 Data Layer 包结构

```
packages/data/
├── lib/
│   ├── models/
│   │   ├── question_model.dart
│   │   ├── question_model.freezed.dart
│   │   ├── question_model.g.dart
│   │   ├── answer_model.dart
│   │   ├── calendar_model.dart
│   │   └── models.dart                # 导出文件
│   │
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── reflection_remote_datasource.dart
│   │   │   ├── user_remote_datasource.dart
│   │   │   └── remote_datasources.dart
│   │   ├── local/
│   │   │   └── local_datasources.dart
│   │   └── datasources.dart
│   │
│   ├── repositories/
│   │   ├── reflection_repository_impl.dart
│   │   ├── user_repository_impl.dart
│   │   └── repositories.dart
│   │
│   └── data.dart                      # 主导出文件
│
└── pubspec.yaml
```

**pubspec.yaml**:
```yaml
name: data
description: Data layer with repositories and data sources
version: 1.0.0

environment:
  sdk: ^3.5.0

dependencies:
  # Domain Layer
  domain:
    path: ../domain
  
  # Infrastructure
  network:
    path: ../core/network
  
  # Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  test: ^1.24.0
```

---

### 3. Presentation Layer（表现层）

**职责**：UI 展示和用户交互，调用 UseCase 执行业务逻辑。

#### 3.1 Features 结构

```
packages/features/calendar/
├── lib/
│   ├── presentation/
│   │   ├── pages/
│   │   │   └── calendar_page.dart
│   │   ├── controllers/
│   │   │   ├── calendar_controller.dart
│   │   │   └── calendar_controller.g.dart
│   │   ├── states/
│   │   │   ├── calendar_state.dart
│   │   │   └── calendar_state.freezed.dart
│   │   └── widgets/
│   │       ├── calendar_month_view.dart
│   │       └── calendar_day_cell.dart
│   │
│   └── calendar.dart                  # 导出文件
│
└── pubspec.yaml
```

#### 3.2 Controller 实现

```dart
// packages/features/calendar/lib/presentation/controllers/calendar_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:domain/usecases/usecases.dart';
import 'package:domain/entities/entities.dart';
import '../states/calendar_state.dart';

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
      reflections: const AsyncValue.loading(),
    );
  }
  
  Future<void> _fetchCalendarData(DateTime month) async {
    final fetchReflections = ref.read(fetchCalendarReflectionsProvider);
    
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    
    state = state.copyWith(reflections: const AsyncValue.loading());
    
    try {
      final reflections = await fetchReflections(start: start, end: end);
      
      // 转换为 Map<String, CalendarDayEntity>
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
  
  void onMonthChanged(DateTime newMonth) {
    state = state.copyWith(focusedMonth: newMonth);
    _fetchCalendarData(newMonth);
  }
  
  void onDateSelected(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}
```

#### 3.3 State 定义

```dart
// packages/features/calendar/lib/presentation/states/calendar_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:domain/entities/entities.dart';

part 'calendar_state.freezed.dart';

@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    required DateTime focusedMonth,
    required DateTime selectedDate,
    required AsyncValue<Map<String, CalendarDayEntity>> reflections,
  }) = _CalendarState;
}
```

#### 3.4 Page 实现

```dart
// packages/features/calendar/lib/presentation/pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/calendar_controller.dart';
import '../widgets/calendar_month_view.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatMonth(state.focusedMonth)),
      ),
      body: state.reflections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (reflections) => CalendarMonthView(
          focusedMonth: state.focusedMonth,
          selectedDate: state.selectedDate,
          reflections: reflections,
          onMonthChanged: controller.onMonthChanged,
          onDateSelected: controller.onDateSelected,
        ),
      ),
    );
  }
  
  String _formatMonth(DateTime date) {
    return '${date.year}年${date.month}月';
  }
}
```

---

### 4. 依赖注入（Riverpod Providers）

在 `apps/lt_app` 中配置所有依赖。

```dart
// apps/lt_app/lib/src/di/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/repositories/repositories.dart';
import 'package:domain/usecases/usecases.dart';
import 'package:data/datasources/datasources.dart';
import 'package:data/repositories/repositories.dart';
import 'package:network/network.dart';

// Infrastructure Layer
final apiClientProvider = Provider<ApiClientType>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return HttpApiClient(baseUrl: kBaseUrl, tokenStorage: storage);
});

// Data Layer - DataSources
final reflectionRemoteDataSourceProvider = 
    Provider<ReflectionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReflectionRemoteDataSourceImpl(apiClient);
});

// Data Layer - Repositories
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});

// Domain Layer - UseCases
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
```

---

## 数据流向

### 完整的数据流

```
用户点击日历
    ↓
CalendarPage (Widget)
    ↓
ref.watch(calendarControllerProvider)
    ↓
CalendarController.build()
    ↓
ref.read(fetchCalendarReflectionsProvider)
    ↓
FetchCalendarReflectionsImpl.call()
    ↓
ReflectionRepository.fetchCalendarView()
    ↓
ReflectionRepositoryImpl.fetchCalendarView()
    ↓
ReflectionRemoteDataSource.fetchCalendarView()
    ↓
ApiClient.get('/api/calendar-view')
    ↓
HTTP Request → Backend
    ↓
Response (JSON)
    ↓
List<CalendarDayModel>.fromJson()
    ↓
models.map((m) => m.toEntity())
    ↓
List<CalendarDayEntity>
    ↓
state.copyWith(reflections: AsyncValue.data(...))
    ↓
CalendarPage 重新构建
    ↓
显示日历数据
```

---

## 依赖关系图

```
┌─────────────────────────────────────────────────────────────┐
│ Apps (lt_app)                                               │
│ - 依赖注入配置                                               │
│ - 路由配置                                                   │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Features (calendar, thread, ...)                            │
│ - Pages, Controllers, States                                │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖                    ↓ 依赖
┌──────────────────────┐    ┌──────────────────────┐
│ Domain               │    │ Core                 │
│ - Entities           │    │ - UI Components      │
│ - Repositories (接口)│    │ - Theme              │
│ - UseCases           │    └──────────────────────┘
└──────────────────────┘
         ↑ 实现
┌─────────────────────────────────────────────────────────────┐
│ Data                                                        │
│ - Models (DTO)                                              │
│ - DataSources                                               │
│ - Repositories (实现)                                        │
└─────────────────────────────────────────────────────────────┘
         ↓ 依赖
┌─────────────────────────────────────────────────────────────┐
│ Core                                                        │
│ - Network (ApiClient)                                       │
│ - Storage                                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 重构步骤

详见 `tasks.md` 文档。

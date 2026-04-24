# Skill: 创建 UseCase

## 概述

在 lt_app 的 Clean Architecture 中，一个完整的 UseCase 涉及 **3 个层级、5 个步骤**：

```
Domain Layer  →  Step 1: 定义 UseCase 接口 + 实现
              →  Step 2: 在 Domain 的 Repository 接口中添加新方法（如需要）
              →  Step 3: 更新 usecases.dart barrel 导出

Data Layer    →  Step 4: 在 Repository 实现类中补全方法

Feature Layer →  Step 5: 在对应 Feature 的 providers/ 中创建 UseCase Provider
```

> ⚠️ UseCase 永远属于 Domain 层（纯 Dart），Provider 属于 Feature 层（按需创建），禁止在 Data 层预创建 UseCase Provider。

---

## Step 1：在 Domain 层定义 UseCase

**文件位置**：`packages/domain/<xxx>_domain/lib/src/usecases/<action>_usecase.dart`

### 1a. 无参数 UseCase（简单查询）

```dart
// packages/domain/reflection_domain/lib/src/usecases/fetch_today_question_usecase.dart

import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// UseCase 接口（依赖倒置：Feature 层依赖此接口，而非具体实现）
abstract interface class FetchTodayQuestionUseCaseType {
  Future<List<QuestionEntity>> execute();
}

/// UseCase 实现
class FetchTodayQuestionUseCase implements FetchTodayQuestionUseCaseType {
  final ReflectionRepository _repository;

  const FetchTodayQuestionUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> execute() async {
    return await _repository.fetchTodayQuestions();
  }
}
```

### 1b. 有参数 UseCase（带业务校验）

```dart
// packages/domain/reflection_domain/lib/src/usecases/submit_answer_usecase.dart

import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class SubmitAnswerUseCaseType {
  Future<AnswerEntity> execute({
    required String questionId,
    required String content,
    String? iconId,
  });
}

class SubmitAnswerUseCase implements SubmitAnswerUseCaseType {
  final ReflectionRepository _repository;

  const SubmitAnswerUseCase(this._repository);

  @override
  Future<AnswerEntity> execute({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    // 业务规则校验（UseCase 的核心职责）
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

### 1c. 有复杂逻辑的 UseCase（数据转换/聚合）

```dart
// packages/domain/reflection_domain/lib/src/usecases/fetch_calendar_reflections_usecase.dart

import '../entities/entities.dart';
import '../repositories/repositories.dart';
import 'package:intl/intl.dart';

abstract interface class CalendarFetchReflectionUseCaseType {
  Future<Map<String, CalendarDayItem>> execute(DateTime start, DateTime end);
}

class CalendarFetchReflectionUseCase implements CalendarFetchReflectionUseCaseType {
  final ReflectionRepository repository;

  CalendarFetchReflectionUseCase({required this.repository});

  @override
  Future<Map<String, CalendarDayItem>> execute(DateTime start, DateTime end) async {
    final list = await repository.fetchCalendarView(start: start, end: end);
    // ... 业务聚合逻辑（构建日历 Map）
    return resultMap;
  }
}
```

**命名规范**：
- 接口类：`<Action><Domain>UseCaseType`（如 `FetchTodayQuestionUseCaseType`）
- 实现类：`<Action><Domain>UseCase`（如 `FetchTodayQuestionUseCase`）
- 文件名：`<action>_<domain>_usecase.dart`（蛇形命名）

---

## Step 2：在 Repository 接口中添加新方法（如需要）

若 UseCase 需要调用尚未存在的 Repository 方法，先在 Domain 的接口文件中声明：

```dart
// packages/domain/reflection_domain/lib/src/repositories/reflection_repository.dart

abstract interface class ReflectionRepository {
  Future<List<QuestionEntity>> fetchTodayQuestions();
  Future<List<QuestionEntity>> fetchThreadQuestions();
  Future<AnswerEntity> submitAnswer({...});
  Future<AnswerEntity> fetchAnswerDetail(String answerId);
  Future<List<CalendarDayEntity>> fetchCalendarView({...});

  // ✅ 新增方法在此声明
  Future<SomeEntity> yourNewMethod({required String param});
}
```

---

## Step 3：更新 usecases.dart barrel 导出

将新 UseCase 文件加入 barrel 导出，确保 Domain 包外部可以访问：

```dart
// packages/domain/reflection_domain/lib/src/usecases/usecases.dart

library usecases;

export 'fetch_thread_questions_usecase.dart';
export 'fetch_today_question_usecase.dart';
export 'fetch_calendar_reflections_usecase.dart';
export 'submit_answer_usecase.dart';
export 'fetch_answer_detail_usecase.dart';

// ✅ 新增 UseCase 在此添加导出
export 'your_new_usecase.dart';
```

---

## Step 4：在 Data 层 Repository 实现中补全方法

若 Step 2 中在接口新增了方法，需在 Repository 实现类中同步补全：

```dart
// packages/data/reflection_data/lib/src/repositories/reflection_repository_impl.dart

class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _remoteDataSource;
  const ReflectionRepositoryImpl(this._remoteDataSource);

  // ✅ 实现新方法
  @override
  Future<SomeEntity> yourNewMethod({required String param}) async {
    final model = await _remoteDataSource.yourNewMethod(param: param);
    return model.toEntity();  // DTO → Entity 转换
  }
}
```

> DataSource 层若也需要新接口方法，同步在 `ReflectionRemoteDataSource` 接口和 `ReflectionRemoteDataSourceImpl` 实现类中添加。

---

## Step 5：在 Feature 层创建 UseCase Provider

UseCase Provider **只在使用该 UseCase 的 Feature 包中创建**，不要放到 Data 层：

```dart
// packages/features/<feature_name>/lib/src/providers/<feature>_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart'; // 获取 reflectionRepositoryProvider

// ✅ 注册 UseCase Provider（依赖 Repository Provider）
final yourNewUseCaseProvider = Provider<YourNewUseCaseType>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return YourNewUseCase(repository: repository);
});
```

在 ViewModel 中使用：

```dart
// packages/features/<feature_name>/lib/src/<feature>_view_model.dart

@riverpod
class YourFeatureViewModel extends _$YourFeatureViewModel {
  @override
  SomeState build() {
    _loadData();
    return SomeState.initial();
  }

  Future<void> _loadData() async {
    // ✅ 通过 Provider 获取 UseCase 实例，调用 execute()
    final useCase = ref.read(yourNewUseCaseProvider);
    try {
      final result = await useCase.execute(/* 传参 */);
      if (!ref.mounted) return;
      state = state.copyWith(data: AsyncValue.data(result));
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = state.copyWith(data: AsyncValue.error(e, stack));
    }
  }
}
```

---

## 完整流程检查清单

创建一个 UseCase 后，逐项确认：

- [ ] `packages/domain/<xxx>_domain/lib/src/usecases/` 新增 UseCase 文件
  - [ ] 定义了 `abstract interface class XxxUseCaseType`
  - [ ] 实现了 `class XxxUseCase implements XxxUseCaseType`
  - [ ] 通过构造函数注入 Repository（`const XxxUseCase(this._repository)`）
  - [ ] 业务校验逻辑（参数校验、业务规则）在 UseCase 内处理
- [ ] `usecases.dart` barrel 文件已添加新导出
- [ ] 若需要新的 Repository 方法：
  - [ ] Domain Repository 接口中已声明
  - [ ] Data Repository 实现类中已补全
  - [ ] DataSource 接口和实现也已同步（如调用了新 API）
- [ ] Feature 层 `providers/` 中创建了对应 `Provider<XxxUseCaseType>`
- [ ] ViewModel 中通过 `ref.read(xxxProvider)` 获取并调用 `useCase.execute()`
- [ ] 运行代码生成（如 ViewModel 使用了 `@riverpod`）：
  ```bash
  make codegen PACKAGE=<feature_package_name>
  ```

---

## 各层文件路径模板

```
Domain 层（新 UseCase 文件）：
  packages/domain/<domain>/lib/src/usecases/<action>_usecase.dart

Domain 层（Repository 接口）：
  packages/domain/<domain>/lib/src/repositories/<domain>_repository.dart

Domain 层（barrel 导出）：
  packages/domain/<domain>/lib/src/usecases/usecases.dart

Data 层（Repository 实现）：
  packages/data/<domain>_data/lib/src/repositories/<domain>_repository_impl.dart

Data 层（DataSource 接口 + 实现）：
  packages/data/<domain>_data/lib/src/datasources/remote/<domain>_remote_datasource.dart

Feature 层（UseCase Provider）：
  packages/features/<feature>/lib/src/providers/<feature>_providers.dart

Feature 层（ViewModel 使用）：
  packages/features/<feature>/lib/src/<feature>_view_model.dart
```

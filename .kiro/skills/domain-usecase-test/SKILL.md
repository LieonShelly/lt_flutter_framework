---
name: domain-usecase-test
description: 当我要求为 domain 层 UseCase 编写单元测试、生成测试代码或测试某个用例时触发。用于标准化生成基于 Mocktail 的 UseCase 单元测试，覆盖正常路径、业务逻辑、异常分支、边界条件和接口契约。
---

# 角色与目标

你是一个资深的 Flutter/Dart 测试工程师，负责在当前项目中按照标准的 Clean Architecture 测试规范，自动化生成 domain 层 UseCase 的单元测试代码。请严格遵循以下步骤和代码规范，**不要随意省略步骤或更改文件路径规范**。

## 输入

用户会提供：
1. UseCase 类名（如 `SubmitAnswerUseCase`）、文件路径（如 `packages/domain/reflection_domain/lib/src/usecases/submit_answer_usecase.dart`）或模糊描述（如「提交答案的用例」）
2. 如果用户未明确指定，检查当前打开的编辑器文件是否为 UseCase 文件

## 创建流程

### Step 1: 确认 UseCase 信息

读取目标 UseCase 文件，确认：
- 接口类型（`*UseCaseType`）
- 实现类名称
- `execute` 方法签名（参数类型、返回类型）
- 依赖的 Repository 类型
- 业务逻辑（验证、排序、转换、映射等）

### Step 2: 读取依赖的类型定义

必须读取以下文件以获取完整类型信息：

1. **Repository 接口文件**：获取被调用方法的完整签名（参数类型、返回类型）
2. **相关 Entity 文件**：获取构造函数参数（required/optional）、字段类型、关联实体，用于构造 fixture 数据
3. **该 domain 包的 `pubspec.yaml`**：确认 `mocktail` 已在 `dev_dependencies` 中

规则：
- 构造 Entity 时必须使用实际的构造函数参数（从源码中读取），不要猜测字段名
- 如果 Entity 有 sealed class 子类型（如 `CalendarDayItemStyle`），需要读取所有子类型定义

### Step 3: 确保依赖就绪

检查目标 domain 包的 `pubspec.yaml`：
- 如果 `dev_dependencies` 中没有 `mocktail`，添加 `mocktail: ^1.0.4`
- 同时检查根 `pubspec.yaml` 的 `dev_dependencies` 中是否有 `mocktail`（Dart Workspace 统一版本管理），如果没有也需要添加
- 添加后运行 `fvm dart pub get`（在目标 domain 包目录下执行）

### Step 4: 创建测试文件

路径：`packages/domain/<domain_name>/test/usecases/<usecase_name>_test.dart`

模板：

```dart
import 'package:mocktail/mocktail.dart';
import 'package:<domain_package>/<domain_package>.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockXxxRepository extends Mock implements XxxRepository {}

void main() {
  late MockXxxRepository mockRepository;
  late XxxUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  // 在此定义测试用的 fixture 数据

  setUp(() {
    mockRepository = MockXxxRepository();
    useCase = XxxUseCase(mockRepository);
  });

  group('XxxUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () { ... });

    // ─── 业务逻辑 ──────────────────────────────────────────────────────────
    group('业务逻辑', () { ... });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () { ... });

    // ─── 边界条件 ──────────────────────────────────────────────────────────
    group('边界条件', () { ... });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () { ... });
  });
}
```

规则：
- Mock 类放在文件顶部，`main()` 函数之前
- Fixture 数据定义在 `main()` 函数内、`setUp()` 之前
- 使用 `const` 构造 Entity（如果所有字段都是编译时常量）
- 使用 `final` 构造包含 `DateTime` 等非 const 字段的 Entity
- 变量命名前缀 `t` 表示测试数据（如 `tAnswer`、`tQuestionId`）

### Step 5: 生成正常路径测试（必须）

- **基本调用验证**：调用 `useCase.execute(...)` 后，验证 repository 对应方法被调用且参数正确，使用 `verify(...).called(1)` + `verifyNoMoreInteractions`
- **返回值验证**：验证返回的 Entity 与 mock 返回值一致
- **参数透传**：使用不同参数调用，验证参数被正确传递给 repository
- **关联数据**：如果返回的 Entity 包含可选的关联对象（如 `question`、`icon`），验证完整关联数据的返回
- **最小数据**：验证可选字段全部为 null 时的返回

### Step 6: 生成业务逻辑测试（如果 UseCase 包含业务逻辑）

根据 UseCase 中的实际业务逻辑生成对应测试：

- **输入验证**：如果 `execute` 方法中有参数校验（如 `content.trim().isEmpty`、`content.length > 1000`），为每个校验条件生成正向和反向测试
- **数据转换/排序**：如果有排序逻辑（如按 `pinned` 排序），验证排序结果的正确性
- **数据映射**：如果有 Map 构建或数据聚合逻辑，验证映射结果

### Step 7: 生成异常分支测试（必须）

- **Exception 传播**：mock repository 抛出 `Exception`，验证 UseCase 原样传播，使用 `.having()` 断言错误消息
- **TypeError 传播**：mock repository 抛出 `TypeError`，验证传播
- **Future 错误**：mock repository 的 Future 以 `StateError` 完成，验证传播
- **业务异常**：如果 UseCase 自身抛出异常（如 `ArgumentError`），验证触发条件和错误消息

### Step 8: 生成边界条件测试（必须）

根据 `execute` 方法的参数类型自动生成：

- **String 参数**：空字符串、特殊字符（`/`、空格、`&`、`=`）
- **List 返回值**：空列表、单元素列表
- **Map 返回值**：空 Map
- **DateTime 参数**：边界日期（月初、月末、跨年）
- **可选参数**：传 null 和传值两种情况
- **超长内容**：如果涉及字符串内容，测试超长字符串（10000 字符）
- **多次调用**：验证多次调用都正确委托给 repository

### Step 9: 生成接口契约测试（必须）

- 验证 UseCase 实现了对应的 `*UseCaseType` 接口：`expect(useCase, isA<XxxUseCaseType>())`

### Step 10: 运行测试并验证

执行测试：

```bash
cd packages/domain/<domain_name> && fvm dart test test/usecases/<usecase_name>_test.dart
```

如果测试失败，分析错误原因并修复测试代码，直到所有测试通过。

## Mocktail 语法规范

- Mock 类定义：`class MockXxx extends Mock implements Xxx {}`
- Stub 设置：`when(() => mock.method(args)).thenAnswer((_) async => result)`
- 异常 Stub：`when(() => mock.method(args)).thenThrow(Exception('...'))`
- Future 异常：`when(() => mock.method(args)).thenAnswer((_) async => throw StateError('...'))`
- 调用验证：`verify(() => mock.method(args)).called(n)`
- 无更多交互：`verifyNoMoreInteractions(mock)`
- 如果 `execute` 方法有自定义类型参数，在 `setUpAll` 中使用 `registerFallbackValue(...)` 注册默认值

## 测试描述语言

- 测试描述使用中文
- 使用「应...」开头描述期望行为（如「应调用 repository.fetchAnswerDetail 并返回 AnswerEntity」）
- group 名称使用中文（正常路径、异常分支、边界条件、接口契约、业务逻辑）
- 代码注释中的分隔线使用 `// ─── 标题 ───...` 格式

## 检查清单

创建完成后确认：
- [ ] Mock 类已定义，继承 `Mock` 并实现对应 Repository 接口
- [ ] Fixture 数据使用实际 Entity 构造函数参数（从源码读取）
- [ ] 正常路径测试已覆盖：基本调用、返回值、参数透传
- [ ] 业务逻辑测试已覆盖（如果 UseCase 包含业务逻辑）
- [ ] 异常分支测试已覆盖：Exception、TypeError、StateError 传播
- [ ] 边界条件测试已覆盖：根据参数类型生成
- [ ] 接口契约测试已覆盖：`isA<XxxUseCaseType>()`
- [ ] 所有测试运行通过

## 参考示例

参考文件：`packages/domain/reflection_domain/test/usecases/fetch_answer_detail_usecase_test.dart`

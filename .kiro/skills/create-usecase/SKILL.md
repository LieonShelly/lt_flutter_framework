---
name: create-usecase
description: 当我要求新增 API 请求、创建 UseCase 或对接新接口时触发。用于标准化生成 Flutter Clean Architecture 项目中的 Entity、Model、DataSource、Repository、UseCase 和 Provider 代码。
---

# 角色与目标

你是一个资深的 Flutter 架构师，负责在当前项目中按照标准的 Clean Architecture 流程，自动化生成从网络请求到业务逻辑层（UseCase）的全链路模板代码。请严格遵循以下步骤和代码规范，**不要随意省略步骤或更改文件路径规范**。

## 输入

用户会提供：
1. API 端点信息（通常已记录在 `docs/API/api.md` 中）
2. 所属的业务模块名称（如 reflection、user、wallet、booking 等）

## 前置准备

在开始之前，确认目标业务模块：
- Domain 包路径：`packages/domain/{module}_domain/`
- Data 包路径：`packages/data/{module}_data/`
- 如果是新模块，需要先创建包目录结构（参考现有模块）

## 创建流程

### Step 1: 确认 API 信息

从 `docs/API/api.md` 中读取对应 API 的详细信息，确认：
- HTTP Method（GET / POST / PUT / DELETE）
- Endpoint path
- Request parameters（query params 或 body）
- Response 数据结构（JSON 字段、类型、嵌套关系）

### Step 2: 创建 Entity（Domain 层）

路径：`packages/domain/{module}_domain/lib/src/entities/{entity_name}_entity.dart`

模板：

```dart
class {Name}Entity {
  final String id;
  // 业务字段，使用 Dart 原生类型
  // 日期用 DateTime?，不用 String

  const {Name}Entity({
    required this.id,
    // required / optional 字段
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    // 字段序列化
  };

  factory {Name}Entity.fromJson(Map<String, dynamic> json) => {Name}Entity(
    id: json['id'] as String,
    // 字段反序列化
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {Name}Entity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

规则：
- 纯 Dart 类，不依赖任何 Flutter 框架
- 使用 `const` 构造函数
- 实现 `==` 和 `hashCode`
- 提供 `toJson()` 和 `fromJson()` 工厂方法
- 日期字段使用 `DateTime?` 类型
- 关联实体使用可选类型（如 `QuestionEntity?`）
- 在 `entities.dart` 导出文件中添加 export

### Step 3: 创建 Model（Data 层 DTO）

路径：`packages/data/{module}_data/lib/src/models/{model_name}_model.dart`

模板：

```dart
import 'package:lt_annotation/annotation.dart';
import 'package:{module}_domain/{module}_domain.dart';

part '{model_name}_model.lt_model.dart';

@ltDeserialization
class {Name}Model {
  final String id;
  // 字段与 API 响应 JSON 对应
  // 使用 @LtJsonKey('snake_case') 处理命名映射
  @LtJsonKey('field_name')
  final String? fieldName;

  {Name}Model({
    required this.id,
    this.fieldName,
  });

  factory {Name}Model.fromJson(Map<String, dynamic> json) =>
      _${Name}ModelFromJson(json);

  {Name}Entity toEntity() {
    return {Name}Entity(
      id: id,
      // DTO → Entity 转换
      // 日期字符串在此处用 DateTime.parse() 转换
    );
  }

  factory {Name}Model.fromEntity({Name}Entity entity) {
    return {Name}Model(
      id: entity.id,
      // Entity → DTO 转换
    );
  }
}
```

规则：
- 使用 `@ltDeserialization` 注解（来自 `lt_annotation` 包）
- 使用 `@LtJsonKey('snake_case')` 处理 JSON 字段名映射
- 包含 `part '{name}_model.lt_model.dart';` 声明
- `fromJson` 工厂方法委托给生成的 `_${Name}ModelFromJson`
- 提供 `toEntity()` 方法转换为 Domain Entity
- 提供 `fromEntity()` 工厂方法反向转换
- 在 `models.dart` 导出文件中添加 export
- 创建后需要运行代码生成：`make codegen PACKAGE={module}_data`

### Step 4: 添加 Repository 方法（Domain 层接口）

路径：`packages/domain/{module}_domain/lib/src/repositories/{module}_repository.dart`

在已有的 Repository 接口中添加新方法：

```dart
abstract interface class {Module}Repository {
  // ... 已有方法

  Future<{ReturnEntity}> {methodName}({parameters});
}
```

规则：
- 返回类型使用 Domain Entity（不是 Model）
- 参数使用 Dart 原生类型
- 方法命名：`fetch*` / `submit*` / `create*` / `update*` / `delete*`

### Step 5: 添加 DataSource 方法（Data 层）

路径：`packages/data/{module}_data/lib/src/datasources/remote/{module}_remote_datasource.dart`

1. 在接口中添加方法声明
2. 在实现类中添加实现

DataSource 方法模板：

```dart
// 接口声明
abstract interface class {Module}RemoteDataSource {
  // ... 已有方法
  Future<{ReturnModel}> {methodName}({parameters});
}

// 实现
class {Module}RemoteDataSourceImpl implements {Module}RemoteDataSource {
  // ... 已有实现

  @override
  Future<{ReturnModel}> {methodName}({parameters}) async {
    final response = await _apiClient.get(  // 或 .post / .put / .delete
      '/api/{endpoint}',
      queryParameters: {  // GET 请求用 queryParameters
        'param': value,
      },
      // data: {  // POST/PUT 请求用 data
      //   'field': value,
      // },
    );

    // 单个对象
    return {ReturnModel}.fromJson(response['data']);

    // 列表对象
    // final data = response['data'] as List;
    // return await ComputeTransformer.decodeList(data, {ReturnModel}.fromJson);
  }
}
```

规则：
- 返回类型使用 Data Model（不是 Entity）
- GET 请求使用 `_apiClient.get()` + `queryParameters`
- POST 请求使用 `_apiClient.post()` + `data`
- 列表解析使用 `ComputeTransformer.decodeList(data, Model.fromJson)`
- 单对象解析使用 `Model.fromJson(response['data'])`
- snake_case 的 JSON 字段名在请求 data 中保持 snake_case

### Step 6: 添加 Repository 实现（Data 层）

路径：`packages/data/{module}_data/lib/src/repositories/{module}_repository_impl.dart`

```dart
@override
Future<{ReturnEntity}> {methodName}({parameters}) async {
  final model = await _remoteDataSource.{methodName}({args});
  return model.toEntity();
  // 列表：return models.map((m) => m.toEntity()).toList();
}
```

规则：
- 调用 DataSource 获取 Model
- 使用 `model.toEntity()` 转换为 Entity 返回
- 列表使用 `.map((m) => m.toEntity()).toList()`

### Step 7: 创建 UseCase（Domain 层）

路径：`packages/domain/{module}_domain/lib/src/usecases/{usecase_name}_usecase.dart`

模板：

```dart
import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class {UseCaseName}UseCaseType {
  Future<{ReturnType}> execute({parameters});
}

class {UseCaseName}UseCase implements {UseCaseName}UseCaseType {
  final {Module}Repository _repository;

  const {UseCaseName}UseCase(this._repository);

  @override
  Future<{ReturnType}> execute({parameters}) async {
    // 业务验证（如果需要）
    // if (content.trim().isEmpty) {
    //   throw ArgumentError('内容不能为空');
    // }

    return await _repository.{repositoryMethod}({args});
  }
}
```

命名规则：
- 获取类：`Fetch{Entity}UseCase`
- 提交/创建类：`Submit{Entity}UseCase` / `Create{Entity}UseCase`
- 更新类：`Update{Entity}UseCase`
- 删除类：`Delete{Entity}UseCase`
- 其他动作：`{Action}{Entity}UseCase`

规则：
- 定义 `abstract interface class {Name}UseCaseType` 接口
- 实现类使用 `const` 构造函数
- Repository 字段使用 `_` 前缀（private）
- 业务验证逻辑放在 `execute` 方法中，在调用 repository 之前
- 在 `usecases.dart`（或 `{module}_usecases.dart`）导出文件中添加 export

### Step 8: 更新导出文件

确保所有新文件都被正确导出：

1. **Entity 导出**：`packages/domain/{module}_domain/lib/src/entities/entities.dart`
   ```dart
   export '{entity_name}_entity.dart';
   ```

2. **UseCase 导出**：`packages/domain/{module}_domain/lib/src/usecases/{module}_usecases.dart`
   ```dart
   export '{usecase_name}_usecase.dart';
   ```

3. **Model 导出**：`packages/data/{module}_data/lib/src/models/models.dart`
   ```dart
   export '{model_name}_model.dart';
   ```

### Step 9: 创建 Feature Provider（如果需要）

如果有 Feature 包需要使用这个 UseCase，在对应 Feature 的 providers 文件中添加：

路径：`packages/features/{feature}/lib/src/providers/{feature}_providers.dart`

```dart
import 'package:{module}_domain/{module}_domain.dart';
import 'package:{module}_data/{module}_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final {useCaseName}UsecaseProvider = Provider<{UseCaseName}UseCaseType>((ref) {
  final repository = ref.watch({module}RepositoryProvider);
  return {UseCaseName}UseCase(repository);
});
```

规则：
- Provider 类型使用 `*UseCaseType` 接口（不是实现类）
- 通过 `ref.watch({module}RepositoryProvider)` 获取 Repository
- Provider 命名：`{useCaseName}UsecaseProvider`（camelCase）

### Step 10: 运行代码生成并验证

```bash
# 生成 Model 的序列化代码
make codegen PACKAGE={module}_data

# 验证编译
cd packages/domain/{module}_domain && fvm dart analyze
cd packages/data/{module}_data && fvm flutter analyze
```

## 检查清单

创建完成后确认：
- [ ] Entity 文件已创建，纯 Dart 类，包含 `const` 构造函数、`==`、`hashCode`、`toJson()`、`fromJson()`
- [ ] Entity 已添加到 `entities.dart` 导出文件
- [ ] Model 文件已创建，使用 `@ltDeserialization` 注解，包含 `toEntity()` 和 `fromEntity()`
- [ ] Model 已添加到 `models.dart` 导出文件
- [ ] Repository 接口已添加新方法声明
- [ ] DataSource 接口和实现已添加新方法
- [ ] Repository 实现已添加新方法（调用 DataSource + toEntity 转换）
- [ ] UseCase 接口（`*UseCaseType`）和实现类已创建
- [ ] UseCase 已添加到 usecases 导出文件
- [ ] Feature Provider 已创建（如果需要）
- [ ] 代码生成已运行（`make codegen PACKAGE={module}_data`）
- [ ] 编译验证通过

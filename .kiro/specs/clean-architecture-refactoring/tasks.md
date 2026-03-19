# Clean Architecture 重构任务清单

## 任务概览

本文档列出了将现有架构重构为标准 Clean Architecture 的所有任务，按阶段组织。

---

## 阶段 1：创建新的包结构

### Task 1.1：创建 Domain 包

- [ ] 创建 `packages/domain/` 目录
- [ ] 创建 `packages/domain/pubspec.yaml`
- [ ] 创建 `packages/domain/lib/domain.dart`
- [ ] 创建子目录：
  - [ ] `packages/domain/lib/entities/`
  - [ ] `packages/domain/lib/repositories/`
  - [ ] `packages/domain/lib/usecases/`

### Task 1.2：创建 Data 包

- [ ] 创建 `packages/data/` 目录
- [ ] 创建 `packages/data/pubspec.yaml`
- [ ] 创建 `packages/data/lib/data.dart`
- [ ] 创建子目录：
  - [ ] `packages/data/lib/models/`
  - [ ] `packages/data/lib/datasources/remote/`
  - [ ] `packages/data/lib/datasources/local/`
  - [ ] `packages/data/lib/repositories/`

---

## 阶段 2：实现 Domain Layer

### Task 2.1：创建 Entities

- [ ] `packages/domain/lib/entities/question_entity.dart`
- [ ] `packages/domain/lib/entities/answer_entity.dart`
- [ ] `packages/domain/lib/entities/calendar_entity.dart`
- [ ] `packages/domain/lib/entities/category_entity.dart`
- [ ] `packages/domain/lib/entities/icon_entity.dart`
- [ ] `packages/domain/lib/entities/user_entity.dart`
- [ ] `packages/domain/lib/entities/wallet_entity.dart`
- [ ] `packages/domain/lib/entities/entities.dart` (导出文件)

### Task 2.2：创建 Repository 接口

- [ ] `packages/domain/lib/repositories/reflection_repository.dart`
- [ ] `packages/domain/lib/repositories/user_repository.dart`
- [ ] `packages/domain/lib/repositories/wallet_repository.dart`
- [ ] `packages/domain/lib/repositories/repositories.dart` (导出文件)

### Task 2.3：创建 UseCases

**Reflection UseCases:**
- [ ] `packages/domain/lib/usecases/reflection/fetch_thread_questions.dart`
- [ ] `packages/domain/lib/usecases/reflection/fetch_today_question.dart`
- [ ] `packages/domain/lib/usecases/reflection/fetch_calendar_reflections.dart`
- [ ] `packages/domain/lib/usecases/reflection/submit_answer.dart`
- [ ] `packages/domain/lib/usecases/reflection/fetch_answer_detail.dart`
- [ ] `packages/domain/lib/usecases/reflection/reflection_usecases.dart` (导出)

**User UseCases:**
- [ ] `packages/domain/lib/usecases/user/get_current_user.dart`
- [ ] `packages/domain/lib/usecases/user/update_profile.dart`
- [ ] `packages/domain/lib/usecases/user/logout.dart`
- [ ] `packages/domain/lib/usecases/user/user_usecases.dart` (导出)

**Wallet UseCases:**
- [ ] `packages/domain/lib/usecases/wallet/get_wallet.dart`
- [ ] `packages/domain/lib/usecases/wallet/get_transactions.dart`
- [ ] `packages/domain/lib/usecases/wallet/wallet_usecases.dart` (导出)

**总导出文件:**
- [ ] `packages/domain/lib/usecases/usecases.dart`

---

## 阶段 3：实现 Data Layer

### Task 3.1：创建 Models (DTO)

从现有的 `packages/service/lt_reflection_service/lib/src/dto/` 迁移：

- [ ] `packages/data/lib/models/question_model.dart`
  - [ ] 添加 `toEntity()` 方法
  - [ ] 添加 `fromEntity()` 工厂方法
- [ ] `packages/data/lib/models/answer_model.dart`
  - [ ] 添加 `toEntity()` 方法
  - [ ] 添加 `fromEntity()` 工厂方法
- [ ] `packages/data/lib/models/calendar_model.dart`
  - [ ] 添加 `toEntity()` 方法
  - [ ] 添加 `fromEntity()` 工厂方法
- [ ] `packages/data/lib/models/category_model.dart`
- [ ] `packages/data/lib/models/icon_model.dart`
- [ ] `packages/data/lib/models/user_model.dart`
- [ ] `packages/data/lib/models/wallet_model.dart`
- [ ] `packages/data/lib/models/models.dart` (导出文件)

### Task 3.2：创建 DataSources

从现有的 Repository 实现中提取数据源逻辑：

**Remote DataSources:**
- [ ] `packages/data/lib/datasources/remote/reflection_remote_datasource.dart`
  - [ ] 接口定义
  - [ ] 实现类
- [ ] `packages/data/lib/datasources/remote/user_remote_datasource.dart`
- [ ] `packages/data/lib/datasources/remote/wallet_remote_datasource.dart`
- [ ] `packages/data/lib/datasources/remote/remote_datasources.dart` (导出)

**Local DataSources (可选):**
- [ ] `packages/data/lib/datasources/local/cache_datasource.dart`
- [ ] `packages/data/lib/datasources/local/local_datasources.dart` (导出)

**总导出文件:**
- [ ] `packages/data/lib/datasources/datasources.dart`

### Task 3.3：创建 Repository 实现

从现有的 `packages/service/lt_reflection_service/lib/src/repository/` 迁移：

- [ ] `packages/data/lib/repositories/reflection_repository_impl.dart`
  - [ ] 实现 `ReflectionRepository` 接口
  - [ ] 使用 DataSource
  - [ ] 添加 Model → Entity 转换
- [ ] `packages/data/lib/repositories/user_repository_impl.dart`
- [ ] `packages/data/lib/repositories/wallet_repository_impl.dart`
- [ ] `packages/data/lib/repositories/repositories.dart` (导出文件)

### Task 3.4：运行代码生成

- [ ] 在 `packages/data/` 运行 `flutter pub get`
- [ ] 运行 `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] 验证所有 `.freezed.dart` 和 `.g.dart` 文件生成成功

---

## 阶段 4：重构 Features Layer

### Task 4.1：重命名 packages/domain 为 packages/features

**方式 1：使用 Git 保留历史**
```bash
cd packages
git mv domain features
```

**方式 2：手动重命名**
- [ ] 重命名 `packages/domain/` → `packages/features/`
- [ ] 更新所有 `pubspec.yaml` 中的包名

### Task 4.2：重构 Calendar Feature

- [ ] 更新 `packages/features/calendar/pubspec.yaml`
  - [ ] 添加 `domain` 依赖
  - [ ] 添加 `data` 依赖（如果需要）
- [ ] 重构 `calendar_controller.dart`
  - [ ] 使用 Domain 层的 UseCases
  - [ ] 使用 Domain 层的 Entities
  - [ ] 移除对 Service 层的直接依赖
- [ ] 更新 `calendar_state.dart`
  - [ ] 使用 Domain Entities 而非 DTOs
- [ ] 更新所有 import 语句

### Task 4.3：重构 Thread Feature

- [ ] 更新 `packages/features/thread/pubspec.yaml`
- [ ] 重构 `thread_controller.dart`
- [ ] 更新 `thread_state.dart`
- [ ] 更新所有 import 语句

### Task 4.4：重构 Today Question Feature

- [ ] 更新 `packages/features/today_question/pubspec.yaml`
- [ ] 重构 `today_question_controller.dart`
- [ ] 更新所有 import 语句

### Task 4.5：重构 Add Answer Feature

- [ ] 更新 `packages/features/add_answer/pubspec.yaml`
- [ ] 重构 `add_answer_controller.dart`
- [ ] 更新所有 import 语句

### Task 4.6：重构 Answer Detail Feature

- [ ] 更新 `packages/features/answer_detail/pubspec.yaml`
- [ ] 重构 `answer_detail_controller.dart`
- [ ] 更新所有 import 语句

### Task 4.7：重构 Copilot Feature

- [ ] 更新 `packages/features/copilot/pubspec.yaml`
- [ ] 重构相关 controllers
- [ ] 更新所有 import 语句

### Task 4.8：重构 User Feature

- [ ] 更新 `packages/features/user/pubspec.yaml`
- [ ] 重构 user controllers
- [ ] 更新所有 import 语句

### Task 4.9：重构 Wallet Feature

- [ ] 更新 `packages/features/wallet/pubspec.yaml`
- [ ] 重构 wallet controllers
- [ ] 更新所有 import 语句

### Task 4.10：重构 Feature Core

- [ ] 更新 `packages/features/feature_core/pubspec.yaml`
- [ ] 更新 `app_route_path.dart`（如果需要）
- [ ] 更新所有 import 语句

---

## 阶段 5：更新 Apps Layer

### Task 5.1：更新主应用依赖

- [ ] 更新 `apps/lt_app/pubspec.yaml`
  - [ ] 添加 `domain` 依赖
  - [ ] 添加 `data` 依赖
  - [ ] 更新 `features/*` 依赖（原 `domain/*`）
  - [ ] 移除 `service/*` 依赖

### Task 5.2：创建依赖注入配置

- [ ] 创建 `apps/lt_app/lib/src/di/providers.dart`
  - [ ] 配置 Infrastructure Providers
  - [ ] 配置 DataSource Providers
  - [ ] 配置 Repository Providers
  - [ ] 配置 UseCase Providers

### Task 5.3：更新路由配置

- [ ] 更新 `apps/lt_app/lib/src/app_router.dart`
  - [ ] 更新所有 import 语句
  - [ ] 确保路由指向正确的 Feature Pages

### Task 5.4：更新主入口

- [ ] 更新 `apps/lt_app/lib/main.dart`
  - [ ] 更新 import 语句
  - [ ] 确保 ProviderScope 正确配置

### Task 5.5：运行代码生成

- [ ] 在 `apps/lt_app/` 运行 `flutter pub get`
- [ ] 运行 `flutter pub run build_runner build --delete-conflicting-outputs`

---

## 阶段 6：清理旧代码

### Task 6.1：删除旧的 Service 包

⚠️ **警告**：在确认所有功能正常后再执行此步骤

- [ ] 备份 `packages/service/` 目录
- [ ] 删除 `packages/service/lt_reflection_service/`
- [ ] 删除 `packages/service/chain_service/`（如果已迁移）
- [ ] 删除 `packages/service/` 目录（如果为空）

### Task 6.2：更新文档

- [ ] 更新 `README.md`
  - [ ] 更新架构图
  - [ ] 更新包结构说明
  - [ ] 更新开发指南
- [ ] 更新 `.kiro/specs/flutter-advanced-learning-plan/project-architecture.md`
- [ ] 更新 `docs/shared-dependencies.md`（如果需要）

---

## 阶段 7：测试和验证

### Task 7.1：编译检查

- [ ] 在根目录运行 `flutter pub get`
- [ ] 运行 `flutter analyze`
- [ ] 修复所有编译错误和警告

### Task 7.2：功能测试

- [ ] 测试日历功能
  - [ ] 加载日历数据
  - [ ] 切换月份
  - [ ] 选择日期
- [ ] 测试 Thread 功能
  - [ ] 加载问题列表
  - [ ] 查看问题详情
- [ ] 测试今日问题功能
  - [ ] 加载今日问题
  - [ ] 提交答案
- [ ] 测试答案详情功能
- [ ] 测试用户中心功能
- [ ] 测试钱包功能

### Task 7.3：单元测试（如果存在）

- [ ] 运行现有单元测试
- [ ] 修复失败的测试
- [ ] 添加新的单元测试（可选）

### Task 7.4：集成测试（如果存在）

- [ ] 运行集成测试
- [ ] 修复失败的测试

---

## 阶段 8：优化和完善

### Task 8.1：代码优化

- [ ] 检查所有 import 语句，移除未使用的导入
- [ ] 统一代码风格
- [ ] 添加必要的注释

### Task 8.2：性能优化

- [ ] 检查不必要的重建
- [ ] 优化 Provider 依赖
- [ ] 检查内存泄漏

### Task 8.3：错误处理

- [ ] 统一异常处理
- [ ] 添加用户友好的错误提示
- [ ] 添加日志记录

---

## 任务优先级

### P0（必须完成）

- 阶段 1：创建新的包结构
- 阶段 2：实现 Domain Layer
- 阶段 3：实现 Data Layer
- 阶段 4：重构 Features Layer
- 阶段 5：更新 Apps Layer
- 阶段 7.1：编译检查
- 阶段 7.2：功能测试

### P1（重要）

- 阶段 6：清理旧代码
- 阶段 7.3：单元测试
- 阶段 8.1：代码优化

### P2（可选）

- 阶段 7.4：集成测试
- 阶段 8.2：性能优化
- 阶段 8.3：错误处理增强

---

## 检查清单

### 编译检查

- [ ] 所有包可以成功运行 `flutter pub get`
- [ ] 所有包可以成功运行 `flutter analyze`
- [ ] 没有编译错误
- [ ] 没有严重的警告

### 架构检查

- [ ] Domain 层不依赖任何框架（除了纯 Dart 包）
- [ ] Data 层实现了 Domain 层的接口
- [ ] Features 层只依赖 Domain 层和 Core 层
- [ ] 依赖方向正确：Features → Domain ← Data → Core

### 功能检查

- [ ] 所有页面可以正常打开
- [ ] 所有数据可以正常加载
- [ ] 所有用户操作可以正常执行
- [ ] 错误处理正常工作

### 代码质量检查

- [ ] 代码风格统一
- [ ] 没有未使用的导入
- [ ] 没有未使用的变量
- [ ] 注释清晰准确

---

## 回滚计划

如果重构过程中遇到严重问题，可以按以下步骤回滚：

1. **使用 Git 回滚**
   ```bash
   git checkout <commit-before-refactoring>
   ```

2. **保留新代码，恢复旧代码**
   - 保留 `packages/domain/` 和 `packages/data/`
   - 恢复 `packages/service/`
   - 恢复 `apps/lt_app/` 的依赖配置

3. **渐进式迁移**
   - 先迁移一个功能模块（如 Calendar）
   - 验证功能正常后再迁移其他模块

---

## 注意事项

1. **代码生成**：每次修改 Model 或 State 后，记得运行 `build_runner`
2. **依赖顺序**：先创建 Domain 层，再创建 Data 层，最后更新 Features 层
3. **测试频率**：每完成一个阶段，都要进行编译和功能测试
4. **备份代码**：在删除旧代码前，确保备份
5. **Git 提交**：每完成一个阶段，提交一次代码

---

## 预估时间

- **阶段 1**：30 分钟
- **阶段 2**：1.5 小时
- **阶段 3**：2 小时
- **阶段 4**：2 小时
- **阶段 5**：1 小时
- **阶段 6**：30 分钟
- **阶段 7**：1.5 小时
- **阶段 8**：1 小时

**总计**：约 10 小时

---

## 下一步

准备好开始重构了吗？建议从阶段 1 开始，逐步完成每个任务。

# Clean Architecture 重构进度报告

## 已完成的工作

### ✅ 阶段 1：创建新的包结构（100%）

- [x] 创建 `packages/domain_layer/` 包
- [x] 创建 `packages/data_layer/` 包
- [x] 配置 pubspec.yaml 文件
- [x] 创建目录结构

### ✅ 阶段 2：实现 Domain Layer（100%）

#### Entities（100%）
- [x] `question_entity.dart` - 问题实体
- [x] `answer_entity.dart` - 答案实体
- [x] `calendar_entity.dart` - 日历实体
- [x] `category_entity.dart` - 分类实体
- [x] `icon_entity.dart` - 图标实体
- [x] `user_entity.dart` - 用户实体
- [x] `wallet_entity.dart` - 钱包实体

#### Repository 接口（100%）
- [x] `reflection_repository.dart` - 反思相关接口
- [x] `user_repository.dart` - 用户相关接口
- [x] `wallet_repository.dart` - 钱包相关接口

#### UseCases（100%）
- [x] Reflection UseCases
  - [x] `fetch_thread_questions.dart`
  - [x] `fetch_today_question.dart`
  - [x] `fetch_calendar_reflections.dart`
  - [x] `submit_answer.dart`
  - [x] `fetch_answer_detail.dart`
- [x] User UseCases
  - [x] `get_current_user.dart`
  - [x] `update_profile.dart`
  - [x] `logout.dart`
- [x] Wallet UseCases
  - [x] `get_wallet.dart`
  - [x] `get_transactions.dart`

### ✅ 阶段 3：实现 Data Layer（100%）

#### Models（100%）
- [x] `question_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `answer_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `calendar_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `category_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `icon_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `user_model.dart` - 包含 toEntity() 和 fromEntity()
- [x] `wallet_model.dart` - 包含 toEntity() 和 fromEntity()

#### DataSources（100%）
- [x] `reflection_remote_datasource.dart` - 反思相关数据源
- [x] `user_remote_datasource.dart` - 用户相关数据源
- [x] `wallet_remote_datasource.dart` - 钱包相关数据源

#### Repository 实现（100%）
- [x] `reflection_repository_impl.dart` - 实现 ReflectionRepository
- [x] `user_repository_impl.dart` - 实现 UserRepository
- [x] `wallet_repository_impl.dart` - 实现 WalletRepository

#### 代码生成（100%）
- [x] 运行 `flutter pub get`
- [x] 运行 `build_runner` 生成代码
- [x] 修复依赖版本冲突
- [x] 更新 SDK 版本为 ^3.8.0

### ✅ 阶段 4：重命名 Features（50%）

- [x] 使用 Git 重命名 `packages/domain/` → `packages/features/`
- [ ] 更新所有 feature 包的 pubspec.yaml
- [ ] 更新所有 feature 包的 import 语句

### ✅ 阶段 5：更新 Apps Layer（30%）

- [x] 创建 `apps/lt_app/lib/src/di/providers.dart` - 依赖注入配置
- [x] 更新 `apps/lt_app/pubspec.yaml` - 添加新依赖
- [ ] 更新路由配置
- [ ] 运行代码生成

---

## 剩余工作

### 🔄 阶段 4：重构 Features Layer（剩余 50%）

需要为每个 feature 包执行以下操作：

#### Calendar Feature
- [ ] 更新 `packages/features/calendar/pubspec.yaml`
  - [ ] 添加 `domain_layer` 依赖
  - [ ] 移除 `lt_reflection_service` 依赖
- [ ] 重构 `calendar_controller.dart`
  - [ ] 使用 `ref.read(fetchCalendarReflectionsProvider)`
  - [ ] 使用 Domain Entities 而非 DTOs
- [ ] 更新 `calendar_state.dart`
  - [ ] 使用 `CalendarDayEntity` 而非 `CalendardayDto`
- [ ] 更新所有 import 语句

#### Thread Feature
- [ ] 更新 `packages/features/thread/pubspec.yaml`
- [ ] 重构 `thread_controller.dart`
  - [ ] 使用 `ref.read(fetchThreadQuestionsProvider)`
- [ ] 更新所有 import 语句

#### Today Question Feature
- [ ] 更新 `packages/features/today_question/pubspec.yaml`
- [ ] 重构相关 controllers
  - [ ] 使用 `ref.read(fetchTodayQuestionProvider)`
- [ ] 更新所有 import 语句

#### Add Answer Feature
- [ ] 更新 `packages/features/add_answer/pubspec.yaml`
- [ ] 重构 `add_answer_controller.dart`
  - [ ] 使用 `ref.read(submitAnswerProvider)`
- [ ] 更新所有 import 语句

#### Answer Detail Feature
- [ ] 更新 `packages/features/answer_detail/pubspec.yaml`
- [ ] 重构 `answer_detail_controller.dart`
  - [ ] 使用 `ref.read(fetchAnswerDetailProvider)`
- [ ] 更新所有 import 语句

#### 其他 Features
- [ ] Copilot Feature
- [ ] User Feature
- [ ] Wallet Feature
- [ ] Feature Core

### 🔄 阶段 5：更新 Apps Layer（剩余 70%）

- [ ] 更新 `apps/lt_app/lib/src/app_router.dart`
  - [ ] 更新所有 import 语句
- [ ] 更新 `apps/lt_app/lib/main.dart`
  - [ ] 确保 ProviderScope 正确配置
- [ ] 运行 `flutter pub get`
- [ ] 运行 `build_runner` 生成代码

### 🔄 阶段 6：清理旧代码（0%）

⚠️ **警告**：在确认所有功能正常后再执行

- [ ] 备份 `packages/service/` 目录
- [ ] 删除 `packages/service/lt_reflection_service/`
- [ ] 删除 `packages/service/` 目录（如果为空）

### 🔄 阶段 7：测试和验证（0%）

- [ ] 编译检查
  - [ ] 运行 `flutter pub get`
  - [ ] 运行 `flutter analyze`
  - [ ] 修复所有编译错误
- [ ] 功能测试
  - [ ] 测试日历功能
  - [ ] 测试 Thread 功能
  - [ ] 测试今日问题功能
  - [ ] 测试答案提交功能

### 🔄 阶段 8：优化和完善（0%）

- [ ] 代码优化
- [ ] 性能优化
- [ ] 错误处理增强
- [ ] 更新文档

---

## 架构概览

### 当前架构

```
packages/
├── domain_layer/          ✅ 已创建（纯业务逻辑）
│   ├── entities/          ✅ 7 个实体
│   ├── repositories/      ✅ 3 个接口
│   └── usecases/          ✅ 10 个用例
│
├── data_layer/            ✅ 已创建（数据层）
│   ├── models/            ✅ 7 个模型（含转换方法）
│   ├── datasources/       ✅ 3 个数据源
│   └── repositories/      ✅ 3 个实现
│
├── features/              🔄 已重命名（需要更新依赖）
│   ├── calendar/          ⏳ 待重构
│   ├── thread/            ⏳ 待重构
│   ├── today_question/    ⏳ 待重构
│   ├── add_answer/        ⏳ 待重构
│   ├── answer_detail/     ⏳ 待重构
│   ├── copilot/           ⏳ 待重构
│   ├── user/              ⏳ 待重构
│   └── wallet/            ⏳ 待重构
│
├── core/                  ✅ 保持不变
│   ├── network/
│   ├── storage/
│   └── lt_uicomponent/
│
└── service/               ⚠️ 待删除
    └── lt_reflection_service/
```

### 依赖关系

```
Apps (lt_app)
  ↓ 依赖
Features (calendar, thread, ...)
  ↓ 依赖                    ↓ 依赖
Domain Layer              Core (UI Components)
  ↑ 实现
Data Layer
  ↓ 依赖
Core (Network, Storage)
```

---

## 关键文件

### 已创建的核心文件

1. **Domain Layer**
   - `packages/domain_layer/lib/domain_layer.dart` - 主导出文件
   - `packages/domain_layer/lib/entities/entities.dart` - 实体导出
   - `packages/domain_layer/lib/repositories/repositories.dart` - 接口导出
   - `packages/domain_layer/lib/usecases/usecases.dart` - 用例导出

2. **Data Layer**
   - `packages/data_layer/lib/data_layer.dart` - 主导出文件
   - `packages/data_layer/lib/models/models.dart` - 模型导出
   - `packages/data_layer/lib/datasources/datasources.dart` - 数据源导出
   - `packages/data_layer/lib/repositories/repositories.dart` - 实现导出

3. **Apps Layer**
   - `apps/lt_app/lib/src/di/providers.dart` - 依赖注入配置

---

## 下一步行动

### 优先级 P0（必须完成）

1. **重构 Calendar Feature**（最重要的功能模块）
   - 更新 pubspec.yaml
   - 重构 controller 使用新的 UseCases
   - 更新 State 使用 Entities
   - 测试功能

2. **重构 Thread Feature**
   - 更新 pubspec.yaml
   - 重构 controller
   - 测试功能

3. **重构 Today Question Feature**
   - 更新 pubspec.yaml
   - 重构 controller
   - 测试功能

4. **编译和测试**
   - 运行 `flutter pub get`
   - 运行 `flutter analyze`
   - 运行应用测试功能

### 优先级 P1（重要）

5. **重构其他 Features**
   - Add Answer
   - Answer Detail
   - Copilot
   - User
   - Wallet

6. **清理旧代码**
   - 删除 `packages/service/`

### 优先级 P2（可选）

7. **优化和完善**
   - 代码优化
   - 性能优化
   - 文档更新

---

## 预估剩余时间

- **阶段 4**（重构 Features）：3-4 小时
- **阶段 5**（更新 Apps）：1 小时
- **阶段 6**（清理）：30 分钟
- **阶段 7**（测试）：1.5 小时
- **阶段 8**（优化）：1 小时

**总计剩余时间**：约 7-8 小时

---

## 注意事项

1. **代码生成**：每次修改 Model 或 State 后，记得运行 `build_runner`
2. **依赖顺序**：先更新 pubspec.yaml，再更新代码
3. **测试频率**：每完成一个 feature，都要测试
4. **备份代码**：在删除旧代码前，确保备份
5. **Git 提交**：每完成一个阶段，提交一次代码

---

## 成功标准

- [x] Domain Layer 不依赖任何框架（只依赖纯 Dart）
- [x] Data Layer 实现了 Domain Layer 的接口
- [ ] Features Layer 只依赖 Domain Layer 和 Core Layer
- [ ] 所有代码可以正常编译
- [ ] 所有功能可以正常运行
- [ ] 依赖方向正确：Features → Domain ← Data → Core

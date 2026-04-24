# Workflow: usecase-workflow

> 触发命令：`/usecase-workflow`

## 用途

在 lt_app Monorepo 中，按照 Clean Architecture 规范快速创建一个完整的 UseCase，涵盖 Domain → Data → Feature 三层联动。

---

## 执行前：收集输入信息

在开始前，确认以下信息（如用户未提供，主动询问）：

| # | 输入项 | 示例 |
|---|--------|------|
| 1 | **Domain 名称** | `reflection` / `user` / `wallet` |
| 2 | **UseCase 动作名** | `FetchMonthlyReport` / `SubmitAnswer` |
| 3 | **入参列表** | `year: int, month: int` 或「无参数」|
| 4 | **返回值（Entity 类型）** | `MonthlyReportEntity` / `List<QuestionEntity>` |
| 5 | **目标 Feature 包名** | `calendar` / `thread` / `copilot` |
| 6 | **是否需要新 Repository 方法** | 是 / 否 |
| 7 | **业务校验规则** | 如「内容不能为空」/ 「无」|

---

## 执行：读取并严格遵循 SKILL 文档

收集完输入信息后，读取以下 SKILL 文档，并按其中的步骤逐一执行：

```
.agents/skills/create-usecase/SKILL.md
```

---

## 执行后：验证输出

所有步骤完成后，逐项核查：

```
Domain 层：
  [ ] usecases/<action>_usecase.dart  ← 已创建
  [ ] usecases/usecases.dart          ← 已添加 export
  [ ] Repository 接口                  ← 已声明新方法（如需要）

Data 层（仅在需要新 Repository 方法时）：
  [ ] <domain>_remote_datasource.dart       ← 接口已声明
  [ ] <domain>_remote_datasource_impl.dart  ← 方法已实现
  [ ] <domain>_repository_impl.dart         ← 方法已实现（含 toEntity()）

Feature 层：
  [ ] <feature>_providers.dart  ← UseCase Provider 已注册
  [ ] ViewModel 中已调用 useCase.execute()
  [ ] 代码生成已运行（如有 @riverpod 注解）
```

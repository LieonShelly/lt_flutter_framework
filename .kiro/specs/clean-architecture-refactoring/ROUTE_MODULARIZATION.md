# 路由模块化设计

## 概述

将路由配置从 App 层解耦，让每个 Feature 模块自己管理自己的路由配置，App 层只负责聚合这些路由。

## 设计原则

1. **职责分离**：每个 Feature 负责定义自己的路由
2. **解耦**：App 层不需要知道每个 Feature 的具体路由实现
3. **可扩展**：添加新 Feature 时，只需实现路由配置接口即可
4. **类型安全**：使用接口约束路由配置

## 架构设计

### 1. 路由配置接口

**位置**：`packages/features/feature_core/lib/src/route_config.dart`

```dart
abstract class FeatureRouteConfig {
  List<RouteBase> get routes;
  
  List<StatefulShellBranch>? get shellBranches => null;
}
```

**说明**：
- `routes`: 顶层路由（如详情页、添加页等）
- `shellBranches`: Shell 路由分支（如底部导航栏的各个 Tab）

### 2. Feature 路由配置实现

每个 Feature 实现 `FeatureRouteConfig` 接口，定义自己的路由。

#### Calendar Feature

**位置**：`packages/features/calendar/lib/src/calendar_route_config.dart`

```dart
class CalendarRouteConfig implements FeatureRouteConfig {
  @override
  List<RouteBase> get routes => [];

  @override
  List<StatefulShellBranch> get shellBranches => [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutePath.calendar,
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: CalendarPage()),
            ),
          ],
        ),
      ];
}
```

#### Answer Detail Feature

**位置**：`packages/features/answer_detail/lib/src/answer_detail_route_config.dart`

```dart
class AnswerDetailRouteConfig implements FeatureRouteConfig {
  final GlobalKey<NavigatorState> rootNavigatorKey;

  AnswerDetailRouteConfig(this.rootNavigatorKey);

  @override
  List<RouteBase> get routes => [
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRoutePath.answerDetail,
          pageBuilder: (context, state) {
            final answer = state.extra as AnswerModel;
            return CustomTransitionPage(
              key: state.pageKey,
              child: AnswerDetailPage(answer: answer),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: child,
                );
              },
            );
          },
        ),
      ];
}
```

### 3. App 层路由聚合

**位置**：`apps/lt_app/lib/src/app_router.dart`

```dart
@riverpod
GoRouter router(Ref ref) {
  final calendarRoutes = CalendarRouteConfig();
  final threadRoutes = ThreadRouteConfig();
  final copilotRoutes = CopilotRouteConfig();
  final userRoutes = UserRouteConfig();
  final answerDetailRoutes = AnswerDetailRouteConfig(_rootNavigatorKey);
  final addAnswerRoutes = AddAnswerRouteConfig(_rootNavigatorKey);

  final shellBranches = <StatefulShellBranch>[
    ...?calendarRoutes.shellBranches,
    ...?threadRoutes.shellBranches,
    ...?copilotRoutes.shellBranches,
    ...?userRoutes.shellBranches,
  ];

  final topLevelRoutes = <RouteBase>[
    ...calendarRoutes.routes,
    ...threadRoutes.routes,
    ...copilotRoutes.routes,
    ...userRoutes.routes,
    ...answerDetailRoutes.routes,
    ...addAnswerRoutes.routes,
  ];

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutePath.thread,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeView(navigationShell: navigationShell);
        },
        branches: shellBranches,
      ),
      ...topLevelRoutes,
    ],
  );
}
```

## 路由类型

### 1. Shell Branch 路由

用于底部导航栏的各个 Tab，使用 `StatefulShellBranch`。

**特点**：
- 保持状态
- 切换 Tab 时不会重建页面
- 适合主导航页面

**示例**：Calendar、Thread、Copilot、User

### 2. 顶层路由

用于详情页、添加页等全屏页面，使用 `GoRoute`。

**特点**：
- 全屏显示
- 可以自定义转场动画
- 需要 `parentNavigatorKey` 指定父导航器

**示例**：AnswerDetail、AddAnswer、Chat

## 添加新 Feature 的步骤

### 1. 创建路由配置类

在 Feature 包中创建 `*_route_config.dart`：

```dart
class MyFeatureRouteConfig implements FeatureRouteConfig {
  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutePath.myFeature,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MyFeaturePage()),
        ),
      ];
}
```

### 2. 导出路由配置

在 Feature 的主文件中导出：

```dart
export 'src/my_feature_route_config.dart';
```

### 3. 在 App 层聚合

在 `app_router.dart` 中添加：

```dart
final myFeatureRoutes = MyFeatureRouteConfig();

final topLevelRoutes = <RouteBase>[
  ...myFeatureRoutes.routes,
];
```

## 优势

### 1. 职责清晰

- Feature 层：定义自己的路由配置
- App 层：聚合所有路由配置

### 2. 解耦

- App 层不需要知道 Feature 的具体实现
- Feature 可以独立开发和测试

### 3. 可维护性

- 路由配置集中在各自的 Feature 中
- 修改路由不影响其他模块

### 4. 可扩展性

- 添加新 Feature 只需实现接口
- 不需要修改 App 层的核心逻辑

### 5. 类型安全

- 使用接口约束路由配置
- 编译时检查类型错误

## 对比

### 重构前

```dart
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePath.calendar,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CalendarPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePath.answerDetail,
        pageBuilder: (context, state) {
        },
      ),
    ],
  );
}
```

**问题**：
- App 层需要知道所有 Feature 的路由细节
- 路由配置集中在一个文件中，难以维护
- 添加新 Feature 需要修改 App 层代码

### 重构后

```dart
@riverpod
GoRouter router(Ref ref) {
  final calendarRoutes = CalendarRouteConfig();
  final answerDetailRoutes = AnswerDetailRouteConfig(_rootNavigatorKey);

  final shellBranches = <StatefulShellBranch>[
    ...?calendarRoutes.shellBranches,
  ];

  final topLevelRoutes = <RouteBase>[
    ...answerDetailRoutes.routes,
  ];

  return GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        branches: shellBranches,
      ),
      ...topLevelRoutes,
    ],
  );
}
```

**优势**：
- App 层只负责聚合路由
- 每个 Feature 管理自己的路由
- 添加新 Feature 只需实例化路由配置类

## 总结

路由模块化设计遵循了 Clean Architecture 的原则，实现了关注点分离和依赖倒置。每个 Feature 负责自己的路由配置，App 层只负责聚合，提高了代码的可维护性和可扩展性。

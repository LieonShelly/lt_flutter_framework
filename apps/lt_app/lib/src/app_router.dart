import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:add_answer/add_answer.dart';
import 'package:answer_detail/answer_detail.dart';
import 'package:calendar/calendar.dart';
import 'package:copilot/copilot.dart';
import 'home_view.dart';
import 'package:thread/thread.dart';
import 'package:user/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feature_core/feature_core.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final calendarRoutes = CalendarRouteConfig();
  final threadRoutes = ThreadRouteConfig();
  final copilotRoutes = CopilotRouteConfig();
  final userRoutes = UserRouteConfig();
  final answerDetailRoutes = AnswerDetailRouteConfig(_rootNavigatorKey);
  final addAnswerRoutes = AddAnswerRouteConfig(_rootNavigatorKey);

  final shellBranches = <StatefulShellBranch>[
    ...calendarRoutes.shellBranches ?? [],
    ...threadRoutes.shellBranches ?? [],
    ...copilotRoutes.shellBranches ?? [],
    ...userRoutes.shellBranches ?? [],
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

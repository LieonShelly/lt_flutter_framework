import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'chat_page.dart';
import 'package:flutter/material.dart';

class CopilotRouteConfig implements FeatureRouteConfig {
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.chat,
      pageBuilder: (context, state) {
        final page = ChatPage(key: state.pageKey);
        return MaterialPage(key: state.pageKey, child: page);
      },
    ),
  ];

  @override
  List<StatefulShellBranch> get shellBranches => [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutePath.insights,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ChatPage()),
        ),
      ],
    ),
  ];
}

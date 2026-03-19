import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'a2ui/a2ui_test_page.dart';

class ThreadRouteConfig implements FeatureRouteConfig {
  @override
  List<RouteBase> get routes => [];

  @override
  List<StatefulShellBranch> get shellBranches => [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutePath.thread,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: A2uiTestPage()),
        ),
      ],
    ),
  ];
}

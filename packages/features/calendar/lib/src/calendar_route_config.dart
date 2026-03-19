import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'calendar_page.dart';

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

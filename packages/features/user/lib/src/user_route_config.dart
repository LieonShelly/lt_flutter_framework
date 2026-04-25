import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'package:user/user.dart';

class UserRouteConfig implements FeatureRouteConfig {
  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.login,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginView(),
      ),
    ),

  ];

  @override
  List<StatefulShellBranch> get shellBranches => [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: AppRoutePath.user,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: UserHomePage()),
        ),
      ],
    ),
  ];
}

import 'package:go_router/go_router.dart';

abstract class FeatureRouteConfig {
  List<RouteBase> get routes;

  List<StatefulShellBranch>? get shellBranches => null;
}

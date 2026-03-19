import 'package:flutter/material.dart';
import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'add_answer_page.dart';

class AddAnswerRouteConfig extends FeatureRouteConfig {
  final GlobalKey<NavigatorState> rootNavigatorKey;

  AddAnswerRouteConfig(this.rootNavigatorKey);

  @override
  List<RouteBase> get routes => [
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: AppRoutePath.addAnswer,
      pageBuilder: (context, state) {
        final questions = state.extra as List<QuestionEntity>;
        final page = AddAnswerPage(key: state.pageKey, questions: questions);
        return MaterialPage(key: state.pageKey, child: page);
      },
    ),
  ];
}

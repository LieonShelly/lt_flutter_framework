import 'package:flutter/material.dart';
import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'package:reflection_data/reflection_data.dart';
import 'answer_detail_page.dart';

class AnswerDetailRouteConfig extends FeatureRouteConfig {
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
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  ),
              child: child,
            );
          },
        );
      },
    ),
  ];
}

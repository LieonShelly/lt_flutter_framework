import 'package:answer_detail/src/metal_overlay_editor.dart';
import 'package:flutter/material.dart';
import 'package:feature_core/feature_core.dart';
import 'package:go_router/go_router.dart';
import 'package:reflection_data/reflection_data.dart';
import 'package:reflection_domain/reflection_domain.dart';
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
        final answer = state.extra as AnswerEntity;
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

    GoRoute(
      path: AppRoutePath.iconEditor,
      pageBuilder: (context, state) {
        final imagePath = state.extra as String;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MetalOverlayEditor(imagePath: imagePath),
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

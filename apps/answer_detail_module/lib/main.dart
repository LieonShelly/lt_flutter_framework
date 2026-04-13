import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:answer_detail/answer_detail.dart';
import 'package:reflection_domain/reflection_domain.dart';

@pragma('vm:entry-point')
void main() {
  runApp(const ProviderScope(child: AnswerDetailModuleApp()));
}

class AnswerDetailModuleApp extends StatelessWidget {
  const AnswerDetailModuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        GoRoute(
          path: '/answer_detail',
          builder: (context, state) {
            final answer = state.extra as AnswerEntity;
            return AnswerDetailPage(answer: answer);
          },
        ),
        GoRoute(
          path: '/iconEditor',
          builder: (context, state) {
            final imagePath = state.extra as String;
            return ExternalTextureEditor(imagePath: imagePath);
          },
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Answer Detail Module',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFDF8),
      ),
    );
  }
}

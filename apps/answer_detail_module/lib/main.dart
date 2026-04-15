import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:answer_detail/answer_detail.dart';
import 'package:reflection_domain/reflection_domain.dart';

import 'src/generated/answer_detail_api.g.dart';
import 'src/answer_detail_flutter_api_impl.dart';
import 'src/navigation_flutter_api_impl.dart';
import 'src/pages/product_detail_page.dart';
import 'src/pages/order_confirm_page.dart';

@pragma('vm:entry-point')
void main() {
  debugPrint('=== Flutter main() started ===');
  runApp(const ProviderScope(child: AnswerDetailModuleApp()));
}

class AnswerDetailModuleApp extends StatefulWidget {
  const AnswerDetailModuleApp({super.key});

  @override
  State<AnswerDetailModuleApp> createState() => _AnswerDetailModuleAppState();
}

class _AnswerDetailModuleAppState extends State<AnswerDetailModuleApp> {
  final AnswerDetailHostApi _hostApi = AnswerDetailHostApi();
  final NavigationHostApi _navigationHostApi = NavigationHostApi();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
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
            return AnswerDetailPage(
              answer: answer,
              onClose: () {
                // 先导航回初始路由，销毁 AnswerDetailPage 的状态
                _router.go('/');
                // 再通知原生端关闭 FlutterViewController
                _hostApi.dismiss();
              },
            );
          },
        ),
        GoRoute(
          path: '/iconEditor',
          builder: (context, state) {
            final imagePath = state.extra as String;
            return ExternalTextureEditor(imagePath: imagePath);
          },
        ),
        GoRoute(
          path: '/product_detail',
          builder: (context, state) {
            final productId = state.extra as String;
            return ProductDetailPage(
              productId: productId,
              hostApi: _navigationHostApi,
            );
          },
        ),
        GoRoute(
          path: '/order_confirm',
          builder: (context, state) {
            final orderInfo = state.extra as Map<String, dynamic>;
            return OrderConfirmPage(
              orderId: orderInfo['orderId'] as String,
              productName: orderInfo['productName'] as String,
              price: orderInfo['price'] as double,
              hostApi: _navigationHostApi,
            );
          },
        ),
      ],
    );

    AnswerDetailFlutterApi.setUp(AnswerDetailFlutterApiImpl(_router));
    NavigationFlutterApi.setUp(NavigationFlutterApiImpl(_router));
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Answer Detail Module',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFDF8),
      ),
    );
  }
}

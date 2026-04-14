import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:answer_detail/answer_detail.dart';
import 'package:reflection_domain/reflection_domain.dart';

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
  final MethodChannel channel = MethodChannel('answer_detail_data_channel');
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

    // 只监听 iOS 端主动推送，不再主动请求
    channel.setMethodCallHandler((call) async {
      debugPrint('=== Flutter received method call: ${call.method} ===');
      if (call.method == 'setAnswerData') {
        final json = _castMap(call.arguments);
        final answer = AnswerEntity.fromJson(json);
        _router.go('/answer_detail', extra: answer);
      }
    });
  }

  /// 递归将 iOS 返回的 Map<Object?, Object?> 转换为 Map<String, dynamic>
  Map<String, dynamic> _castMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) {
        final dynamic castValue;
        if (value is Map) {
          castValue = _castMap(value);
        } else if (value is List) {
          castValue = value.map((e) => e is Map ? _castMap(e) : e).toList();
        } else {
          castValue = value;
        }
        return MapEntry(key.toString(), castValue);
      });
    }
    throw ArgumentError('Expected a Map but got ${data.runtimeType}');
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

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'generated/answer_detail_api.g.dart';
import 'pigeon_converters.dart';

class AnswerDetailFlutterApiImpl implements AnswerDetailFlutterApi {
  final GoRouter _router;

  AnswerDetailFlutterApiImpl(this._router);

  @override
  void setAnswerData(ApiAnswer answer) {
    try {
      final entity = answer.toAnswerEntity();
      _router.go('/answer_detail', extra: entity);
    } catch (e, stackTrace) {
      debugPrint('=== ERROR in setAnswerData: $e ===');
      debugPrint('=== $stackTrace ===');
    }
  }
}

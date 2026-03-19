import 'package:intl/intl.dart';

import 'package:reflection_domain/reflection_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'providers/providers.dart';

part 'add_answer_controller.g.dart';

@riverpod
class AddAnswerController extends _$AddAnswerController {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> submitAnswer({
    required String questionId,
    required String content,
  }) async {
    final useCase = ref.read(submitAnswerUsecaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await useCase.execute(questionId: questionId, content: content);
    });
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './providers/thread_providers.dart';
part 'thread_page_controller.freezed.dart';
part 'thread_page_controller.g.dart';

@freezed
class ThreadPageState with _$ThreadPageState {
  final AsyncValue<List<QuestionEntity>> questions;

  ThreadPageState({required this.questions});
}

@riverpod
final class ThreadPageController extends _$ThreadPageController {
  @override
  ThreadPageState build() {
    _fetchThreadData();
    return ThreadPageState(questions: AsyncValue.loading());
  }

  void _fetchThreadData() async {
    final useCase = ref.read(fetchThreadQuestionsUseCaseProvider);
    try {
      final list = await useCase.execute();
      if (!ref.mounted) return;
      state = state.copyWith(questions: AsyncValue.data(list));
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = state.copyWith(questions: AsyncValue.error(e, stack));
    }
  }
}

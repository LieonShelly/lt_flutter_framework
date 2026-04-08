import 'package:reflection_domain/reflection_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './providers/today_question_providers.dart';
part 'today_question_banner_controller.g.dart';

@riverpod
class TodayQuestionBannerController extends _$TodayQuestionBannerController {
  @override
  Future<List<QuestionEntity>> build() async {
    final usecase = ref.read(fethTodayQuestionUseCaseProvider);
    return await usecase.execute();
  }
}

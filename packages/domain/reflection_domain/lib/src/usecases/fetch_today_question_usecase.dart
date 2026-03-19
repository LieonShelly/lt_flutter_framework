import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取今日问题的用例接口
abstract interface class FetchTodayQuestionUseCaseType {
  Future<List<QuestionEntity>> execute();
}

/// 获取今日问题的用例实现
class FetchTodayQuestionUseCase implements FetchTodayQuestionUseCaseType {
  final ReflectionRepository _repository;

  const FetchTodayQuestionUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> execute() async {
    return await _repository.fetchTodayQuestions();
  }
}

import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class FetchTodayQuestionUseCaseType {
  Future<List<QuestionEntity>> execute();
}

class FetchTodayQuestionUseCase implements FetchTodayQuestionUseCaseType {
  final ReflectionRepository _repository;

  const FetchTodayQuestionUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> execute() async {
    return await _repository.fetchTodayQuestions();
  }
}

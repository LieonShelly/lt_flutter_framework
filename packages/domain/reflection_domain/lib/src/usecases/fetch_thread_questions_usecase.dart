import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class FetchThreadQuestionsUseCaseType {
  Future<List<QuestionEntity>> execute();
}

class FetchThreadQuestionsUseCase implements FetchThreadQuestionsUseCaseType {
  final ReflectionRepository _repository;

  const FetchThreadQuestionsUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> execute() async {
    final questions = await _repository.fetchThreadQuestions();

    questions.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return 0;
    });

    return questions;
  }
}

import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取 Thread 问题列表的用例接口
abstract interface class FetchThreadQuestionsUseCaseType {
  Future<List<QuestionEntity>> execute();
}

/// 获取 Thread 问题列表的用例实现
class FetchThreadQuestionsUseCase implements FetchThreadQuestionsUseCaseType {
  final ReflectionRepository _repository;

  const FetchThreadQuestionsUseCase(this._repository);

  @override
  Future<List<QuestionEntity>> execute() async {
    final questions = await _repository.fetchThreadQuestions();

    // 业务逻辑：按 pinned 排序
    questions.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return 0;
    });

    return questions;
  }
}

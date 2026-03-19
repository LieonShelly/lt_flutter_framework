import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class SubmitAnswerUseCaseType {
  Future<AnswerEntity> execute({
    required String questionId,
    required String content,
    String? iconId,
  });
}

class SubmitAnswerUseCase implements SubmitAnswerUseCaseType {
  final ReflectionRepository _repository;

  const SubmitAnswerUseCase(this._repository);

  @override
  Future<AnswerEntity> execute({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('答案内容不能为空');
    }

    if (content.length > 1000) {
      throw ArgumentError('答案内容不能超过 1000 字');
    }

    return await _repository.submitAnswer(
      questionId: questionId,
      content: content,
      iconId: iconId,
    );
  }
}

import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class FetchAnswerDetailUseCaseType {
  Future<AnswerEntity> execute(String answerId);
}

class FetchAnswerDetailUseCase implements FetchAnswerDetailUseCaseType {
  final ReflectionRepository _repository;

  const FetchAnswerDetailUseCase(this._repository);

  @override
  Future<AnswerEntity> execute(String answerId) async {
    return await _repository.fetchAnswerDetail(answerId);
  }
}

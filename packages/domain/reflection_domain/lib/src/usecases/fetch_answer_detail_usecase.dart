import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取答案详情的用例接口
abstract interface class FetchAnswerDetailUseCaseType {
  Future<AnswerEntity> execute(String answerId);
}

/// 获取答案详情的用例实现
class FetchAnswerDetailUseCase implements FetchAnswerDetailUseCaseType {
  final ReflectionRepository _repository;

  const FetchAnswerDetailUseCase(this._repository);

  @override
  Future<AnswerEntity> execute(String answerId) async {
    return await _repository.fetchAnswerDetail(answerId);
  }
}

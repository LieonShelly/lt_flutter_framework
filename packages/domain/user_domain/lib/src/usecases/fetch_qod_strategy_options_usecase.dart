import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取 QoD 策略选项列表 UseCase
/// API: GET /api/qod-strategy-options
abstract interface class FetchQodStrategyOptionsUseCaseType {
  Future<List<QodStrategyOptionEntity>> execute();
}

class FetchQodStrategyOptionsUseCase
    implements FetchQodStrategyOptionsUseCaseType {
  final UserRepository _repository;

  const FetchQodStrategyOptionsUseCase(this._repository);

  @override
  Future<List<QodStrategyOptionEntity>> execute() async {
    return await _repository.fetchQodStrategyOptions();
  }
}

import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 更新 QoD（今日问题）策略 UseCase
/// API: POST /api/qod-strategy
abstract interface class UpdateQodStrategyUseCaseType {
  Future<void> execute(QodStrategy strategy);
}

class UpdateQodStrategyUseCase implements UpdateQodStrategyUseCaseType {
  final UserRepository _repository;

  const UpdateQodStrategyUseCase(this._repository);

  @override
  Future<void> execute(QodStrategy strategy) async {
    await _repository.updateQodStrategy(strategy);
  }
}

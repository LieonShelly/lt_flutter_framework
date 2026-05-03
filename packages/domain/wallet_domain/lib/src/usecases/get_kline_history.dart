import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class GetKlineHistory {
  Future<List<CandleEntity>> call(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit,
  });
}

class GetKlineHistoryImpl implements GetKlineHistory {
  final KlineRepository _repository;

  const GetKlineHistoryImpl(this._repository);

  @override
  Future<List<CandleEntity>> call(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) {
    return _repository.getHistory(
      key,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
    );
  }
}

import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class WatchKlineRealtime {
  Stream<CandleEntity> call(KlineKey key);
}

class WatchKlineRealtimeImpl implements WatchKlineRealtime {
  final KlineRepository _repository;

  const WatchKlineRealtimeImpl(this._repository);

  @override
  Stream<CandleEntity> call(KlineKey key) {
    return _repository.watchRealtime(key);
  }
}

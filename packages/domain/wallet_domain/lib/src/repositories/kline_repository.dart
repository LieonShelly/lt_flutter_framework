import '../entities/entities.dart';

abstract interface class KlineRepository {
  Future<List<CandleEntity>> getHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  });

  Stream<CandleEntity> watchRealtime(KlineKey key);

  Future<List<CandleEntity>> loadMoreBefore(
    KlineKey key,
    int beforeOpenTime, {
    int limit = 500,
  });

  Future<List<CandleEntity>> recoverFrom(KlineKey key, int fromOpenTime);
}

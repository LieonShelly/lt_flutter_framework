import 'dart:async';

import 'package:wallet_domain/wallet_domain.dart';

import '../datasources/datasources.dart';
import 'kline_store.dart';

class KlineRepositoryImpl implements KlineRepository {
  final KlineRemoteDataSource _remoteDataSource;
  final KlineStore _store;

  const KlineRepositoryImpl(this._remoteDataSource, this._store);

  @override
  Future<List<CandleEntity>> getHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final snapshot = await _remoteDataSource.fetchHistory(
      key,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
    );
    return _store.replaceSnapshot(key, snapshot);
  }

  @override
  Future<List<CandleEntity>> loadMoreBefore(
    KlineKey key,
    int beforeOpenTime, {
    int limit = 500,
  }) async {
    final older = await _remoteDataSource.fetchHistory(
      key,
      endTime: beforeOpenTime - 1,
      limit: limit,
    );
    return _store.prependHistory(key, older);
  }

  @override
  Future<List<CandleEntity>> recoverFrom(KlineKey key, int fromOpenTime) async {
    final recovered = await _remoteDataSource.fetchHistory(
      key,
      startTime: fromOpenTime,
      limit: 500,
    );

    var candles = _store.candlesOf(key);
    for (final candle in recovered) {
      candles = _store.mergeIncoming(key, candle);
    }
    return candles;
  }

  @override
  Stream<CandleEntity> watchRealtime(KlineKey key) {
    return _remoteDataSource.subscribeRealtime(key).map((candle) {
      _store.mergeIncoming(key, candle);
      return candle;
    });
  }
}

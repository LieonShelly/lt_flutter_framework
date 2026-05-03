import 'package:wallet_domain/wallet_domain.dart';

class KlineStore {
  final Map<KlineKey, List<CandleEntity>> _candlesByKey = {};
  final Map<KlineKey, Map<int, int>> _indexByOpenTime = {};

  List<CandleEntity> candlesOf(KlineKey key) {
    return List.unmodifiable(_candlesByKey[key] ?? const []);
  }

  List<CandleEntity> replaceSnapshot(KlineKey key, List<CandleEntity> candles) {
    final merged = _dedupeAndSort(candles);
    _candlesByKey[key] = merged;
    _rebuildIndex(key);
    return candlesOf(key);
  }

  List<CandleEntity> prependHistory(KlineKey key, List<CandleEntity> older) {
    final current = _candlesByKey[key] ?? const <CandleEntity>[];
    _candlesByKey[key] = _dedupeAndSort([...older, ...current]);
    _rebuildIndex(key);
    return candlesOf(key);
  }

  List<CandleEntity> mergeIncoming(KlineKey key, CandleEntity incoming) {
    final candles = List<CandleEntity>.from(_candlesByKey[key] ?? const []);
    if (candles.isEmpty) {
      candles.add(incoming);
      _candlesByKey[key] = candles;
      _rebuildIndex(key);
      return candlesOf(key);
    }

    final last = candles.last;
    if (incoming.openTime == last.openTime) {
      candles[candles.length - 1] = incoming;
    } else if (incoming.openTime > last.openTime) {
      candles.add(incoming);
    } else {
      final index = _indexByOpenTime[key]?[incoming.openTime];
      if (index != null) {
        candles[index] = incoming;
      }
    }

    _candlesByKey[key] = candles;
    _rebuildIndex(key);
    return candlesOf(key);
  }

  List<int> findMissingOpenTimes(KlineKey key) {
    final candles = _candlesByKey[key] ?? const <CandleEntity>[];
    if (candles.length < 2) {
      return const [];
    }

    final intervalMs = key.interval.duration.inMilliseconds;
    final missing = <int>[];
    for (var index = 1; index < candles.length; index++) {
      final previous = candles[index - 1].openTime;
      final current = candles[index].openTime;
      var expected = previous + intervalMs;
      while (expected < current) {
        missing.add(expected);
        expected += intervalMs;
      }
    }
    return missing;
  }

  List<CandleEntity> _dedupeAndSort(List<CandleEntity> candles) {
    final byOpenTime = <int, CandleEntity>{};
    for (final candle in candles) {
      byOpenTime[candle.openTime] = candle;
    }
    return byOpenTime.values.toList()
      ..sort((left, right) => left.openTime.compareTo(right.openTime));
  }

  void _rebuildIndex(KlineKey key) {
    final candles = _candlesByKey[key] ?? const <CandleEntity>[];
    _indexByOpenTime[key] = {
      for (var index = 0; index < candles.length; index++)
        candles[index].openTime: index,
    };
  }
}

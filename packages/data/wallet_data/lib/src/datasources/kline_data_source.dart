import 'dart:async';
import 'dart:math';

import 'package:wallet_domain/wallet_domain.dart';

abstract interface class KlineRemoteDataSource {
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  });

  Stream<CandleEntity> subscribeRealtime(KlineKey key);
}

class MockKlineRemoteDataSource implements KlineRemoteDataSource {
  const MockKlineRemoteDataSource();

  @override
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final intervalMs = key.interval.duration.inMilliseconds;
    final now = DateTime.now().millisecondsSinceEpoch;
    final alignedNow = _alignTime(now, intervalMs);
    final lastOpenTime = endTime == null
        ? alignedNow
        : _alignTime(endTime, intervalMs);
    final basePrice = _basePriceFor(key.symbol.raw);

    return List<CandleEntity>.generate(limit, (index) {
      final openTime = lastOpenTime - (limit - index - 1) * intervalMs;
      return _buildCandle(
        openTime: openTime,
        intervalMs: intervalMs,
        basePrice: basePrice,
        seed: index + openTime ~/ intervalMs,
        isFinal: openTime < alignedNow,
      );
    });
  }

  @override
  Stream<CandleEntity> subscribeRealtime(KlineKey key) {
    final intervalMs = key.interval.duration.inMilliseconds;
    final basePrice = _basePriceFor(key.symbol.raw);

    return Stream<CandleEntity>.periodic(const Duration(seconds: 1), (tick) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final openTime = _alignTime(now, intervalMs);
      return _buildCandle(
        openTime: openTime,
        intervalMs: intervalMs,
        basePrice: basePrice,
        seed: tick + openTime ~/ intervalMs,
        isFinal: false,
      );
    }).asBroadcastStream();
  }

  int _alignTime(int timestampMs, int intervalMs) {
    return timestampMs - timestampMs % intervalMs;
  }

  double _basePriceFor(String symbol) {
    if (symbol.contains('ETH')) {
      return 3100;
    }
    if (symbol.contains('SOL')) {
      return 145;
    }
    return 64000;
  }

  CandleEntity _buildCandle({
    required int openTime,
    required int intervalMs,
    required double basePrice,
    required int seed,
    required bool isFinal,
  }) {
    final random = Random(seed);
    final wave = sin(seed / 7) * basePrice * 0.015;
    final open = basePrice + wave + random.nextDouble() * basePrice * 0.004;
    final close = open + (random.nextDouble() - 0.5) * basePrice * 0.01;
    final high = max(open, close) + random.nextDouble() * basePrice * 0.006;
    final low = min(open, close) - random.nextDouble() * basePrice * 0.006;
    final volume = 20 + random.nextDouble() * 300;

    return CandleEntity(
      openTime: openTime,
      closeTime: openTime + intervalMs - 1,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
      quoteVolume: volume * close,
      tradeCount: 10 + random.nextInt(500),
      isFinal: isFinal,
    );
  }
}

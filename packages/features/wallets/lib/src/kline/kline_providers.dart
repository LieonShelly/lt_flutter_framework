import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'kline_view_model.dart';

final defaultKlineKeyProvider = Provider<KlineKey>((ref) {
  return const KlineKey(
    market: MarketEntity(exchange: 'binance', type: MarketType.spot),
    symbol: TradingSymbolEntity(
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      raw: 'BTCUSDT',
    ),
    interval: KlineInterval.m1,
  );
}, name: 'defaultKlineKeyProvider');

final klineViewModelProvider = NotifierProvider<KlineViewModel, KlineState>(
  KlineViewModel.new,
  name: 'klineViewModelProvider',
);

/// Binance Kline key provider
final binanceKlineKeyProvider = Provider.family<KlineKey, BinanceKlineParams>(
  (ref, params) {
    return KlineKey(
      market: const MarketEntity(exchange: 'binance', type: MarketType.spot),
      symbol: TradingSymbolEntity(
        baseAsset: params.baseAsset,
        quoteAsset: params.quoteAsset,
        raw: '${params.baseAsset}${params.quoteAsset}',
      ),
      interval: params.interval,
    );
  },
  name: 'binanceKlineKeyProvider',
);

class BinanceKlineParams {
  final String baseAsset;
  final String quoteAsset;
  final KlineInterval interval;

  const BinanceKlineParams({
    required this.baseAsset,
    required this.quoteAsset,
    this.interval = KlineInterval.m1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinanceKlineParams &&
          runtimeType == other.runtimeType &&
          baseAsset == other.baseAsset &&
          quoteAsset == other.quoteAsset &&
          interval == other.interval;

  @override
  int get hashCode => Object.hash(baseAsset, quoteAsset, interval);
}

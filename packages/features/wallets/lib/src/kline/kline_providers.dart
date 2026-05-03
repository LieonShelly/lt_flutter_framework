import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'kline_view_model.dart';

final defaultKlineKeyProvider = Provider<KlineKey>((ref) {
  return const KlineKey(
    market: MarketEntity(exchange: 'mock', type: MarketType.spot),
    symbol: TradingSymbolEntity(
      baseAsset: 'BTC',
      quoteAsset: 'USDT',
      raw: 'BTCUSDT',
    ),
    interval: KlineInterval.m1,
  );
}, name: 'defaultKlineKeyProvider');

final klineViewModelProvider = Provider<KlineViewModel>((ref) {
  final repository = ref.watch(klineRepositoryProvider);
  final key = ref.watch(defaultKlineKeyProvider);
  final viewModel = KlineViewModel(repository: repository, initialKey: key);
  ref.onDispose(viewModel.dispose);
  return viewModel;
}, name: 'klineViewModelProvider');

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kline_providers.dart';
import 'widgets/kline_candle_chart.dart';
import 'widgets/kline_interval_selector.dart';

class KlineChartPage extends ConsumerStatefulWidget {
  const KlineChartPage({super.key});

  @override
  ConsumerState<KlineChartPage> createState() => _KlineChartPageState();
}

class _KlineChartPageState extends ConsumerState<KlineChartPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(klineViewModelProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      ref.read(klineViewModelProvider.notifier).loadMoreBefore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(klineViewModelProvider);
    final key = ref.watch(defaultKlineKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(key.symbol.displayName),
        actions: [
          if (state.isReconnecting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IntervalSelector(
              selectedInterval: key.interval,
              onIntervalChanged: (interval) {
                // TODO: Implement interval switching via app_providers
              },
            ),
            SizedBox(
              height: 300,
              child: state.isLoading && state.candles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.candles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('加载失败: ${state.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(klineViewModelProvider.notifier).loadInitial();
                                },
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : KlineCandleChart(
                          candles: state.candles,
                          scrollController: _scrollController,
                        ),
            ),
            _buildCurrentPriceInfo(state),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPriceInfo(KlineState state) {
    if (state.candles.isEmpty) return const SizedBox.shrink();

    final lastCandle = state.candles.last;
    final priceChange = lastCandle.close - lastCandle.open;
    final priceChangePercent = (priceChange / lastCandle.open) * 100;
    final isPositive = priceChange >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriceColumn('当前价', lastCandle.close.toStringAsFixed(2),
              isPositive ? Colors.green : Colors.red),
          _buildPriceColumn(
              '涨跌幅', '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
              isPositive ? Colors.green : Colors.red),
          _buildPriceColumn('最高', lastCandle.high.toStringAsFixed(2), null),
          _buildPriceColumn('最低', lastCandle.low.toStringAsFixed(2), null),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

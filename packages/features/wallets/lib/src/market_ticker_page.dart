import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wallet_data/wallet_data.dart';

class MarketTickerPage extends StatefulWidget {
  @override
  _MarketTickerPageState createState() => _MarketTickerPageState();
}

class _MarketTickerPageState extends State<MarketTickerPage> {
  late final MarketDataService _dataService;
  List<TickerModel> _tickers = [];
  // ✅ 优化2：缓存耗时计算结果，只在价格变化时重新计算
  final Map<String, double> _computeCache = {};
  StreamSubscription<List<TickerModel>>? _subscription;

  @override
  void initState() {
    super.initState();
    _dataService = MarketDataService();
    _dataService.connect();

    // ✅ 优化3：手动监听 stream，用 setState 精确控制刷新
    _subscription = _dataService.tickerStream.listen((tickers) {
      setState(() {
        _tickers = tickers;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _dataService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('优化后：实时行情')),
      body: _tickers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tickers.length,
              itemBuilder: (context, index) {
                final ticker = _tickers[index];
                return _TickerItem(
                  key: ValueKey(ticker.symbol),
                  ticker: ticker,
                  computeCache: _computeCache,
                );
              },
            ),
    );
  }
}

// ✅ 优化4：独立的 StatefulWidget，配合 ValueKey 只重建数据变化的 item
class _TickerItem extends StatefulWidget {
  final TickerModel ticker;
  final Map<String, double> computeCache;

  const _TickerItem({
    super.key,
    required this.ticker,
    required this.computeCache,
  });

  @override
  State<_TickerItem> createState() => _TickerItemState();
}

class _TickerItemState extends State<_TickerItem> {
  double? _computedValue;
  bool _computing = false;

  @override
  void initState() {
    super.initState();
    _tryCompute();
  }

  @override
  void didUpdateWidget(covariant _TickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ticker.price != widget.ticker.price) {
      _tryCompute();
    }
  }

  void _tryCompute() {
    final symbol = widget.ticker.symbol;
    final cacheKey = '${symbol}_${widget.ticker.price.toStringAsFixed(4)}';

    // ✅ 命中缓存直接用
    if (widget.computeCache.containsKey(cacheKey)) {
      _computedValue = widget.computeCache[cacheKey];
      return;
    }

    // ✅ 清理该 symbol 的旧缓存，只保留最新 price
    widget.computeCache.removeWhere((key, _) => key.startsWith('${symbol}_'));

    if (!_computing) {
      _computing = true;
      compute(_heavyCompute, widget.ticker.price).then((result) {
        if (mounted) {
          widget.computeCache[cacheKey] = result;
          setState(() {
            _computedValue = result;
            _computing = false;
          });
        }
      });
    }
  }

  // 在 isolate 中执行的耗时计算
  static double _heavyCompute(double price) {
    double dummy = 0;
    for (int i = 0; i < 2000000; i++) {
      dummy += (price * i).hashCode % 7;
    }
    return dummy;
  }

  @override
  Widget build(BuildContext context) {
    final ticker = widget.ticker;
    final dummy = _computedValue ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(child: Text(ticker.symbol.split('_').last)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticker.symbol,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '计算值: ${dummy.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '\$${ticker.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

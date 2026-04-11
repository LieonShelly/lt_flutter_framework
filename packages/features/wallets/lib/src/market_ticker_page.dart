// market_ticker_page.dart
import 'package:flutter/material.dart';
import 'package:wallet_data/wallet_data.dart';

class MarketTickerPage extends StatefulWidget {
  @override
  _MarketTickerPageState createState() => _MarketTickerPageState();
}

class _MarketTickerPageState extends State<MarketTickerPage> {
  late final MarketDataService _dataService;

  @override
  void initState() {
    super.initState();
    _dataService = MarketDataService();
    _dataService.connect();
  }

  @override
  void dispose() {
    _dataService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('卡顿复现：实时行情')),
      body: StreamBuilder<List<TickerModel>>(
        // 🔴 灾难源头：包裹了整个列表
        stream: _dataService.tickerStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tickers = snapshot.data!;

          return ListView.builder(
            itemCount: tickers.length,
            itemBuilder: (context, index) {
              final ticker = tickers[index];

              // 🔴 模拟耗时操作：在 build 中做同步计算，阻塞主线程
              // 每个 item 都会执行，50 个 item × 每秒 10 次推送 = 每秒 500 次重计算
              double dummy = 0;
              for (int i = 0; i < 2000000; i++) {
                dummy += (ticker.price * i).hashCode % 7;
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔴 每次 rebuild 都创建新的 BoxDecoration + 渐变 + 阴影
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color((dummy.toInt() & 0x00FFFFFF) | 0xFF000000),
                              Colors.blue,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ticker.symbol.split('_').last,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
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
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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
      appBar: AppBar(title: Text('实时行情看板')),
      body: Center(
        child: StreamBuilder<TickerModel>(
          stream: _dataService.tickerStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('数据加载错误: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final ticker = snapshot.data!;
            return _buildTickerCard(ticker);
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dataService.sendMessage("Hello Server, 我是 Flutter 客户端!");
        },
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _buildTickerCard(TickerModel ticker) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ticker.symbol,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 使用等宽字体防止价格跳动时 UI 闪烁
            Text(
              '\$${ticker.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 48,
                color: Colors.green,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '最后更新: ${ticker.timestamp}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

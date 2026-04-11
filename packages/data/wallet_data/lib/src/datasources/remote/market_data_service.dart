import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_data/wallet_data.dart';

class MarketDataService {
  WebSocketChannel? _channel;
  Timer? _throttleTimer;
  List<TickerModel>? _latestTickers;

  final StreamController<List<TickerModel>> _tickerController =
      StreamController<List<TickerModel>>.broadcast();
  Stream<List<TickerModel>> get tickerStream => _tickerController.stream;

  void connect() {
    final uri = Uri.parse('ws://127.0.0.1:8000/ws');

    try {
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) {
          final List<dynamic> dataList = jsonDecode(message);
          final tickers = dataList.map((e) => TickerModel.fromJson(e)).toList();

          // ✅ 优化1：节流 — 缓存最新数据，每 200ms 才推送一次给 UI
          _latestTickers = tickers;
          _throttleTimer ??= Timer(const Duration(milliseconds: 200), () {
            if (_latestTickers != null) {
              _tickerController.add(_latestTickers!);
              _latestTickers = null;
            }
            _throttleTimer = null;
          });
        },
        onError: (error) {
          print('WebSocket 发生错误: $error');
        },
        onDone: () {
          print('WebSocket 连接已关闭');
        },
      );
    } catch (e) {
      print('连接异常: $e');
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void dispose() {
    _throttleTimer?.cancel();
    _channel?.sink.close();
    _tickerController.close();
  }
}

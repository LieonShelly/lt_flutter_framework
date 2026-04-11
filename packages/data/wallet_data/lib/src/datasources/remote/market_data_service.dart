import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_data/wallet_data.dart';

class MarketDataService {
  WebSocketChannel? _channel;

  final StreamController<TickerModel> _tickerController =
      StreamController<TickerModel>.broadcast();
  Stream<TickerModel> get tickerStream => _tickerController.stream;

  void connect() {
    // ⚠️ 避坑指南：
    // iOS 模拟器可以使用 ws://127.0.0.1:8000/ws 或 localhost
    // Android 模拟器必须使用 ws://10.0.2.2:8000/ws
    // 真机测试需替换为电脑的局域网 IP，如 ws://192.168.1.100:8000/ws
    final uri = Uri.parse('ws://127.0.0.1:8000/ws');

    try {
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) {
          final Map<String, dynamic> data = jsonDecode(message);
          final ticker = TickerModel.fromJson(data);
          _tickerController.add(ticker);
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
    _channel?.sink.close();
    _tickerController.close();
  }
}

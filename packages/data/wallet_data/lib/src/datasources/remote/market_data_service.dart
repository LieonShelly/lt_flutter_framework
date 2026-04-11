import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:stream_transform/stream_transform.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_data/wallet_data.dart';

class MarketDataService {
  WebSocketChannel? _channel;
  int _retryCount = 0;
  final int _maxRetries = 10;
  Timer? _reconnectTimer;
  bool _isConnected = false;

  final StreamController<List<TickerModel>> _rawController =
      StreamController<List<TickerModel>>.broadcast();

  // ✅ audit：每 200ms 窗口内只取最后一条数据推给 UI
  // 自动处理 timer 生命周期，stream 关闭时不会有边界问题
  late final Stream<List<TickerModel>> tickerStream = _rawController.stream
      .audit(const Duration(milliseconds: 200));

  void connect() {
    final uri = Uri.parse('ws://127.0.0.1:8000/ws');

    try {
      print('尝试连接... (第 $_retryCount 次重试)');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (message) {
          _isConnected = true;
          _retryCount = 0;
          final List<dynamic> dataList = jsonDecode(message);
          final tickers = dataList.map((e) => TickerModel.fromJson(e)).toList();
          _rawController.add(tickers);
        },
        onError: (error) {
          print('WebSocket 发生错误: $error');
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket 连接已关闭');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      print('连接异常: $e');
      _scheduleReconnect();
    }
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void dispose() {
    _channel?.sink.close();
    _rawController.close();
    _reconnectTimer?.cancel();
  }

  void _scheduleReconnect() {
    _isConnected = false;
    _channel?.sink.close();
    if (_retryCount >= _maxRetries) {
      print('达到最大重连次数，提示用户检查网络');
      return;
    }
    final int delaySeconds = pow(2, _retryCount).toInt();
    final int jitterMs = Random().nextInt(1000);
    final Duration delay = Duration(
      seconds: delaySeconds,
      milliseconds: jitterMs,
    );
    print('将在 ${delay.inSeconds} 秒后尝试重新连接...');
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _retryCount++;
      connect();
    });
  }
}

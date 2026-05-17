import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../kline_data_source.dart';

class PythonGatewayKlineDataSource implements KlineRemoteDataSource {
  final String _baseWsUrl;
  final int _maxRetries;

  PythonGatewayKlineDataSource({
    String baseWsUrl = 'ws://localhost:8000/ws/kline',
    int maxRetries = 10,
  })  : _baseWsUrl = baseWsUrl,
        _maxRetries = maxRetries;

  @override
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    throw UnimplementedError(
      'fetchHistory should use BinanceKlineRemoteDataSource via REST API',
    );
  }

  @override
  Stream<CandleEntity> subscribeRealtime(KlineKey key) {
    final wsUrl = '$_baseWsUrl/${key.symbol.raw}/${key.interval.apiValue}';

    final controller = StreamController<CandleEntity>.broadcast();
    WebSocketChannel? channel;
    Timer? reconnectTimer;
    final shouldReconnect = <bool>[true];
    final retryCount = <int>[0];

    void Function() scheduleReconnect = () {};

    Future<void> connect() async {
      try {
        await channel?.sink.close();

        channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        retryCount[0] = 0;

        channel!.stream.listen(
          (message) {
            try {
              final data = jsonDecode(message as String) as Map<String, dynamic>;
              final eventType = data['event_type'] as String?;
              if (eventType == 'kline') {
                final candle = _parseWsCandle(data['candle'] as Map<String, dynamic>);
                controller.add(candle);
              }
            } catch (e) {
              // Ignore parse errors
            }
          },
          onError: (error) {
            controller.addError(error);
            scheduleReconnect();
          },
          onDone: () {
            scheduleReconnect();
          },
        );
      } catch (e) {
        controller.addError(e);
        scheduleReconnect();
      }
    }

    scheduleReconnect = () {
      if (!controller.isClosed && shouldReconnect[0] && retryCount[0] < _maxRetries) {
        reconnectTimer?.cancel();
        final delay = _calculateBackoff(retryCount[0]);
        retryCount[0]++;
        reconnectTimer = Timer(delay, connect);
      }
    };

    connect();

    controller.onCancel = () {
      shouldReconnect[0] = false;
      reconnectTimer?.cancel();
      channel?.sink.close();
    };

    return controller.stream;
  }

  CandleEntity _parseWsCandle(Map<String, dynamic> candle) {
    return CandleEntity(
      openTime: candle['open_time'] as int,
      closeTime: candle['close_time'] as int,
      open: (candle['open'] as num).toDouble(),
      high: (candle['high'] as num).toDouble(),
      low: (candle['low'] as num).toDouble(),
      close: (candle['close'] as num).toDouble(),
      volume: (candle['volume'] as num).toDouble(),
      quoteVolume: (candle['quote_volume'] as num?)?.toDouble() ?? 0,
      tradeCount: candle['trade_count'] as int? ?? 0,
      isFinal: candle['is_final'] as bool? ?? false,
    );
  }

  Duration _calculateBackoff(int attempt) {
    final baseSeconds = pow(2, attempt).toInt();
    final jitterMs = Random().nextInt(1000);
    return Duration(seconds: baseSeconds, milliseconds: jitterMs);
  }
}

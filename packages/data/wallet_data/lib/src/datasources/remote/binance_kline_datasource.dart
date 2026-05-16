import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

class BinanceKlineRemoteDataSource implements KlineRemoteDataSource {
  const BinanceKlineRemoteDataSource();

  @override
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    // 直接使用 Binance 公开 API 获取历史数据
    final params = <String, dynamic>{
      'symbol': key.symbol.raw,
      'interval': key.interval.apiValue,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final uri = Uri.parse('https://api.binance.com/api/v3/klines')
        .replace(queryParameters: params);

    final response = await _httpGet(uri.toString());
    final data = jsonDecode(response) as List;

    return data.map((raw) => _parseBinanceKline(raw)).toList();
  }

  @override
  Stream<CandleEntity> subscribeRealtime(KlineKey key) {
    final streamId = '${key.symbol.raw.toLowerCase()}_kline_${key.interval.apiValue}';
    final wsUrl = 'wss://stream.binance.com:9443/ws/$streamId';

    final controller = StreamController<CandleEntity>.broadcast();
    WebSocketChannel? channel;
    StreamSubscription? subscription;
    Timer? reconnectTimer;
    final shouldReconnect = <bool>[true];

    void Function() scheduleReconnect = () {};

    Future<void> connect() async {
      try {
        await subscription?.cancel();
        await channel?.sink.close();

        channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        subscription = channel!.stream.listen(
          (message) {
            try {
              final data = jsonDecode(message as String) as Map<String, dynamic>;
              final event = data['e'] as String?;
              if (event == 'kline') {
                final k = data['k'] as Map<String, dynamic>;
                controller.add(_parseBinanceWsKline(k));
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
      reconnectTimer?.cancel();
      reconnectTimer = Timer(const Duration(seconds: 2), () {
        if (!controller.isClosed && shouldReconnect[0]) {
          connect();
        }
      });
    };

    connect();

    controller.onCancel = () {
      shouldReconnect[0] = false;
      reconnectTimer?.cancel();
      subscription?.cancel();
      channel?.sink.close();
    };

    return controller.stream;
  }

  Future<String> _httpGet(String url) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final buffer = StringBuffer();
    await for (final chunk in response.transform(utf8.decoder)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  CandleEntity _parseBinanceKline(dynamic raw) {
    final arr = raw as List;
    return CandleEntity(
      openTime: arr[0] as int,
      closeTime: arr[6] as int,
      open: (arr[1] as num).toDouble(),
      high: (arr[2] as num).toDouble(),
      low: (arr[3] as num).toDouble(),
      close: (arr[4] as num).toDouble(),
      volume: (arr[5] as num).toDouble(),
      quoteVolume: (arr[7] as num).toDouble(),
      tradeCount: int.parse(arr[8].toString()),
      isFinal: arr[11] == true,
    );
  }

  CandleEntity _parseBinanceWsKline(Map<String, dynamic> k) {
    return CandleEntity(
      openTime: k['t'] as int,
      closeTime: k['T'] as int,
      open: (k['o'] as num).toDouble(),
      high: (k['h'] as num).toDouble(),
      low: (k['l'] as num).toDouble(),
      close: (k['c'] as num).toDouble(),
      volume: (k['v'] as num).toDouble(),
      quoteVolume: (k['q'] as num).toDouble(),
      tradeCount: int.parse(k['n'].toString()),
      isFinal: k['x'] == true,
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:lt_network/network.dart';
import 'package:wallet_domain/wallet_domain.dart';

class BinanceApiClient {
  final ApiClientType _client;
  final String _baseUrl;

  BinanceApiClient({
    required ApiClientType client,
    String baseUrl = 'http://localhost:8000',
  })  : _client = client,
        _baseUrl = baseUrl;

  String get baseUrl => _baseUrl;

  Future<List<CandleEntity>> getKlineHistory({
    required String symbol,
    required KlineInterval interval,
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final queryParams = <String, dynamic>{
      'symbol': symbol,
      'interval': interval.apiValue,
      'limit': limit,
    };
    if (startTime != null) queryParams['start_time'] = startTime;
    if (endTime != null) queryParams['end_time'] = endTime;

    final response = await _client.post(
      '$_baseUrl/api/v1/kline/history',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final candles = (data['candles'] as List)
        .map((c) => _parseCandle(c as Map<String, dynamic>))
        .toList();

    return candles;
  }
}

CandleEntity _parseCandle(Map<String, dynamic> json) {
  return CandleEntity(
    openTime: json['open_time'] as int,
    closeTime: json['close_time'] as int,
    open: (json['open'] as num).toDouble(),
    high: (json['high'] as num).toDouble(),
    low: (json['low'] as num).toDouble(),
    close: (json['close'] as num).toDouble(),
    volume: (json['volume'] as num).toDouble(),
    quoteVolume: (json['quote_volume'] as num?)?.toDouble() ?? 0,
    tradeCount: json['trade_count'] as int? ?? 0,
    isFinal: json['is_final'] as bool? ?? false,
  );
}

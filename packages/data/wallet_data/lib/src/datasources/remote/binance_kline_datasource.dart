import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lt_network/network.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

class BinanceKlineRemoteDataSource implements KlineRemoteDataSource {
  final ApiClientType _apiClient;
  final String _baseUrl;

  BinanceKlineRemoteDataSource({
    required ApiClientType apiClient,
    String baseUrl = 'http://localhost:8000',
  })  : _apiClient = apiClient,
        _baseUrl = baseUrl;

  @override
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final queryParams = <String, dynamic>{
      'symbol': key.symbol.raw,
      'interval': key.interval.apiValue,
      'limit': limit,
    };
    if (startTime != null) queryParams['start_time'] = startTime;
    if (endTime != null) queryParams['end_time'] = endTime;

    final response = await _apiClient.post(
      '$_baseUrl/api/v1/kline/history',
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final candles = (data['candles'] as List)
        .map((c) => _parseCandle(c as Map<String, dynamic>))
        .toList();

    return candles;
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

  @override
  Stream<CandleEntity> subscribeRealtime(KlineKey key) {
    return MockKlineRemoteDataSource().subscribeRealtime(key);
  }
}

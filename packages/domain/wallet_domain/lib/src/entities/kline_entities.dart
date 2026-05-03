enum MarketType { spot, margin, futures, perpetual }

enum KlineInterval {
  m1('1m', Duration(minutes: 1)),
  m5('5m', Duration(minutes: 5)),
  m15('15m', Duration(minutes: 15)),
  h1('1h', Duration(hours: 1)),
  h4('4h', Duration(hours: 4)),
  d1('1d', Duration(days: 1));

  final String apiValue;
  final Duration duration;

  const KlineInterval(this.apiValue, this.duration);
}

class MarketEntity {
  final String exchange;
  final MarketType type;

  const MarketEntity({required this.exchange, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketEntity &&
          runtimeType == other.runtimeType &&
          exchange == other.exchange &&
          type == other.type;

  @override
  int get hashCode => Object.hash(exchange, type);
}

class TradingSymbolEntity {
  final String baseAsset;
  final String quoteAsset;
  final String raw;

  const TradingSymbolEntity({
    required this.baseAsset,
    required this.quoteAsset,
    required this.raw,
  });

  String get displayName => '$baseAsset/$quoteAsset';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradingSymbolEntity &&
          runtimeType == other.runtimeType &&
          baseAsset == other.baseAsset &&
          quoteAsset == other.quoteAsset &&
          raw == other.raw;

  @override
  int get hashCode => Object.hash(baseAsset, quoteAsset, raw);
}

class KlineKey {
  final MarketEntity market;
  final TradingSymbolEntity symbol;
  final KlineInterval interval;

  const KlineKey({
    required this.market,
    required this.symbol,
    required this.interval,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KlineKey &&
          runtimeType == other.runtimeType &&
          market == other.market &&
          symbol == other.symbol &&
          interval == other.interval;

  @override
  int get hashCode => Object.hash(market, symbol, interval);
}

class CandleEntity {
  final int openTime;
  final int closeTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int tradeCount;
  final bool isFinal;

  const CandleEntity({
    required this.openTime,
    required this.closeTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.quoteVolume = 0,
    this.tradeCount = 0,
    this.isFinal = false,
  });

  CandleEntity copyWith({
    int? openTime,
    int? closeTime,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
    double? quoteVolume,
    int? tradeCount,
    bool? isFinal,
  }) {
    return CandleEntity(
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
      tradeCount: tradeCount ?? this.tradeCount,
      isFinal: isFinal ?? this.isFinal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandleEntity &&
          runtimeType == other.runtimeType &&
          openTime == other.openTime &&
          closeTime == other.closeTime &&
          open == other.open &&
          high == other.high &&
          low == other.low &&
          close == other.close &&
          volume == other.volume &&
          quoteVolume == other.quoteVolume &&
          tradeCount == other.tradeCount &&
          isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(
    openTime,
    closeTime,
    open,
    high,
    low,
    close,
    volume,
    quoteVolume,
    tradeCount,
    isFinal,
  );
}

class IndicatorSeriesEntity {
  final List<double?> ma5;
  final List<double?> ma10;
  final List<double?> ma30;

  const IndicatorSeriesEntity({
    this.ma5 = const [],
    this.ma10 = const [],
    this.ma30 = const [],
  });
}

# K 线图表功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建独立 Flutter 应用 `apps/kline_chart/`，集成 K 线图表功能，使用 fl_chart 渲染蜡烛图，支持时间周期切换、手势缩放、加载更多历史和实时数据推送。

**Architecture:** 采用 Clean Architecture 分层，数据层通过 Python 网关连接 Binance，Domain 层复用 `wallet_domain` 包定义实体和仓库接口，Presentation 层使用 Riverpod 管理状态并通过 fl_chart 渲染图表。

**Tech Stack:** Flutter + Riverpod + fl_chart + Python Gateway (FastAPI)

---

## 文件结构概览

```
apps/
└── kline_chart/                          # [新增] 独立 Flutter 应用
    ├── lib/
    │   ├── main.dart
    │   └── src/
    │       ├── kline/
    │       │   ├── kline_chart_page.dart  # [新增] K 线图表页面
    │       │   ├── kline_providers.dart  # [新增] Riverpod Providers
    │       │   └── widgets/
    │       │       ├── kline_candle_chart.dart      # [新增] 蜡烛图组件
    │       │       └── kline_interval_selector.dart # [新增] 时间周期选择器
    │       └── di/
    │           └── app_providers.dart     # [新增] 依赖注入
    └── pubspec.yaml                       # [新增] 应用配置

packages/
├── data/wallet_data/lib/src/datasources/remote/
│   ├── binance_kline_datasource.dart       # [修改] REST API 数据源
│   └── python_gateway_kline_datasource.dart # [新增] WebSocket 实时数据源

packages/domain/wallet_domain/lib/          # [复用] 实体定义
```

---

## Task 1: 创建 apps/kline_chart/ 独立 Flutter 应用

**Files:**
- Create: `apps/kline_chart/pubspec.yaml`
- Create: `apps/kline_chart/lib/main.dart`
- Create: `apps/kline_chart/lib/src/di/app_providers.dart`
- Create: `apps/kline_chart/lib/src/kline/kline_providers.dart`

**变更内容:**

### 1.1 创建 `apps/kline_chart/pubspec.yaml`

```yaml
name: kline_chart_app
description: "K Line Chart - Binance K-line visualization app"
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.1.0

  # Chart Library
  fl_chart: ^0.69.0

  # Network & WebSocket
  web_socket_channel: ^3.0.1

  # Domain packages
  wallet_domain:
    path: ../../packages/domain/wallet_domain
  wallet_data:
    path: ../../packages/data/wallet_data

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

### 1.2 创建 `apps/kline_chart/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/di/app_providers.dart';
import 'src/kline/kline_chart_page.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: AppProviders.overrides,
      child: const KlineChartApp(),
    ),
  );
}

class KlineChartApp extends StatelessWidget {
  const KlineChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K Line Chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const KlineChartPage(),
    );
  }
}
```

### 1.3 创建 `apps/kline_chart/lib/src/di/app_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// API Client Provider
final apiClientProvider = Provider<ApiClientType>((ref) {
  return ApiClientType();
});

/// K 线 REST 数据源 Provider
final klineRestDataSourceProvider = Provider<BinanceKlineRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BinanceKlineRemoteDataSource(apiClient: apiClient);
});

/// K 线 WebSocket 数据源 Provider
final klineWsDataSourceProvider = Provider<PythonGatewayKlineDataSource>((ref) {
  return PythonGatewayKlineDataSource();
});

/// K 线仓库 Provider
final klineRepositoryProvider = Provider<KlineRepository>((ref) {
  final restDataSource = ref.watch(klineRestDataSourceProvider);
  final wsDataSource = ref.watch(klineWsDataSourceProvider);
  return KlineRepositoryImpl(
    restDataSource: restDataSource,
    wsDataSource: wsDataSource,
  );
});

/// K 线数据存储 Provider
final klineStoreProvider = Provider<KlineDataStore>((ref) {
  return KlineDataStore();
});

class AppProviders {
  AppProviders._();

  static List<Override> get overrides => [];
}
```

### 1.4 创建 `apps/kline_chart/lib/src/kline/kline_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../di/app_providers.dart';

/// 默认 K 线 Key (BTC/USDT, 1分钟)
const _defaultKlineKey = KlineKey(
  market: MarketEntity(exchange: 'binance', type: MarketType.spot),
  symbol: TradingSymbolEntity(
    baseAsset: 'BTC',
    quoteAsset: 'USDT',
    raw: 'BTCUSDT',
  ),
  interval: KlineInterval.m1,
);

/// 当前选中的 K 线 Key Provider
final selectedKlineKeyProvider = StateProvider<KlineKey>((ref) {
  return _defaultKlineKey;
});

/// K 线图表 ViewModel Provider
final klineViewModelProvider = StateNotifierProvider.autoDispose
    .family<KlineViewModel, KlineState, KlineKey>((ref, key) {
  final repository = ref.watch(klineRepositoryProvider);
  final store = ref.watch(klineStoreProvider);
  return KlineViewModel(
    repository: repository,
    dataStore: store,
    initialKey: key,
  );
});
```

**验收标准:**
- `flutter pub get` 成功安装所有依赖
- 应用可以正常启动（虽然页面内容还未实现）

---

## Task 2: 修改数据层使用 Python 网关

**Files:**
- Modify: `packages/data/wallet_data/lib/src/datasources/remote/binance_kline_datasource.dart`
- Create: `packages/data/wallet_data/lib/src/datasources/remote/python_gateway_kline_datasource.dart`
- Modify: `packages/data/wallet_data/lib/src/datasources/datasources.dart`

**变更内容:**

### 2.1 修改 `binance_kline_datasource.dart` - 使用 Python 网关 REST API

```dart
import 'dart:async';
import 'package:lt_network/network.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

class BinanceKlineRemoteDataSource implements KlineRestDataSource {
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
}
```

### 2.2 新建 `python_gateway_kline_datasource.dart` - WebSocket 实时数据源

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wallet_domain/wallet_domain.dart';

class PythonGatewayKlineDataSource implements KlineWsDataSource {
  final String _baseWsUrl;
  final int _maxRetries;

  PythonGatewayKlineDataSource({
    String baseWsUrl = 'ws://localhost:8000/ws/kline',
    int maxRetries = 10,
  })  : _baseWsUrl = baseWsUrl,
        _maxRetries = maxRetries;

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
```

### 2.3 新增数据源接口定义

**Files:**
- Modify: `packages/data/wallet_data/lib/src/datasources/kline_data_source.dart`

```dart
import 'package:wallet_domain/wallet_domain.dart';

/// K 线 REST API 数据源接口
abstract class KlineRestDataSource {
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  });
}

/// K 线 WebSocket 数据源接口
abstract class KlineWsDataSource {
  Stream<CandleEntity> subscribeRealtime(KlineKey key);
}
```

### 2.4 更新 `datasources.dart` 导出

```dart
library datasources;

export 'kline_data_source.dart';
export 'remote/wallet_remote_datasource.dart';
export 'remote/binance_kline_datasource.dart';
export 'remote/python_gateway_kline_datasource.dart';
export './contract_data_source.dart';
```

**验收标准:**
- `BinanceKlineRemoteDataSource` 通过 Python 网关 `POST /api/v1/kline/history` 获取历史数据
- `PythonGatewayKlineDataSource` 通过 `ws://localhost:8000/ws/kline/{symbol}/{interval}` 订阅实时数据
- 两者正确解析 Python 网关返回的 JSON 格式

---

## Task 3: 创建 K 线图表页面

**Files:**
- Create: `apps/kline_chart/lib/src/kline/kline_chart_page.dart`

**代码:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'kline_providers.dart';
import 'widgets/kline_candle_chart.dart';
import 'widgets/kline_interval_selector.dart';

class KlineChartPage extends ConsumerStatefulWidget {
  const KlineChartPage({super.key});

  @override
  ConsumerState<KlineChartPage> createState() => _KlineChartPageState();
}

class _KlineChartPageState extends ConsumerState<KlineChartPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = ref.read(selectedKlineKeyProvider);
      ref.read(klineViewModelProvider(key).notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      final key = ref.read(selectedKlineKeyProvider);
      ref.read(klineViewModelProvider(key).notifier).loadMoreBefore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = ref.watch(selectedKlineKeyProvider);
    final viewModel = ref.watch(klineViewModelProvider(selectedKey));
    final state = viewModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedKey.symbol.displayName),
        actions: [
          if (state.isReconnecting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          IntervalSelector(
            selectedInterval: selectedKey.interval,
            onIntervalChanged: (interval) {
              final newKey = selectedKey.copyWith(interval: interval);
              ref.read(selectedKlineKeyProvider.notifier).state = newKey;
              ref.read(klineViewModelProvider(newKey).notifier).loadInitial();
            },
          ),
          Expanded(
            child: state.isLoading && state.candles.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.candles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('加载失败: ${state.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(klineViewModelProvider(selectedKey)
                                        .notifier)
                                    .loadInitial();
                              },
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : KlineCandleChart(
                        candles: state.candles,
                        scrollController: _scrollController,
                      ),
          ),
          _buildCurrentPriceInfo(state),
        ],
      ),
    );
  }

  Widget _buildCurrentPriceInfo(KlineState state) {
    if (state.candles.isEmpty) return const SizedBox.shrink();

    final lastCandle = state.candles.last;
    final priceChange = lastCandle.close - lastCandle.open;
    final priceChangePercent = (priceChange / lastCandle.open) * 100;
    final isPositive = priceChange >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPriceColumn('当前价', lastCandle.close.toStringAsFixed(2),
              isPositive ? Colors.green : Colors.red),
          _buildPriceColumn(
              '涨跌幅', '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
              isPositive ? Colors.green : Colors.red),
          _buildPriceColumn('最高', lastCandle.high.toStringAsFixed(2), null),
          _buildPriceColumn('最低', lastCandle.low.toStringAsFixed(2), null),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
```

**验收标准:**
- 页面加载时自动获取初始数据
- 滚动到顶部时自动加载更多历史
- 显示当前价格、涨跌幅、最高价、最低价

---

## Task 4: 创建蜡烛图组件

**Files:**
- Create: `apps/kline_chart/lib/src/kline/widgets/kline_candle_chart.dart`

**代码:**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet_domain/wallet_domain.dart';

class KlineCandleChart extends StatefulWidget {
  final List<CandleEntity> candles;
  final ScrollController? scrollController;

  const KlineCandleChart({
    super.key,
    required this.candles,
    this.scrollController,
  });

  @override
  State<KlineCandleChart> createState() => _KlineCandleChartState();
}

class _KlineCandleChartState extends State<KlineCandleChart> {
  double _minY = 0;
  double _maxY = 0;
  double _minX = 0;
  double _maxX = 0;

  @override
  void initState() {
    super.initState();
    _calculateBounds();
  }

  @override
  void didUpdateWidget(KlineCandleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candles != widget.candles) {
      _calculateBounds();
    }
  }

  void _calculateBounds() {
    if (widget.candles.isEmpty) return;

    double minLow = double.infinity;
    double maxHigh = double.negativeInfinity;

    for (final candle in widget.candles) {
      if (candle.low < minLow) minLow = candle.low;
      if (candle.high > maxHigh) maxHigh = candle.high;
    }

    final padding = (maxHigh - minLow) * 0.1;
    _minY = minLow - padding;
    _maxY = maxHigh + padding;
    _minX = 0;
    _maxX = (widget.candles.length - 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candles.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minX: _minX,
          maxX: _maxX,
          minY: _minY,
          maxY: _maxY,
          clipData: const FlClipData.all(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (_maxX - _minX) / 6,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.candles.length) {
                    return const SizedBox.shrink();
                  }
                  final candle = widget.candles[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(candle.openTime);
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (_maxY - _minY) / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= widget.candles.length) {
                    return null;
                  }
                  final candle = widget.candles[index];
                  return LineTooltipItem(
                    'O: ${candle.open.toStringAsFixed(2)}\n'
                    'H: ${candle.high.toStringAsFixed(2)}\n'
                    'L: ${candle.low.toStringAsFixed(2)}\n'
                    'C: ${candle.close.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: widget.candles.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.close);
              }).toList(),
              isCurved: false,
              color: Colors.blue,
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}
```

**验收标准:**
- 显示蜡烛图的收盘价折线（作为基础）
- 支持触摸显示 OHLC 信息
- 自动计算 Y 轴范围并留出边距

---

## Task 5: 创建时间周期选择器

**Files:**
- Create: `apps/kline_chart/lib/src/kline/widgets/kline_interval_selector.dart`

**代码:**

```dart
import 'package:flutter/material.dart';
import 'package:wallet_domain/wallet_domain.dart';

class IntervalSelector extends StatelessWidget {
  final KlineInterval selectedInterval;
  final ValueChanged<KlineInterval> onIntervalChanged;

  const IntervalSelector({
    super.key,
    required this.selectedInterval,
    required this.onIntervalChanged,
  });

  static const _intervals = [
    KlineInterval.m1,
    KlineInterval.m5,
    KlineInterval.m15,
    KlineInterval.h1,
    KlineInterval.h4,
    KlineInterval.d1,
  ];

  static const _labels = {
    KlineInterval.m1: '1m',
    KlineInterval.m5: '5m',
    KlineInterval.m15: '15m',
    KlineInterval.h1: '1h',
    KlineInterval.h4: '4h',
    KlineInterval.d1: '1D',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _intervals.map((interval) {
          final isSelected = interval == selectedInterval;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                _labels[interval] ?? interval.apiValue,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onIntervalChanged(interval),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

**验收标准:**
- 显示 6 个时间周期选项：1m, 5m, 15m, 1h, 4h, 1D
- 当前选中项高亮显示
- 点击切换时触发回调

---

## Task 6: 更新 Domain 层 - KlineRepository 接口

**Files:**
- Modify: `packages/domain/wallet_domain/lib/src/repositories/kline_repository.dart`

**变更内容:**

```dart
import 'package:wallet_domain/wallet_domain.dart';

abstract class KlineRepository {
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  });

  Stream<CandleEntity> subscribeRealtime(KlineKey key);

  Future<void> unsubscribeRealtime(KlineKey key);
}

class KlineRepositoryImpl implements KlineRepository {
  final KlineRestDataSource restDataSource;
  final KlineWsDataSource wsDataSource;
  final Map<KlineKey, StreamSubscription> _subscriptions = {};

  KlineRepositoryImpl({
    required this.restDataSource,
    required this.wsDataSource,
  });

  @override
  Future<List<CandleEntity>> fetchHistory(
    KlineKey key, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) {
    return restDataSource.fetchHistory(
      key,
      startTime: startTime,
      endTime: endTime,
      limit: limit,
    );
  }

  @override
  Stream<CandleEntity> subscribeRealtime(KlineKey key) {
    return wsDataSource.subscribeRealtime(key);
  }

  @override
  Future<void> unsubscribeRealtime(KlineKey key) async {
    final subscription = _subscriptions.remove(key);
    await subscription?.cancel();
  }
}
```

**验收标准:**
- `KlineRepository` 支持 REST 历史数据获取和 WebSocket 实时订阅
- 独立应用可以正确使用仓库

---

## Task 7: 验证集成

**验证步骤:**

1. 确保 Python 网关运行中：
   ```bash
   cd binance_gateway && python -m binance_gateway.main
   ```

2. 运行 Flutter 应用：
   ```bash
   cd apps/kline_chart
   flutter run
   ```

3. 验证功能：
   - 历史数据正确加载
   - 蜡烛图正确渲染
   - 时间周期切换正常工作
   - 触摸显示 OHLC 信息
   - WebSocket 实时数据更新

---

## 技术决策说明

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 项目结构 | 独立 app (`apps/kline_chart/`) | 独立开发测试，不影响主应用 |
| 数据源分离 | REST 用于历史，WebSocket 用于实时 | REST 更适合分页加载，WebSocket 更适合实时推送 |
| 图表库 | fl_chart | 社区活跃，支持蜡烛图，且轻量 |
| 状态管理 | Riverpod | 与现有架构一致 |
| 重连策略 | 指数退避 + 抖动 | 避免重连风暴 |

---

## 风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Python 网关不可用 | 历史数据无法加载 | 显示友好错误提示，提供重试按钮 |
| WebSocket 断开 | 实时数据停止 | 自动重连，恢复后重新同步 |
| 数据量过大 | 性能问题 | 限制单次加载数量，考虑虚拟化 |

---

## 执行状态

- [ ] Task 1: 创建独立 Flutter 应用
- [ ] Task 2: 修改数据层使用 Python 网关
- [ ] Task 3: 创建 K 线图表页面
- [ ] Task 4: 创建蜡烛图组件
- [ ] Task 5: 创建时间周期选择器
- [ ] Task 6: 更新 Domain 层接口
- [ ] Task 7: 验证集成

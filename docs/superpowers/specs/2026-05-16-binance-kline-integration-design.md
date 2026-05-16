# Binance K线数据集成设计方案

## 概述

在现有 `wallets` feature 基础上扩展数字货币市场价格行情功能，使用 Binance 真实交易所 API 作为数据源，Python 作为统一接口层。

## 需求

- **数据来源**: Binance 交易所 REST API + WebSocket
- **后端定位**: Python 统一接口层，前端只连接 Python
- **核心能力**: 历史 K 线数据（多周期）

## 架构设计

```
┌──────────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                                   │
│  MarketTickerPage → KlineViewModel → Riverpod Providers             │
└─────────────────────────────┬────────────────────────────────────────┘
                              │ consumes
┌─────────────────────────────▼────────────────────────────────────────┐
│  DOMAIN LAYER (wallet_domain)                                        │
│  KlineKey / CandleEntity / IndicatorSeriesEntity                    │
│  KlineRepository (interface)                                         │
│  GetKlineHistory / WatchKlineRealtime (use cases)                   │
└─────────────────────────────┬────────────────────────────────────────┘
                              │ implemented by
┌─────────────────────────────▼────────────────────────────────────────┐
│  DATA LAYER (wallet_data)                                            │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  BinanceKlineRemoteDataSource                                │    │
│  │  - REST: GET /api/v3/klines (历史K线)                       │    │
│  │  - WebSocket: wss://stream.binance.com:9443/kline_         │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                        │
│                              ▼                                        │
│  BinanceKlineRepositoryImpl                                          │
│  (map Binance API → CandleEntity) + KlineStore (内存缓存)            │
└──────────────────────────────────────────────────────────────────────┘
```

## 文件变更清单

| 层级 | 文件 | 操作 | 说明 |
|------|------|------|------|
| **data** | `datasources/binance_api_client.dart` | 新增 | Binance REST API + WebSocket |
| **data** | `datasources/binance_kline_datasource.dart` | 新增 | Binance K线数据源实现 |
| **data** | `datasources/datasources.dart` | 修改 | 导出新数据源 |
| **data** | `repositories/binance_kline_repository_impl.dart` | 新增 | Binance 仓库实现 |
| **data** | `repositories/repositories.dart` | 修改 | 导出新实现 |
| **data** | `providers/wallet_providers.dart` | 修改 | DI 配置 |
| **domain** | `entities/kline_entities.dart` | 修改 | 可能需要扩展字段 |
| **python** | `binance_gateway/` | 新增 | Python 统一网关 |
| **python** | `binance_gateway/main.py` | 新增 | FastAPI 服务入口 |
| **python** | `binance_gateway/kline_handler.py` | 新增 | K线数据处理 |

## Python 网关接口设计

### REST API

```
POST /api/v1/kline/history
  Request:  { symbol: "BTCUSDT", interval: "1m", limit: 200, startTime?, endTime? }
  Response: { candles: [CandleEntity], nextStartTime?: number }
```

### WebSocket

```
WebSocket /ws/kline/{symbol}/{interval}
  Subscribe: Binance kline_ stream
  Forward:  { eventType: "kline", candle: CandleEntity }
```

## 关键设计决策

1. **数据转换**: Binance Raw → `CandleEntity` 在 Flutter 端完成，保持 domain 层纯净
2. **缓存策略**: `KlineStore` 内存缓存 + 去重合并，避免重复数据
3. **实时流**: Python 转发 Binance WebSocket 流，前端订阅 Python WS
4. **可切换性**: 通过 provider 注入，未来可替换为 OKX 实现

## 技术栈

- **Flutter**: Riverpod 状态管理
- **Python**: FastAPI + websockets + aiohttp
- **协议**: REST + WebSocket
- **数据格式**: JSON

## 状态

- [x] 设计完成
- [x] 实现完成

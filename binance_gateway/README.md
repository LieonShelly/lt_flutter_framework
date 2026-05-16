# Binance Gateway

统一网关服务，为 Flutter 应用提供 Binance K 线数据的 REST 与 WebSocket 访问接口。

---

## 架构概览

```
┌──────────────┐      HTTP / WS       ┌──────────────────┐      REST / WS       ┌──────────────┐
│  Flutter App │ ───────────────────▶ │  Binance Gateway │ ──────────────────▶ │  Binance API │
│              │                      │  (FastAPI :8000) │                      │              │
└──────────────┘                      └──────────────────┘                      └──────────────┘
```

网关透明代理 Binance API，应用只需连接本地 Gateway，无需处理跨域、API 签名及重连逻辑。

---

## 技术栈

| 组件 | 技术选型 | 说明 |
|---|---|---|
| Web 框架 | FastAPI 0.115+ | 自动 OpenAPI 文档，类型安全路由 |
| ASGI 服务器 | Uvicorn (with WatchFiles) | 支持热重载的生产级 ASGI |
| HTTP 客户端 | httpx | 异步 HTTP，支持超时控制 |
| WebSocket 客户端 | websockets | 自动重连，异步迭代器风格 |
| 数据验证 | Pydantic v2 | 自动序列化 / 反序列化 |
| 编程语言 | Python 3.11+ | |

---

## 项目结构

```
binance_gateway/
├── binance_gateway/
│   ├── __init__.py        # 公共导出：模型类
│   ├── models.py          # Pydantic 数据模型定义
│   ├── binance_client.py  # Binance API 低级客户端（REST + WebSocket）
│   ├── kline_handler.py   # K 线业务处理层（代理 + 消息转发）
│   └── main.py            # FastAPI 应用入口，路由定义
├── pyproject.toml         # 项目元数据与依赖声明
└── .venv/                 # 虚拟环境（由用户管理，提交时 .gitignore）
```

---

## API 接口

### 1. 健康检查

```
GET /api/v1/health
```

**响应**

```json
{ "status": "ok" }
```

---

### 2. 历史 K 线（REST）

```
POST /api/v1/kline/history
Content-Type: application/json
```

**请求体**

| 字段 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `symbol` | string | ✅ | 交易对，如 `BTCUSDT` |
| `interval` | string | ✅ | K 线周期，可选值见下方 |
| `start_time` | integer (ms) | ❌ | 起始时间戳（毫秒） |
| `end_time` | integer (ms) | ❌ | 结束时间戳（毫秒） |
| `limit` | integer | ❌ | 返回数量，默认 `500`，范围 `1~1500` |

**K 线周期 (`interval`)**

| 值 | 含义 |
|---|---|
| `1m` | 1 分钟 |
| `5m` | 5 分钟 |
| `15m` | 15 分钟 |
| `1h` | 1 小时 |
| `4h` | 4 小时 |
| `1d` | 1 天 |
| `1w` | 1 周 |

**响应**

```json
{
  "candles": [
    {
      "open_time": 1747363200000,
      "close_time": 1747363259999,
      "open": "95234.5",
      "high": "95300.0",
      "low": "95200.0",
      "close": "95280.0",
      "volume": "123.45",
      "quote_volume": "11768432.10",
      "trade_count": 5678,
      "is_final": true
    }
  ],
  "next_start_time": 1747363260000
}
```

`next_start_time` 仅在返回数据达到 `limit` 上限时返回，用于分页获取更早的数据。

**示例 (curl)**

```bash
curl -X POST http://localhost:8000/api/v1/kline/history \
  -H "Content-Type: application/json" \
  -d '{"symbol": "BTCUSDT", "interval": "1m", "limit": 10}'
```

---

### 3. 实时 K 线（WebSocket）

```
WS /ws/kline/{symbol}/{interval}
```

**路径参数**

| 参数 | 说明 |
|---|---|
| `symbol` | 交易对，如 `BTCUSDT` |
| `interval` | K 线周期，如 `1m` |

**客户端连接示例**

```python
import asyncio
import websockets

async def main():
    uri = "ws://localhost:8000/ws/kline/BTCUSDT/1m"
    async with websockets.connect(uri) as ws:
        async for msg in ws:
            print(msg)

asyncio.run(main())
```

**推送消息格式**

```json
{
  "event_type": "kline",
  "symbol": "BTCUSDT",
  "interval": "1m",
  "candle": {
    "open_time": 1747363200000,
    "close_time": 1747363259999,
    "open": "95234.5",
    "high": "95300.0",
    "low": "95200.0",
    "close": "95280.0",
    "volume": "123.45",
    "quote_volume": "11768432.10",
    "trade_count": 5678,
    "is_final": false
  }
}
```

`is_final = false` 表示 K 线尚未闭合，数据会持续更新推送直至该周期结束。

---

## 数据模型

### `CandleData`

| 字段 | 类型 | 说明 |
|---|---|---|
| `open_time` | int | 开仓时间，毫秒时间戳 |
| `close_time` | int | 闭仓时间，毫秒时间戳 |
| `open` | float | 开盘价 |
| `high` | float | 最高价 |
| `low` | float | 最低价 |
| `close` | float | 收盘价 |
| `volume` | float | 成交量（基础资产） |
| `quote_volume` | float | 成交额（计价资产） |
| `trade_count` | int | 成交笔数 |
| `is_final` | bool | 是否为最终确认的 K 线 |

---

## 启动方式

### 前置依赖

- Python 3.11+
- pip 或 uv

### 安装依赖

```bash
# 创建虚拟环境（推荐）
python -m venv .venv
source .venv/bin/activate   # macOS / Linux
# .venv\Scripts\activate    # Windows

# 安装依赖
pip install -e .
```

### 启动服务

```bash
# 方式一：使用 Python 模块运行
python -m binance_gateway.main

# 方式二：使用 uvicorn 直接运行（无需进入 .venv）
uvicorn binance_gateway.main:app --host 0.0.0.0 --port 8000 --reload
```

服务启动后运行在 `http://0.0.0.0:8000`，内置 Swagger 文档地址：`http://localhost:8000/docs`。

### 停止服务

```bash
# 查找进程
lsof -ti:8000

# 终止进程（将 <PID> 替换为上方输出的数字）
kill -9 <PID>
```

---

## 热重载

服务使用 Uvicorn 内置的 WatchFiles 实现热重载。修改任何 `.py` 文件后，服务器会自动重启（仅重载进程，不中断端口）。

---

## 开发

### 运行测试

```bash
pip install -e ".[dev]"
pytest
```

### 代码格式

```bash
ruff check .
ruff format .
```

---

## 配置说明

当前版本无外部配置文件，所有参数通过代码硬编码：

| 配置项 | 值 | 位置 |
|---|---|---|
| 服务端口 | `8000` | `main.py` |
| REST 超时 | `30.0s` | `binance_client.py` |
| Binance REST 基础 URL | `https://api.binance.com` | `binance_client.py` |
| Binance WebSocket URL | `wss://stream.binance.com:9443/ws` | `binance_client.py` |
| 默认分页大小 | `500` | `models.py` |
| CORS | 允许所有来源 (`*`) | `main.py` |

如需扩展为配置文件，可引入 `pydantic-settings` 并定义环境变量或 `.env` 文件。

---

## 已知限制

- **无认证**：当前网关不对外暴露，仅供本地 Flutter 应用访问。如需部署至服务器，请添加 API Key 验证或网络层限制。
- **单 Binance 客户端实例**：`KlineHandler` 在整个应用生命周期内共用一个 `BinanceClient` 实例，无连接池隔离。
- **WebSocket 自动重连**：由 `binance_client.py` 在 `subscribe_kline_stream` 中实现，客户端断开后会等待并重连 Binance 端。
- **CORS 全开**：`allow_origins=["*"]` 仅适合本地开发，生产环境应指定允许的域名。
